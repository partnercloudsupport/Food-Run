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
        child: Stack(
            overflow: Overflow.clip,
            fit: StackFit.expand,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: Text("Sign In"),
                    onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignInSignUpScreen(
                                isSignIn: true,
                                usersBloc: usersBloc,
                                sharedPreferencesBloc: sharedPreferencesBloc)),
                        (_) => false),
                  ),
                  RaisedButton(
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
                ],
              ),
              Icon(Icons.fastfood),
            ]),
      ),
    );
  }
}
