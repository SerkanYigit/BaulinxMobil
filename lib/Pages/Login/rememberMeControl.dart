import 'package:shared_preferences/shared_preferences.dart';

class RememberMeControl {
  RememberMeControl._privateConstructor();

  static final RememberMeControl instance =
  RememberMeControl._privateConstructor();
  setRemember(String key, List<String> value) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    myPrefs.setStringList(key, value);
  }

  Future<List<String>> getRemember(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();


      return myPrefs.getStringList(key) ?? [];



  }
}
