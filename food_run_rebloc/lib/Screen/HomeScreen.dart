import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/SharedPreferencesBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Screen/SignInSignUpScreen.dart';

class HomeScreen extends StatelessWidget {
  final UsersBloc usersBloc;
  final SharedPreferencesBloc sharedPreferencesBloc;
  HomeScreen({this.usersBloc, this.sharedPreferencesBloc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: const DecorationImage(
          fit: BoxFit.fitHeight,
          image: const AssetImage("assets/login.jpg"),
        )),
        child: Stack(
            fit: StackFit.expand,
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              Positioned(
                bottom: 70.0,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24.0))),
                  child: Text("Sign In"),
                  onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignInSignUpScreen(
                                isSignIn: true,
                                usersBloc: usersBloc,
                                sharedPreferencesBloc: sharedPreferencesBloc)),
                      ),
                ),
              ),
              Positioned(
                bottom: 25.0,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24.0))),
                  child: Text("Sign Up"),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignInSignUpScreen(
                                isSignIn: false,
                                usersBloc: usersBloc,
                                sharedPreferencesBloc: sharedPreferencesBloc,
                              ))),
                ),
              ),
            ]),
      ),
    );
  }
}
