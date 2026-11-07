// ignore_for_file: avoid_print
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  sqfliteFfiInit();
  final dbPath = p.normalize(p.join(Directory.current.path, '../../backend/sample_flow.db'));
  print('Inspecting DB at: $dbPath');

  final db = await databaseFactoryFfi.openDatabase(dbPath);
  
  final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%';");
  print('\n=== Tables in SQLite database ===');
  for (var t in tables) {
    print('• ${t['name']}');
  }

  print('\n=== Rows in "samples" table ===');
  final samples = await db.rawQuery('SELECT id, title, category, status, remaining_days FROM samples;');
  if (samples.isEmpty) {
    print('(No samples yet - add one in the app and re-pull!)');
  } else {
    for (var s in samples) {
      print('• [#${s['id']}] ${s['title']} | ${s['category']} | Status: ${s['status']} | ${s['remaining_days']}d left');
    }
  }

  print('\n=== Rows in "notifications" table ===');
  final notifs = await db.rawQuery('SELECT id, title, is_read FROM notifications;');
  if (notifs.isEmpty) {
    print('(No notifications yet)');
  } else {
    for (var n in notifs) {
      print('• [#${n['id']}] ${n['title']} (read: ${n['is_read'] == 1})');
    }
  }

  await db.close();
}
