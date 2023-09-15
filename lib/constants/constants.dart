class Const {
  static String firebaseWebToken = "332468819428-cfl1304qvatg0j5jd9hsooqvcelf68al.apps.googleusercontent.com";
  static Duration animationDuration = const Duration(milliseconds: 500);
  static String imageLocation(String uid, String pic) => 'https://firebasestorage.googleapis.com/v0/b/contacts-ivykids.appspot.com/o/$uid%2F$pic.jpg?alt=media';
  static double uiRoundness = 10;
  static double bottomNavBarHeight = 60;
  static double appBarHeight = 70;
  static List<String> availableLanguages = [
    'English',
    'Spanish',
    'Russian',
    'French',
    'Greek',
  ];
  static List<String> availableLanguageCodes = [
    'en',
    'es',
    'ru',
    'fr',
    'el',
  ];
}