import 'package:food_run_rebloc/Model/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesBloc {
  User user;

  SharedPreferencesBloc() {}

  Future<bool> isUserLoggedIn() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    user = getUserFromPreferences(preferences);
    if (user.id != null) {
      print("User is logged in from preferences");
      return true;
    }
    print("User is NOT logged in from preferences");
    return false;
  }

  static void toSharedPreferences(User user) {}

  static User getUserFromPreferences(SharedPreferences preferences) {
    print("Getting user from preferences");
    return User(
      id: preferences.getString("id"),
      name: preferences.getString("name"),
      isVolunteer: preferences.getBool("isVolunteer") ?? false,
      isAdmin: preferences.getBool("isAdmin") ?? false,
      email: preferences.getString("email"),
      password: preferences.getString("password"),
      groupIds: preferences.getStringList("groupIds"),
    );
  }

  Future saveUser(User user) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("id", user.id);
    sharedPreferences.setString("name", user.name);
    sharedPreferences.setBool("isVolunteer", user.isVolunteer);
    sharedPreferences.setBool("isAdmin", user.isAdmin);
    sharedPreferences.setString("email", user.email);
    sharedPreferences.setString("password", user.password);
    sharedPreferences.setStringList("groupIds", user.groupIds);
    print("Saved user to preference");
  }
}
