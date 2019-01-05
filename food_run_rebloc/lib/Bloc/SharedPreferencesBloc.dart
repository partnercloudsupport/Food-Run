import 'package:food_run_rebloc/Model/LoadingState.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesBloc {
  User user;
  SharedPreferencesBloc._() {
    _isUserLoggedIn();
  }
  static SharedPreferencesBloc _instance;
  PublishSubject<LoginState> isLoggedInStream = PublishSubject<LoginState>();

  /*
  Must call initializationDOne

  how to enforce
   */

  static SharedPreferencesBloc getInstance() {
    if (_instance == null) {
      _instance = SharedPreferencesBloc._();
    }
    return _instance;
  }

  Future<bool> _isUserLoggedIn() async {
    isLoggedInStream.add(LoginState.init);
    isLoggedInStream.add(LoginState.loading);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    user = getUserFromPreferences(preferences);
    if (user.id != null) {
      print(user.toString());
      print("User is logged in from preferences");
      isLoggedInStream.add(LoginState.signedIn);
      return true;
    }
    print("User is NOT logged in from preferences");
    isLoggedInStream.add(LoginState.notSignedIn);
    return false;
  }

  static void toSharedPreferences(User user) {}

  static User getUserFromPreferences(SharedPreferences preferences) {
    print("Getting user from preferences");
    return User(
      id: preferences.getString("id"),
      name: preferences.getString("name"),
      volunteeredResturants: preferences.getStringList("volunteeredGroups"),
      adminForGroups: preferences.getStringList("adminForGroups"),
      email: preferences.getString("email"),
      password: preferences.getString("password"),
      groupIds: preferences.getStringList("groupIds"),
    );
  }

  Future saveUser(User user) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("id", user.id);
    sharedPreferences.setString("name", user.name);
    sharedPreferences.setStringList(
        "volunteeredGroups", user.volunteeredResturants);
    sharedPreferences.setStringList("adminForGroups", user.adminForGroups);
    sharedPreferences.setString("email", user.email);
    sharedPreferences.setString("password", user.password);
    sharedPreferences.setStringList("groupIds", user.groupIds);
    print("Saved user to preference");
  }

  Future signOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print("User signed out");
    isLoggedInStream.add(LoginState.notSignedIn);
    await sharedPreferences.clear();
  }
}
