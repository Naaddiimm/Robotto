import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:robotto/shop/validators/product_validators.dart';

void main() {
  // ===========================================================================
  // validateName
  // ===========================================================================
  group('ProductValidators.validateName', () {
    test('returns null for a valid name', () {
      expect(ProductValidators.validateName('Arduino Uno'), isNull);
      expect(ProductValidators.validateName('  Arduino Uno  '), isNull);
    });

    test('returns error for empty or whitespace-only', () {
      expect(ProductValidators.validateName(''), 'Product name is required');
      expect(ProductValidators.validateName('   '), 'Product name is required');
      expect(ProductValidators.validateName(null), 'Product name is required');
    });

    test('returns error for too short (< 3)', () {
      expect(ProductValidators.validateName('AB'), 'Name must be at least 3 characters');
      expect(ProductValidators.validateName('  A  '), 'Name must be at least 3 characters');
    });

    test('returns null at exactly 3 characters', () {
      expect(ProductValidators.validateName('ABC'), isNull);
    });

    test('returns error for too long (> 60)', () {
      expect(ProductValidators.validateName('A' * 61), 'Name must be at most 60 characters');
    });

    test('returns null at exactly 60 characters', () {
      expect(ProductValidators.validateName('A' * 59 + 'b'), isNull);
    });

    test('returns error for no letters', () {
      expect(ProductValidators.validateName('123'), 'Name must contain at least one letter');
      expect(ProductValidators.validateName('   456   '), 'Name must contain at least one letter');
    });
  });

  // ===========================================================================
  // validateDescription
  // ===========================================================================
  group('ProductValidators.validateDescription', () {
    test('returns null for a valid description', () {
      expect(ProductValidators.validateDescription('A great sensor for robotics projects'), isNull);
    });

    test('returns error for empty', () {
      expect(ProductValidators.validateDescription(''), 'Description is required');
      expect(ProductValidators.validateDescription(null), 'Description is required');
    });

    test('returns error for too short (< 10)', () {
      expect(ProductValidators.validateDescription('Short'), 'Description must be at least 10 characters');
    });

    test('returns null at exactly 10 characters', () {
      expect(ProductValidators.validateDescription('123456789a'), isNull);
    });

    test('returns error for too long (> 500)', () {
      expect(ProductValidators.validateDescription('A' * 501), 'Description must be at most 500 characters');
    });

    test('returns null at exactly 500 characters', () {
      expect(ProductValidators.validateDescription('A' * 500), isNull);
    });
  });

  // ===========================================================================
  // validateCategory
  // ===========================================================================
  group('ProductValidators.validateCategory', () {
    test('returns null for valid categories', () {
      expect(ProductValidators.validateCategory('Sensors'), isNull);
      expect(ProductValidators.validateCategory('Development boards'), isNull);
      expect(ProductValidators.validateCategory('Mechanical parts'), isNull);
    });

    test('returns error for empty', () {
      expect(ProductValidators.validateCategory(''), 'Category is required');
      expect(ProductValidators.validateCategory(null), 'Category is required');
    });

    test('returns error for invalid category', () {
      expect(ProductValidators.validateCategory('Electronics'), 'Select a valid category');
      expect(ProductValidators.validateCategory('sensor'), 'Select a valid category');
    });
  });

  // ===========================================================================
  // validateLevel
  // ===========================================================================
  group('ProductValidators.validateLevel', () {
    test('returns null for valid levels', () {
      expect(ProductValidators.validateLevel('Beginner'), isNull);
      expect(ProductValidators.validateLevel('Intermediate'), isNull);
      expect(ProductValidators.validateLevel('Advanced'), isNull);
    });

    test('returns error for empty', () {
      expect(ProductValidators.validateLevel(''), 'Level is required');
      expect(ProductValidators.validateLevel(null), 'Level is required');
    });

    test('returns error for invalid level', () {
      expect(ProductValidators.validateLevel('Expert'), 'Select a valid level');
    });
  });

  // ===========================================================================
  // validateBrand
  // ===========================================================================
  group('ProductValidators.validateBrand', () {
    test('returns null for empty (optional)', () {
      expect(ProductValidators.validateBrand(''), isNull);
      expect(ProductValidators.validateBrand(null), isNull);
      expect(ProductValidators.validateBrand('   '), isNull);
    });

    test('returns null for valid brand', () {
      expect(ProductValidators.validateBrand('Adafruit'), isNull);
    });

    test('returns error for too short (< 2)', () {
      expect(ProductValidators.validateBrand('A'), 'Brand must be at least 2 characters');
    });

    test('returns null at exactly 2 characters', () {
      expect(ProductValidators.validateBrand('AB'), isNull);
    });

    test('returns error for too long (> 40)', () {
      expect(ProductValidators.validateBrand('A' * 41), 'Brand must be at most 40 characters');
    });

    test('returns null at exactly 40 characters', () {
      expect(ProductValidators.validateBrand('A' * 40), isNull);
    });
  });

  // ===========================================================================
  // validatePrice
  // ===========================================================================
  group('ProductValidators.validatePrice', () {
    test('returns null for valid prices with dot', () {
      expect(ProductValidators.validatePrice('10.99'), isNull);
      expect(ProductValidators.validatePrice('0.01'), isNull);
      expect(ProductValidators.validatePrice('100000'), isNull);
      expect(ProductValidators.validatePrice('99999.99'), isNull);
    });

    test('returns null for valid prices with comma', () {
      expect(ProductValidators.validatePrice('10,99'), isNull);
      expect(ProductValidators.validatePrice('0,01'), isNull);
    });

    test('returns error for empty', () {
      expect(ProductValidators.validatePrice(''), 'Price is required');
      expect(ProductValidators.validatePrice(null), 'Price is required');
    });

    test('returns error for zero or negative', () {
      expect(ProductValidators.validatePrice('0'), 'Price must be greater than 0');
      expect(ProductValidators.validatePrice('-5'), 'Price must be greater than 0');
      expect(ProductValidators.validatePrice('0.00'), 'Price must be greater than 0');
    });

    test('returns error for above 100000', () {
      expect(ProductValidators.validatePrice('100001'), 'Price must be at most 100000');
      expect(ProductValidators.validatePrice('100000.01'), 'Price must be at most 100000');
    });

    test('returns null at exactly 100000', () {
      expect(ProductValidators.validatePrice('100000'), isNull);
      expect(ProductValidators.validatePrice('100000.00'), isNull);
    });

    test('returns error for more than 2 decimal places', () {
      expect(ProductValidators.validatePrice('10.999'), 'Price can have at most 2 decimal places');
      expect(ProductValidators.validatePrice('10,999'), 'Price can have at most 2 decimal places');
    });

    test('returns null for exactly 2 decimal places', () {
      expect(ProductValidators.validatePrice('10.99'), isNull);
    });

    test('returns error for non-numeric', () {
      expect(ProductValidators.validatePrice('abc'), 'Enter a valid price');
      expect(ProductValidators.validatePrice('1.2.3'), 'Enter a valid price');
    });
  });

  // ===========================================================================
  // validateStock
  // ===========================================================================
  group('ProductValidators.validateStock', () {
    test('returns null for valid stock values', () {
      expect(ProductValidators.validateStock('0'), isNull);
      expect(ProductValidators.validateStock('100'), isNull);
      expect(ProductValidators.validateStock('100000'), isNull);
    });

    test('returns error for empty', () {
      expect(ProductValidators.validateStock(''), 'Stock is required');
      expect(ProductValidators.validateStock(null), 'Stock is required');
    });

    test('returns error for negative', () {
      expect(ProductValidators.validateStock('-1'), 'Stock cannot be negative');
    });

    test('returns error for above 100000', () {
      expect(ProductValidators.validateStock('100001'), 'Stock must be at most 100000');
    });

    test('returns null at boundaries 0 and 100000', () {
      expect(ProductValidators.validateStock('0'), isNull);
      expect(ProductValidators.validateStock('100000'), isNull);
    });

    test('returns error for non-integer', () {
      expect(ProductValidators.validateStock('abc'), 'Stock must be a whole number');
      expect(ProductValidators.validateStock('1.5'), 'Stock must be a whole number');
    });
  });

  // ===========================================================================
  // validateWeightKg
  // ===========================================================================
  group('ProductValidators.validateWeightKg', () {
    test('returns null for valid weights with dot', () {
      expect(ProductValidators.validateWeightKg('1.5'), isNull);
      expect(ProductValidators.validateWeightKg('0.001'), isNull);
      expect(ProductValidators.validateWeightKg('500'), isNull);
      expect(ProductValidators.validateWeightKg('499.999'), isNull);
    });

    test('returns null for valid weights with comma', () {
      expect(ProductValidators.validateWeightKg('1,5'), isNull);
      expect(ProductValidators.validateWeightKg('0,001'), isNull);
    });

    test('returns error for empty', () {
      expect(ProductValidators.validateWeightKg(''), 'Weight is required');
      expect(ProductValidators.validateWeightKg(null), 'Weight is required');
    });

    test('returns error for zero or negative', () {
      expect(ProductValidators.validateWeightKg('0'), 'Weight must be greater than 0');
      expect(ProductValidators.validateWeightKg('-1'), 'Weight must be greater than 0');
    });

    test('returns error for above 500', () {
      expect(ProductValidators.validateWeightKg('501'), 'Weight must be at most 500 kg');
      expect(ProductValidators.validateWeightKg('500.001'), 'Weight must be at most 500 kg');
    });

    test('returns null at exactly 500', () {
      expect(ProductValidators.validateWeightKg('500'), isNull);
      expect(ProductValidators.validateWeightKg('500.000'), isNull);
    });

    test('returns error for more than 3 decimal places', () {
      expect(ProductValidators.validateWeightKg('1.5000'), 'Weight can have at most 3 decimal places');
    });

    test('returns null for exactly 3 decimal places', () {
      expect(ProductValidators.validateWeightKg('1.500'), isNull);
    });

    test('returns error for non-numeric', () {
      expect(ProductValidators.validateWeightKg('abc'), 'Enter a valid weight');
    });
  });

  // ===========================================================================
  // validatePhotos (file-based)
  // ===========================================================================
  group('ProductValidators.validatePhotos', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('shop_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    File createFile(String name, int sizeBytes) {
      final file = File('${tempDir.path}/$name');
      file.writeAsBytesSync(List.filled(sizeBytes, 0));
      return file;
    }

    test('returns error for null or empty list', () {
      expect(ProductValidators.validatePhotos(null), 'At least one photo is required');
      expect(ProductValidators.validatePhotos([]), 'At least one photo is required');
    });

    test('returns error for more than 5 photos', () {
      final photos = List.generate(6, (i) => createFile('photo$i.jpg', 100));
      expect(ProductValidators.validatePhotos(photos), 'Maximum 5 photos allowed');
    });

    test('returns null for 1 to 5 valid photos', () {
      final photos1 = [createFile('photo.jpg', 100)];
      expect(ProductValidators.validatePhotos(photos1), isNull);

      final photos5 = List.generate(5, (i) => createFile('photo$i.jpg', 100));
      expect(ProductValidators.validatePhotos(photos5), isNull);
    });

    test('returns error for unsupported extension', () {
      final photo = createFile('photo.gif', 100);
      expect(ProductValidators.validatePhotos([photo]), 'Only JPG, PNG and WebP images are allowed');
    });

    test('returns null for jpg, jpeg, png, webp', () {
      for (final ext in ['jpg', 'jpeg', 'png', 'webp']) {
        final photo = createFile('photo.$ext', 100);
        expect(ProductValidators.validatePhotos([photo]), isNull);
      }
    });

    test('returns error for file over 5 MB', () {
      final photo = createFile('photo.jpg', 5 * 1024 * 1024 + 1);
      expect(ProductValidators.validatePhotos([photo]), 'Each photo must be at most 5 MB');
    });

    test('returns null for file exactly 5 MB', () {
      final photo = createFile('photo.jpg', 5 * 1024 * 1024);
      expect(ProductValidators.validatePhotos([photo]), isNull);
    });

    test('returns error for non-existent file', () {
      final photo = File('${tempDir.path}/nonexistent.jpg');
      expect(ProductValidators.validatePhotos([photo]), 'One or more photos could not be found');
    });
  });

  // ===========================================================================
  // validateManual (file-based)
  // ===========================================================================
  group('ProductValidators.validateManual', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('shop_manual_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('returns null for null (optional)', () {
      expect(ProductValidators.validateManual(null), isNull);
    });

    test('returns null for a valid PDF', () {
      final file = File('${tempDir.path}/manual.pdf');
      file.writeAsBytesSync(List.filled(100, 0));
      expect(ProductValidators.validateManual(file), isNull);
    });

    test('returns error for non-PDF extension', () {
      final file = File('${tempDir.path}/manual.txt');
      file.writeAsBytesSync(List.filled(100, 0));
      expect(ProductValidators.validateManual(file), 'Only PDF files are allowed');
    });

    test('returns error for empty file', () {
      final file = File('${tempDir.path}/manual.pdf');
      file.writeAsBytesSync([]);
      expect(ProductValidators.validateManual(file), 'The file is empty');
    });

    test('returns error for file over 10 MB', () {
      final file = File('${tempDir.path}/manual.pdf');
      file.writeAsBytesSync(List.filled(10 * 1024 * 1024 + 1, 0));
      expect(ProductValidators.validateManual(file), 'The manual must be at most 10 MB');
    });

    test('returns null for file exactly 10 MB', () {
      final file = File('${tempDir.path}/manual.pdf');
      file.writeAsBytesSync(List.filled(10 * 1024 * 1024, 0));
      expect(ProductValidators.validateManual(file), isNull);
    });

    test('returns error for non-existent file', () {
      final file = File('${tempDir.path}/nonexistent.pdf');
      expect(ProductValidators.validateManual(file), 'The selected file could not be found');
    });
  });
}
