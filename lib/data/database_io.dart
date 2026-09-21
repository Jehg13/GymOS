import 'dart:io';
import 'dart:convert';

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
            version: 3,
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
              await database.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
              await database.execute('''
          CREATE TABLE app_state (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
            },
            onUpgrade: (database, oldVersion, newVersion) async {
              if (oldVersion < 2) {
                await database.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
              }
              if (oldVersion < 3) {
                await database.execute('''
          CREATE TABLE app_state (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
              }
            },
          ),
        );
  }

  Future<List<Map<String, dynamic>>> readCollection(String key) async {
    final rows = await database.query(
      'app_state',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return [];
    try {
      final decoded = jsonDecode(rows.first['value'] as String);
      if (decoded is! List) {
        throw const FormatException('La colección no contiene una lista.');
      }
      return decoded.map((item) {
        if (item is! Map) {
          throw const FormatException('Elemento inválido en la colección.');
        }
        return Map<String, dynamic>.from(item);
      }).toList();
    } on FormatException catch (error) {
      throw StateError('No se pudo leer la colección "$key": $error');
    } on TypeError catch (error) {
      throw StateError('No se pudo interpretar la colección "$key": $error');
    }
  }

  Future<void> writeCollection(
    String key,
    List<Map<String, dynamic>> values,
  ) async {
    await database.insert('app_state', {
      'key': key,
      'value': jsonEncode(values),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, Object?>?> findUser(String email) async {
    final rows = await database.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> createUser({
    required String name,
    required String email,
    required String passwordHash,
  }) async {
    await database.insert('users', {
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updatePassword(String email, String passwordHash) async {
    await database.update(
      'users',
      {'password_hash': passwordHash},
      where: 'email = ?',
      whereArgs: [email],
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
