import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/GroupsBloc.dart';
import 'package:food_run_rebloc/Bloc/SharedPreferencesBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_run_rebloc/Screen/GroupsListScreen.dart';

class SignInSignUpScreen extends StatefulWidget {
  final bool isSignIn;
  final UsersBloc usersBloc;
  final SharedPreferencesBloc sharedPreferencesBloc;
  SignInSignUpScreen(
      {@required this.isSignIn,
      @required this.usersBloc,
      @required this.sharedPreferencesBloc});

  @override
  SignInSignUpScreenState createState() {
    return new SignInSignUpScreenState();
  }
}

class SignInSignUpScreenState extends State<SignInSignUpScreen> {
  User _user;
  GlobalKey<FormState> _signInSignUpFormsKey = GlobalKey<FormState>();

  TextEditingController _passwordController = new TextEditingController();
  bool _isLoading;
  SignInSignUpScreenState() {
    _user = new User();
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: widget.isSignIn ? Text("Sign In") : Text("Sign Up"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                if (_signInSignUpFormsKey.currentState.validate()) {
                  _signInSignUpFormsKey.currentState.save();
                  setState(() {
                    _isLoading = true;
                  });
                  Function function;
                  if (widget.isSignIn) {
                    function = widget.usersBloc.signInEmailUser;
                  } else {
                    function = widget.usersBloc.sendEmailVerification;
                  }
                  function(_user).then((firebaseAuthData) {
                    if (firebaseAuthData is FirebaseAuthData) {
                      setState(() {
                        _isLoading = false;
                      });
                      _sendToast(firebaseAuthData.message);
                      if (firebaseAuthData.user != null) {
                        widget.sharedPreferencesBloc
                            .saveUser(firebaseAuthData.user);
                        print("Going to Groups List Screen");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GroupsListScreen(
                                    usersBloc: UsersBloc(),
                                    user: firebaseAuthData.user,
                                    groupsBloc: GroupsBloc(
                                        user: firebaseAuthData.user))));
                      }
                    }
                  });
                  //widget.usersBloc.addNewUser(user);
                }
              },
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            _isLoading ? CircularProgressIndicator() : _buildForms(),
          ],
        ));
  }

  _buildForms() {
    return Form(
      key: _signInSignUpFormsKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            validator: (emailAddress) {
              if (emailAddress == "" || emailAddress == null) {
                return "Enter valid email address";
              }
              return null;
            },
            decoration: InputDecoration(hintText: "Email Address"),
            onSaved: (email) => _user.email = email,
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(hintText: "Password"),
            validator: (password) {
              if (password == "" || password == null) {
                return "Enter valid password";
              }
              if (password.length < 6) {
                return "Password should be at least 6 characters";
              }
              return null;
            },
            onSaved: (password) => _user.password = password,
          ),
          widget.isSignIn
              ? new Container()
              : TextFormField(
                  validator: (confirmPassword) {
                    if (_passwordController.text.toString() == "" ||
                        _passwordController.text.toString() == null) {
                      return null;
                    }
                    if (confirmPassword.length < 6) {
                      return "Password should be at least 6 characters";
                    }
                    if (confirmPassword !=
                        _passwordController.text.toString()) {
                      return "Passwords don't match";
                    }
                    return null;
                  },
                  decoration: InputDecoration(hintText: "Confirm Password"),
                ),
        ],
      ),
    );
  }

  void _sendToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white);
  }
}
