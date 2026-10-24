import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:robotto/features/shop/validators/product_validators.dart';
import 'package:robotto/features/shop/data/models/product.dart';

void main() {
  // -- Name --
  group('validateName', () {
    test('valid', () => expect(ProductValidators.validateName('Sensor'), isNull));
    test('null → error', () => expect(ProductValidators.validateName(null), isNotNull));
    test('empty → error', () => expect(ProductValidators.validateName(''), isNotNull));
    test('whitespace only → error', () => expect(ProductValidators.validateName('   '), isNotNull));
    test('2 chars → error', () => expect(ProductValidators.validateName('AB'), isNotNull));
    test('3 chars boundary → valid', () => expect(ProductValidators.validateName('Abc'), isNull));
    test('60 chars → valid', () => expect(ProductValidators.validateName('A' * 59 + 'b'), isNull));
    test('61 chars → error', () => expect(ProductValidators.validateName('A' * 61), isNotNull));
    test('no letter → error', () => expect(ProductValidators.validateName('123'), isNotNull));
  });

  // -- Description --
  group('validateDescription', () {
    test('valid', () => expect(ProductValidators.validateDescription('This is a great sensor'), isNull));
    test('9 chars → error', () => expect(ProductValidators.validateDescription('123456789'), isNotNull));
    test('10 chars → valid', () => expect(ProductValidators.validateDescription('1234567890'), isNull));
    test('500 chars → valid', () => expect(ProductValidators.validateDescription('A' * 500), isNull));
    test('501 chars → error', () => expect(ProductValidators.validateDescription('A' * 501), isNotNull));
    test('empty → error', () => expect(ProductValidators.validateDescription(''), isNotNull));
  });

  // -- Category --
  group('validateCategory', () {
    for (final cat in Product.categories) {
      test('$cat → valid', () => expect(ProductValidators.validateCategory(cat), isNull));
    }
    test('invalid → error', () => expect(ProductValidators.validateCategory('Rockets'), isNotNull));
    test('empty → error', () => expect(ProductValidators.validateCategory(''), isNotNull));
    test('null → error', () => expect(ProductValidators.validateCategory(null), isNotNull));
  });

  // -- Level --
  group('validateLevel', () {
    for (final lvl in Product.levels) {
      test('$lvl → valid', () => expect(ProductValidators.validateLevel(lvl), isNull));
    }
    test('invalid → error', () => expect(ProductValidators.validateLevel('Expert'), isNotNull));
    test('empty → error', () => expect(ProductValidators.validateLevel(''), isNotNull));
  });

  // -- Brand --
  group('validateBrand', () {
    test('empty/null → valid (optional)', () {
      expect(ProductValidators.validateBrand(''), isNull);
      expect(ProductValidators.validateBrand(null), isNull);
    });
    test('1 char → error', () => expect(ProductValidators.validateBrand('A'), isNotNull));
    test('2 chars → valid', () => expect(ProductValidators.validateBrand('AB'), isNull));
    test('40 chars → valid', () => expect(ProductValidators.validateBrand('A' * 40), isNull));
    test('41 chars → error', () => expect(ProductValidators.validateBrand('A' * 41), isNotNull));
  });

  // -- Price --
  group('validatePrice', () {
    test('valid dot', () => expect(ProductValidators.validatePrice('9.99'), isNull));
    test('valid comma', () => expect(ProductValidators.validatePrice('9,99'), isNull));
    test('0 → error', () => expect(ProductValidators.validatePrice('0'), isNotNull));
    test('negative → error', () => expect(ProductValidators.validatePrice('-1'), isNotNull));
    test('100000 → valid', () => expect(ProductValidators.validatePrice('100000'), isNull));
    test('100000.01 → error', () => expect(ProductValidators.validatePrice('100000.01'), isNotNull));
    test('3 decimals → error', () => expect(ProductValidators.validatePrice('1.999'), isNotNull));
    test('2 decimals → valid', () => expect(ProductValidators.validatePrice('1.99'), isNull));
    test('non-numeric → error', () => expect(ProductValidators.validatePrice('abc'), isNotNull));
    test('empty → error', () => expect(ProductValidators.validatePrice(''), isNotNull));
  });

  // -- Stock --
  group('validateStock', () {
    test('0 → valid', () => expect(ProductValidators.validateStock('0'), isNull));
    test('100000 → valid', () => expect(ProductValidators.validateStock('100000'), isNull));
    test('100001 → error', () => expect(ProductValidators.validateStock('100001'), isNotNull));
    test('negative → error', () => expect(ProductValidators.validateStock('-1'), isNotNull));
    test('float → error', () => expect(ProductValidators.validateStock('1.5'), isNotNull));
    test('empty → error', () => expect(ProductValidators.validateStock(''), isNotNull));
  });

  // -- Weight --
  group('validateWeightKg', () {
    test('valid', () => expect(ProductValidators.validateWeightKg('1.5'), isNull));
    test('comma', () => expect(ProductValidators.validateWeightKg('1,5'), isNull));
    test('0 → error', () => expect(ProductValidators.validateWeightKg('0'), isNotNull));
    test('negative → error', () => expect(ProductValidators.validateWeightKg('-1'), isNotNull));
    test('500 → valid', () => expect(ProductValidators.validateWeightKg('500'), isNull));
    test('500.001 → error', () => expect(ProductValidators.validateWeightKg('500.001'), isNotNull));
    test('3 decimals → valid', () => expect(ProductValidators.validateWeightKg('1.500'), isNull));
    test('4 decimals → error', () => expect(ProductValidators.validateWeightKg('1.0001'), isNotNull));
    test('empty → error', () => expect(ProductValidators.validateWeightKg(''), isNotNull));
  });

  // -- Photos --
  group('validatePhotos', () {
    late Directory tempDir;
    setUp(() => tempDir = Directory.systemTemp.createTempSync('shop_test_'));
    tearDown(() => tempDir.deleteSync(recursive: true));

    File makeFile(String name, int bytes) =>
        File('${tempDir.path}/$name')..writeAsBytesSync(List.filled(bytes, 0));

    test('null → error', () => expect(ProductValidators.validatePhotos(null), isNotNull));
    test('empty → error', () => expect(ProductValidators.validatePhotos([]), isNotNull));
    test('1 jpg → valid', () => expect(ProductValidators.validatePhotos([makeFile('a.jpg', 100)]), isNull));
    test('5 png → valid', () => expect(ProductValidators.validatePhotos(List.generate(5, (i) => makeFile('$i.png', 100))), isNull));
    test('6 → error', () => expect(ProductValidators.validatePhotos(List.generate(6, (i) => makeFile('$i.jpg', 100))), isNotNull));
    test('gif → error', () => expect(ProductValidators.validatePhotos([makeFile('a.gif', 100)]), isNotNull));
    test('webp → valid', () => expect(ProductValidators.validatePhotos([makeFile('a.webp', 100)]), isNull));
    test('over 5 MB → error', () => expect(ProductValidators.validatePhotos([makeFile('a.jpg', 5 * 1024 * 1024 + 1)]), isNotNull));
    test('exactly 5 MB → valid', () => expect(ProductValidators.validatePhotos([makeFile('a.jpg', 5 * 1024 * 1024)]), isNull));
  });

  // -- Manual PDF --
  group('validateManual', () {
    late Directory tempDir;
    setUp(() => tempDir = Directory.systemTemp.createTempSync('shop_pdf_'));
    tearDown(() => tempDir.deleteSync(recursive: true));

    File makeFile(String name, int bytes) =>
        File('${tempDir.path}/$name')..writeAsBytesSync(List.filled(bytes, 0));

    test('null → valid (optional)', () => expect(ProductValidators.validateManual(null), isNull));
    test('valid pdf', () => expect(ProductValidators.validateManual(makeFile('m.pdf', 100)), isNull));
    test('txt → error', () => expect(ProductValidators.validateManual(makeFile('m.txt', 100)), isNotNull));
    test('empty file → error', () => expect(ProductValidators.validateManual(makeFile('m.pdf', 0)), isNotNull));
    test('over 10 MB → error', () => expect(ProductValidators.validateManual(makeFile('m.pdf', 10 * 1024 * 1024 + 1)), isNotNull));
    test('exactly 10 MB → valid', () => expect(ProductValidators.validateManual(makeFile('m.pdf', 10 * 1024 * 1024)), isNull));
  });
}
