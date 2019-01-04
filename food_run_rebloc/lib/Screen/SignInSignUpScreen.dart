import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/GroupsBloc.dart';
import 'package:food_run_rebloc/Bloc/SharedPreferencesBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_run_rebloc/Screen/GroupsListScreen.dart';
import 'package:food_run_rebloc/Widgets/AvailabilityWidget.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

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

  static final GlobalKey<AvailabilityWidgetState> _availabilityKey =
      new GlobalKey<AvailabilityWidgetState>();
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
            onPressed: () async {
              //state
              //available
              //taken
              //signin

              //order
              //if is signing up check name availability and save

              bool isNameAvailable;
              if (!widget.isSignIn) {
                isNameAvailable =
                    await _availabilityKey.currentState.isAvailable();
              }
              if (_signInSignUpFormsKey.currentState.validate()) {
                if (!widget.isSignIn) {
                  if (isNameAvailable) {
                    _availabilityKey.currentState.save();
                  } else {
                    print("User not available");
                    Fluttertoast.showToast(
                        msg:
                            "Username is already taken"); //widget.usersBloc.addNewUser(user);
                  }
                }
                _signInSignUpFormsKey.currentState.save();
                _callProperFunction();
              }
            },
          )
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: _buildForms(),
      ),
    );
  }

  _buildForms() {
    return Form(
      key: _signInSignUpFormsKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            key: Key("Email Address"),
            validator: (emailAddress) {
              if (emailAddress == "" || emailAddress == null) {
                return "Enter valid email address";
              }
              return null;
            },
            decoration: InputDecoration(
                hintText: "Email Address",
                contentPadding: EdgeInsets.all(16.0)),
            onSaved: (email) => _user.email = email,
          ),
          widget.isSignIn
              ? Container()
              : AvailabilityWidget(
                  key: _availabilityKey,
                  decoration: InputDecoration(hintText: "Username"),
                  validator: (input) {
                    if (input != null || input == "") {
                      "Can't be empty";
                    }
                  },
                  onSaved: (name) {
                    setState(() {
                      _user.name = name;
                    });
                  },
                  isAvailable: (name) {
                    return widget.usersBloc.usernameIsAvailable(name);
                  },
                ),
          TextFormField(
            key: Key("Password"),
            controller: _passwordController,
            decoration: InputDecoration(
                hintText: "Password", contentPadding: EdgeInsets.all(16.0)),
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
                  key: Key("Confirm Password"),
                  validator: (confirmPassword) {
                    if (confirmPassword !=
                        _passwordController.text.toString()) {
                      return "Passwords don't match";
                    } else if (confirmPassword == null ||
                        confirmPassword == "") {
                      return "Can't be empty";
                    }
                    if (confirmPassword.length < 6) {
                      return "Password should be at least 6 characters";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      hintText: "Confirm Password",
                      contentPadding: EdgeInsets.all(16.0)),
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

  void _callProperFunction() {
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
          widget.sharedPreferencesBloc.saveUser(firebaseAuthData.user);
          print("Going to Groups List Screen");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GroupsListScreen(
                      usersBloc: UsersBloc(),
                      groupsBloc: GroupsBloc(user: firebaseAuthData.user))));
        }
      }
    });
  }

  Widget _buildIndicator() {
    return Expanded(
      child: Center(
          child: FittedBox(
        child: CircularProgressIndicator(
          value: 24.0,
        ),
        fit: BoxFit.contain,
      )),
    );
  }
}
