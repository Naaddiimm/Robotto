import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Copies picked photos and PDF manuals into the app's persistent document
/// storage so they survive after the temporary picker cache is cleared.
///
/// Always store the **copied** path returned by these methods in the database,
/// never the original temporary path from the picker.
class FileStorageService {
  static const String _imagesDir = 'shop/images';
  static const String _manualsDir = 'shop/manuals';

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Copies a picked image into `<app documents>/shop/images/` with a unique
  /// name (`prod_<timestamp>_<n>.<ext>`) and returns the new path.
  Future<String> saveProductImage(File picked) async {
    final dir = await _getImagesDirectory();
    final ext = _extension(picked.path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'prod_${timestamp}_${_nextSeq()}.$ext';
    final destPath = p.join(dir.path, filename);
    await picked.copy(destPath);
    return destPath;
  }

  /// Copies a picked PDF manual into `<app documents>/shop/manuals/` with a
  /// unique name and returns the new path.
  Future<String> saveManual(File picked) async {
    final dir = await _getManualsDirectory();
    final ext = _extension(picked.path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'manual_${timestamp}_${_nextSeq()}.$ext';
    final destPath = p.join(dir.path, filename);
    await picked.copy(destPath);
    return destPath;
  }

  /// Deletes a file silently if it exists. No error if the path is null or
  /// the file is already gone.
  Future<void> deleteFile(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Silently ignore — no orphan management needed for a missing file.
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  int _seq = 0;

  String _nextSeq() {
    _seq++;
    return _seq.toString().padLeft(2, '0');
  }

  String _extension(String path) {
    final ext = p.extension(path);
    return ext.isEmpty ? 'jpg' : ext.replaceAll('.', '');
  }

  Future<Directory> _getImagesDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _imagesDir));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> _getManualsDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _manualsDir));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
