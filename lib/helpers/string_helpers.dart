import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class StringHelpers {
  static const noLocationPlant = "Sin ubicación";

  static String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  static String formatLocalDate(
    DateTime? date,
    BuildContext context, {
    String format = "",
  }) {
    if (date == null) {
      return 'Sin fecha';
    }
    final locale = Localizations.localeOf(context).toString();

    return DateFormat(
      format.isEmpty ? 'dd/MM/yyyy \'a las\' hh:mm a' : format,
      locale,
    ).format(date);
  }
}

enum LevelLog {
  info(normalName: 'INFO'),
  error(normalName: 'ERROR');

  final String normalName;
  const LevelLog({required this.normalName});
}
