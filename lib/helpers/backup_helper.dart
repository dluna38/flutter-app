import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:myapp/helpers/io_helpers.dart';

import 'package:myapp/data/database_helper.dart';

class BackupHelper {
  static Future<void> createAndShareBackup({
    required bool includeImages,
    required bool includeReminders,
  }) async {
    try {
      // 1. Get paths
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, 'plants_database.db'));
      final appDir = await getApplicationDocumentsDirectory();

      if (!await dbFile.exists()) {
        debugPrint("Database file not found!");
        return;
      }

      // 2. Prepare temp directory
      final tempDir = await getTemporaryDirectory();
      final backupDir = Directory(join(tempDir.path, 'backup_temp'));
      if (await backupDir.exists()) {
        await backupDir.delete(recursive: true);
      }
      await backupDir.create();

      // 3. Copy Database
      final tempDbPath = join(backupDir.path, 'plants_database.db');
      await dbFile.copy(tempDbPath);

      // 4. Modify Database if needed (Remove Reminders)
      if (!includeReminders) {
        final tempDb = await openDatabase(tempDbPath);
        await tempDb.delete('reminders');
        await tempDb.close();
      }

      // 5. Create Zip
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final zipPath = join(tempDir.path, 'plantapp_backup_$timestamp.zip');
      final encoder = ZipFileEncoder();
      try {
        encoder.create(zipPath);

        // Add DB
        encoder.addFile(File(tempDbPath));

        // 6. Add Images if needed
        if (includeImages) {
          final imagesDir = Directory(
            join(appDir.path, IOHelpers.imagesFolderName),
          );
          if (await imagesDir.exists()) {
            await encoder.addDirectory(imagesDir);
          }
        }
      } finally {
        encoder.close();
      }

      // 7. Share
      SharePlus.instance.share(
        ShareParams(text: 'Plant App Backup', files: [XFile(zipPath)]),
      );

      // Cleanup (Optional, but good practice, though Share might need the file for a bit. Usually Share copies it or opens a stream.
      // Safe to leave in temp, OS cleans up eventually, or clean up next time.)
    } catch (e) {
      debugPrint("Error creating backup: $e");
      // Rethrow or handle? For UI feedback, rethrow might be better or return success bool.
      // But the user interface just needs to be triggered.
    }
  }

  static Future<void> restoreBackup(File zipFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, 'plants_database.db'));

      // 1. Read Zip
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // 2. Validate
      bool hasDb = archive.any(
        (file) =>
            file.name == 'plants_database.db' ||
            file.name.endsWith('plants_database.db'),
      );
      if (!hasDb) {
        throw Exception('Invalid backup: Missing database file');
      }

      // 3. Clear existing state (Close DB)
      await DatabaseHelper().close();

      // 4. Extract Files
      for (final file in archive) {
        if (file.isFile) {
          if (file.name == 'plants_database.db' ||
              file.name.endsWith('plants_database.db')) {
            // Restore DB
            if (await dbFile.exists()) {
              await dbFile.delete();
            }
            final data = file.content as List<int>;
            await dbFile.writeAsBytes(data);
          } else if (file.name.contains('plantsImages')) {
            // Restore Images
            // Ensure path exists
            // file.name includes 'appImages/plantsImages/filename.jpg' or similar depending on how deep it was zipped.
            final filename =
                Config().currentPlatform == TargetPlatform.windows
                    ? file.name.replaceAll('/', '\\')
                    : file.name;
            final fullPath = join(appDir.path, filename);
            final outFile = File(fullPath);
            await outFile.create(recursive: true);
            await outFile.writeAsBytes(file.content as List<int>);
          }
        }
      }
    } catch (e) {
      debugPrint("Error restoring backup: $e");
      rethrow;
    }
  }
}

class Config {
  TargetPlatform get currentPlatform {
    if (kIsWeb) return TargetPlatform.fuchsia; // generic for web
    if (Platform.isMacOS) return TargetPlatform.macOS;
    if (Platform.isWindows) return TargetPlatform.windows;
    if (Platform.isLinux) return TargetPlatform.linux;
    if (Platform.isAndroid) return TargetPlatform.android;
    if (Platform.isIOS) return TargetPlatform.iOS;
    return TargetPlatform.android;
  }
}
