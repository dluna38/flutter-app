class StringHelpers{
  static const NO_LOCATION_PLANT="Sin ubicación";



  static String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}

enum LevelLog{
  info(normalName: 'INFO'),
  error(normalName: 'ERROR');

  final String normalName;
  const LevelLog({required this.normalName});
}
