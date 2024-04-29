class StringUtils {
  static String getLottieByName(String lotterName) {
    return "assets/lotties/$lotterName.json";
  }
}

String capitalize(String str) {
  return str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1)}' : str;
}
