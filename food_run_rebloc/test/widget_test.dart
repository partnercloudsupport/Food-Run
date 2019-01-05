// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_run_rebloc/Bloc/GroupsBloc.dart';
import 'package:food_run_rebloc/Bloc/SharedPreferencesBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Screen/SignInSignUpScreen.dart';
import 'package:mockito/mockito.dart';

class MockGroupsBlock extends Mock implements GroupsBloc {}

class MockUsersBloc extends Mock implements UsersBloc {}

class MockSharedPreferences extends Mock implements SharedPreferencesBloc {}

void main() {
  testWidgets("groups availability", (WidgetTester tester) async {
    await tester.pumpAndSettle(Duration(microseconds: 400));

    MockUsersBloc mockUsersBloc = MockUsersBloc();
    MockSharedPreferences mockSharedPreferences = MockSharedPreferences();

    var homeScreen = _makeTestableWidget(mockUsersBloc, mockSharedPreferences);
    await tester.pumpWidget(homeScreen);

    var emailText = find.ancestor(matching: find.byKey(Key("Email Address")));
    await tester.enterText(emailText, "ashkan117@aol.com");
  });
}

Widget _makeTestableWidget(
    MockUsersBloc mockUsersBloc, MockSharedPreferences mockSharedPreferences) {
  return SignInSignUpScreen(
      isSignIn: false,
      usersBloc: mockUsersBloc,
      sharedPreferencesBloc: mockSharedPreferences);
}
