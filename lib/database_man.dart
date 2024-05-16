import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseManage {
  static Database? _db;

  static Future<Database> get database async {
    if(_db != null) return _db!;

    _db = await initDatabase();
    return _db!;
  }

  static Future<Database> initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'crud_user_flutter.db'),
      onCreate: (db,version) async {
        //Tabela User
        await db.execute(
          '''
          CREATE TABLE user_table (
            texto TEXT NOT NULL,
            numero INTEGER UNIQUE NOT NULL CHECK (numero>0)
            );
          ''');
        //Tabela Logs
        await db.execute(
          '''
          CREATE TABLE user_logs (
            operacao TEXT NOT NULL,
            datahora TEXT DEFAULT CURRENT_TIMESTAMP
          );
          ''');
        //Trigger log para insert
        await db.execute(
          '''
          CREATE TRIGGER trigger_to_log_inserts
          AFTER INSERT ON user_table
          BEGIN
            INSERT INTO user_logs (operacao, datahora) VALUES (
              'INSERT ' || new.numero || ',' || new.texto, strftime('%d-%m-%Y %H:%M:%S', 'now')
            );
          END;
          ''');
        //Trigger log para update
        await db.execute(
          '''
          CREATE TRIGGER trigger_to_log_updates
          AFTER UPDATE ON user_table
          BEGIN
            INSERT INTO user_logs (operacao, datahora) VALUES (
              'UPDATE ' || new.numero || ',' || new.texto || ' WHERE ' || old.numero, strftime('%d-%m-%Y %H:%M:%S', 'now')
            );
          END;
          ''');
        //Trigger log para delete
        await db.execute(
          '''
          CREATE TRIGGER trigger_to_log_deletes
          AFTER DELETE ON user_table
          BEGIN
            INSERT INTO user_logs (operacao, datahora) VALUES (
              'DELETE ' || old.numero || ',' || old.texto, strftime('%d-%m-%Y %H:%M:%S', 'now')
            );
          END;
          ''');
      },
      version: 1,
    );
  }
  //C
  static Future<void> insertUser(Map<String, dynamic> data) async{
    final db = await database;
    await db.insert('user_table', data, conflictAlgorithm: ConflictAlgorithm.ignore);
  }
  //R
  static Future<List<Map<String, dynamic>>> getAllData() async{
    final db = await database;
    return db.query('user_table');
  }
  //U
  static Future<void> updateUser(int uid, String utext) async{
    final db = await database;
    await db.update(
        "user_table",
        {'texto': utext},
        where: 'numero = ?',
        whereArgs: [uid]
    );
  }
  //D
  static Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(
        "user_table",
        where: 'numero = ?',
        whereArgs: [id]
    );
  }

  // -----------------------logs------------------------------

  static Future<List<Map<String,dynamic>>> getLogs() async{
    final db = await database;
    return db.query('user_logs');
  }
}