import 'package:hive/hive.dart';
import 'package:leadmanagementsystem/models/reminder_model.dart';

class ReminderStorage {
  static final _box = Hive.box('remindersBox');
  static const String _reminderKey = 'reminders';

  static Future<void> saveReminder(ReminderModel reminder) async {
    final list = getReminders();
    list.add(reminder);
    await _box.put(_reminderKey, ReminderModel.encodeList(list));
  }

  static List<ReminderModel> getReminders() {
    final data = _box.get(_reminderKey);
    if (data == null || data.isEmpty) return [];
    return ReminderModel.decodeList(data);
  }

  static Future<void> deleteReminder(int id) async {
    final list = getReminders();
    list.removeWhere((r) => r.id == id);
    await _box.put(_reminderKey, ReminderModel.encodeList(list));
  }

  static Future<void> updateReminder(ReminderModel updated) async {
    final list = getReminders();
    final index = list.indexWhere((r) => r.id == updated.id);
    if (index != -1) {
      list[index] = updated;
      await _box.put(_reminderKey, ReminderModel.encodeList(list));
    }
  }
}
