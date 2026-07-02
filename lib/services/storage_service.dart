// ─────────────────────────────────────────────────────────────────────────
// StorageService — Centralize File Logic (Best Practice ✅)
//
// All local JSON read/write goes through this single class so providers
// never touch dart:io / path_provider directly.
//
//  ✅ Always async/await — never blocks the UI
//  ✅ try/catch around every operation — missing/corrupted files handled
//  ✅ Validates decoded JSON before returning it
//  ✅ Uses path_provider instead of hardcoded paths
// ─────────────────────────────────────────────────────────────────────────
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  StorageService._();

  static Future<File> _file(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$filename');
  }

  /// Read and decode a JSON file.
  /// Returns `null` if the file is missing, empty, or invalid JSON —
  /// callers should treat `null` as "no data yet", not as an error.
  static Future<dynamic> readJson(String filename) async {
    try {
      final file = await _file(filename);
      if (!await file.exists()) return null; // ✅ "Missing File? No Plan" — handled

      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return null;

      return jsonDecode(raw); // may throw FormatException
    } on FormatException {
      return null; // ✅ "Assuming Valid JSON" — corrupted file handled
    } catch (_) {
      return null; // any other I/O error
    }
  }

  /// Encode [data] as JSON and write it to [filename].
  /// Returns `true` on success, `false` if the write failed.
  static Future<bool> writeJson(String filename, dynamic data) async {
    try {
      final file = await _file(filename);
      await file.writeAsString(jsonEncode(data));
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> deleteFile(String filename) async {
    try {
      final file = await _file(filename);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}
