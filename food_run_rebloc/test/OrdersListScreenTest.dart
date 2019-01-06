// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_run_rebloc/Bloc/GroupsBloc.dart';
import 'package:food_run_rebloc/Bloc/ResturantsAndOrdersBloc.dart';
import 'package:food_run_rebloc/Bloc/SharedPreferencesBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Model/Group.dart';
import 'package:food_run_rebloc/Model/Resturant.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:food_run_rebloc/Screen/OrdersListScreen.dart';
import 'package:food_run_rebloc/Screen/SignInSignUpScreen.dart';
import 'package:mockito/mockito.dart';

class MockGroupsBlock extends Mock implements GroupsBloc {}

class MockUsersBloc extends Mock implements UsersBloc {}

class MockSharedPreferences extends Mock implements SharedPreferencesBloc {}

class MockResturantsAndOrdersBloc extends Mock
    implements ResturantsAndOrdersBloc {}

void main() {
  testWidgets("groups availability", (WidgetTester tester) async {
    await tester.pumpAndSettle(Duration(microseconds: 400));

    MockUsersBloc mockUsersBloc = MockUsersBloc();
    MockResturantsAndOrdersBloc mockResturantsAndOrdersBloc =
        MockResturantsAndOrdersBloc();

    var homeScreen =
        _makeTestableWidget(mockUsersBloc, mockResturantsAndOrdersBloc);
    await tester.pumpWidget(homeScreen);
  });
}

Widget _makeTestableWidget(MockUsersBloc mockUsersBloc,
    MockResturantsAndOrdersBloc mockResturantsAndOrdersBloc) {
  return MaterialApp(
    home: OrdersListScreen(
      user: User(id: "1", name: "ash", adminForGroups: ["McDonald's"]),
      group: Group(
          id: "gmr", numberOfUsers: 0, adminPassword: "gmr", password: "gmr"),
      resturant:
          Resturant(id: "McDonald's", name: "McDonald's", numberOfOrders: 0),
      usersBloc: mockUsersBloc,
      resturantsAndOrdersBloc: mockResturantsAndOrdersBloc,
    ),
  );
}
