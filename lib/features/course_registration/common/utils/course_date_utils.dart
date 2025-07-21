class CourseDateUtils {
  static String formatStudyWeeks(String studyWeeks) {
    try {
      List<String> strings = studyWeeks.split(";");
      String result = "Thứ ";
      int index = 2;

      for (String str in strings) {
        if (str.isNotEmpty) {
          result += "$index: $str;";
        }
        index++;
      }

      if (result.length > 4) {
        result = result.substring(0, result.length - 1);
      }

      return result;
    } catch (e) {
      return "";
    }
  }
}
