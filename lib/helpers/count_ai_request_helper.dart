import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


//very simple and not very secure limit assure
class CounterAiHelper{
  static const String _counterKey = 'daily_counter_value';
  static const String _lastResetDateKey = 'last_reset_date';


  Future<int> getCounter() async {
    final prefs = await SharedPreferences.getInstance();

    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String? lastResetDate = prefs.getString(_lastResetDateKey);

    int counterValue;

    if (lastResetDate != today || prefs.getInt(_counterKey) ==null) {
      debugPrint('renew counter: $lastResetDate | counter: ${prefs.getInt(_counterKey)}');
      counterValue =10;
      await prefs.setInt(_counterKey, counterValue);
      await prefs.setString(_lastResetDateKey, today);
    } else {
      debugPrint('get counter');
      counterValue = prefs.getInt(_counterKey) ?? 10;
    }

    return counterValue;
  }

  // Disminuye el contador en 1
  Future<int> decrementCounter() async {
    final prefs = await SharedPreferences.getInstance();
    int currentCounter = await getCounter();

    if (currentCounter > 0) {
      currentCounter--;
      await prefs.setInt(_counterKey, currentCounter);
    }

    return currentCounter;
  }
}