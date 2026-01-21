import 'package:aiims_heartcare/local/preference.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

class UserSession {
  static String? userToken;
  static String? userName;
  static String? email;
  static String? language;
  static String? mobileNo;
    static String? age;
      static String? dob;


  static clearSession() {
    userName = null;
    email = null;
    userToken = null;
    language = 'en';
    mobileNo = null;
  }

static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    userToken = prefs.getString('userToken');
    email = prefs.getString('email');
    userName = prefs.getString('userName');
     age = prefs.getString('age');
     dob = prefs.getString('dob');
  }
static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userToken');
    await prefs.remove('email');
    await prefs.remove('userName');
    userToken = null;
    email = null;
    userName = null;
  }
  UserSession() {
    userToken = Preference.getString(Preference.USER_TOKEN);
    email = Preference.getString(Preference.USER_EMAIL);
    userName = Preference.getString(Preference.FIRST_NAME);
    mobileNo = Preference.getString(Preference.PHONE);
    age = Preference.getString(Preference.AGE);
    dob = Preference.getString(Preference.DOB);

    language = Preference.getString(Preference.LANGUAGE);
  }
}
