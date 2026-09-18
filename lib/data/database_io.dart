import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class GymDatabase {
  GymDatabase._();

  static final GymDatabase instance = GymDatabase._();
  Database? _database;

  Future<void> initialize() async {
    if (_database != null) return;

    final isDesktop =
        Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    if (isDesktop) {
      sqfliteFfiInit();
    }

    final databasePath = isDesktop
        ? path.join((await getApplicationSupportDirectory()).path, 'gym_os.db')
        : path.join(await getDatabasesPath(), 'gym_os.db');

    _database = await (isDesktop ? databaseFactoryFfi : databaseFactory)
        .openDatabase(
          databasePath,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: (database, version) async {
              await database.execute('''
          CREATE TABLE routines (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
              await database.execute('''
          CREATE TABLE exercises (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            muscle_group TEXT,
            created_at TEXT NOT NULL
          )
        ''');
            },
          ),
        );
  }

  Database get database {
    final database = _database;
    if (database == null) {
      throw StateError('GymDatabase.initialize() debe ejecutarse primero.');
    }
    return database;
  }
}
