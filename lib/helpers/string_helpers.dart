class StringHelpers{
  static const NO_LOCATION_PLANT="Sin ubicación";
}

enum LevelLog{
  info(normalName: 'INFO'),
  error(normalName: 'ERROR');

  final String normalName;
  const LevelLog({required this.normalName});
}
