import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kPrefix = 'anchor.schedule.';

/// The user's daily schedule and derived free-time calculations.
class UserSchedule {
  const UserSchedule({
    required this.wakeTime,
    required this.leaveTime,
    required this.returnTime,
    required this.sleepTime,
  });

  final TimeOfDay wakeTime;
  final TimeOfDay leaveTime;
  final TimeOfDay returnTime;
  final TimeOfDay sleepTime;

  static const UserSchedule defaults = UserSchedule(
    wakeTime: TimeOfDay(hour: 7, minute: 0),
    leaveTime: TimeOfDay(hour: 9, minute: 0),
    returnTime: TimeOfDay(hour: 19, minute: 0),
    sleepTime: TimeOfDay(hour: 23, minute: 0),
  );

  // Sleep before 5 AM is treated as "next day" for arithmetic.
  int get _sleepHourNorm =>
      sleepTime.hour < 5 ? sleepTime.hour + 24 : sleepTime.hour;

  int get morningWindowHours =>
      (leaveTime.hour - wakeTime.hour).clamp(0, 24);

  int get eveningWindowHours =>
      (_sleepHourNorm - returnTime.hour).clamp(0, 24);

  bool get hasMorningWindow => morningWindowHours > 1;

  int get morningOwnedHours =>
      morningWindowHours > 1 ? morningWindowHours - 1 : 0;

  int get eveningAfterWorkHours =>
      eveningWindowHours > 1 ? eveningWindowHours - 1 : 0;

  int get eveningOwnedHours =>
      eveningAfterWorkHours > 1 ? eveningAfterWorkHours - 1 : 0;

  int get dailyOwnedHours => morningOwnedHours + eveningOwnedHours;
  int get weeklyOwnedHours => dailyOwnedHours * 5;

  UserSchedule copyWith({
    TimeOfDay? wakeTime,
    TimeOfDay? leaveTime,
    TimeOfDay? returnTime,
    TimeOfDay? sleepTime,
  }) =>
      UserSchedule(
        wakeTime: wakeTime ?? this.wakeTime,
        leaveTime: leaveTime ?? this.leaveTime,
        returnTime: returnTime ?? this.returnTime,
        sleepTime: sleepTime ?? this.sleepTime,
      );

  static Future<UserSchedule?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final wakeH = prefs.getInt('${_kPrefix}wake_h');
    if (wakeH == null) return null;
    return UserSchedule(
      wakeTime: TimeOfDay(
        hour: wakeH,
        minute: prefs.getInt('${_kPrefix}wake_m') ?? 0,
      ),
      leaveTime: TimeOfDay(
        hour: prefs.getInt('${_kPrefix}leave_h') ?? 9,
        minute: prefs.getInt('${_kPrefix}leave_m') ?? 0,
      ),
      returnTime: TimeOfDay(
        hour: prefs.getInt('${_kPrefix}return_h') ?? 19,
        minute: prefs.getInt('${_kPrefix}return_m') ?? 0,
      ),
      sleepTime: TimeOfDay(
        hour: prefs.getInt('${_kPrefix}sleep_h') ?? 23,
        minute: prefs.getInt('${_kPrefix}sleep_m') ?? 0,
      ),
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_kPrefix}wake_h', wakeTime.hour);
    await prefs.setInt('${_kPrefix}wake_m', wakeTime.minute);
    await prefs.setInt('${_kPrefix}leave_h', leaveTime.hour);
    await prefs.setInt('${_kPrefix}leave_m', leaveTime.minute);
    await prefs.setInt('${_kPrefix}return_h', returnTime.hour);
    await prefs.setInt('${_kPrefix}return_m', returnTime.minute);
    await prefs.setInt('${_kPrefix}sleep_h', sleepTime.hour);
    await prefs.setInt('${_kPrefix}sleep_m', sleepTime.minute);
  }
}

final userScheduleProvider = StateProvider<UserSchedule?>((ref) => null);
