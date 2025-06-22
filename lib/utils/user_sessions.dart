import 'package:aiims_heartcare/local/preference.dart';

class UserSession {
  static String? userToken;
  static String? userName;
  static String? email;
  static String? language;
  static String? mobileNo;

  static clearSession() {
    userName = null;
    email = null;
    userToken = null;
    language = 'en';
    mobileNo = null;
  }

  UserSession() {
    userToken = Preference.getString(Preference.USER_TOKEN);
    email = Preference.getString(Preference.USER_EMAIL);
    userName = Preference.getString(Preference.FIRST_NAME);
    mobileNo = Preference.getString(Preference.PHONE);

    language = Preference.getString(Preference.LANGUAGE);
  }
}
