import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/GroupsBloc.dart';
import 'package:food_run_rebloc/Bloc/ResturantsAndOrdersBloc.dart';
import 'package:food_run_rebloc/Bloc/SharedPreferencesBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Model/Group.dart';
import 'package:food_run_rebloc/Model/Resturant.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:food_run_rebloc/Screen/AddEditResturantScreen.dart';
import 'package:food_run_rebloc/Screen/AdminSettingsScreen.dart';
import 'package:food_run_rebloc/Screen/OrdersListScreen.dart';
import 'package:food_run_rebloc/Widgets/ResturantListItem.dart';

class ResturantsListScreen extends StatefulWidget {
  final ResturantsAndOrdersBloc resturantsAndOrdersBloc;
  final Group group;
  User user;
  final SharedPreferencesBloc sharedPreferencesBloc;
  final GroupsBloc groupsBloc;
  final UsersBloc usersBloc;

  ResturantsListScreen({
    @required this.usersBloc,
    @required this.groupsBloc,
    @required this.resturantsAndOrdersBloc,
    @required this.sharedPreferencesBloc,
    @required this.group,
  }) {
    user = usersBloc.signedInUser;
  }

  @override
  ResturantsListScreenState createState() {
    return new ResturantsListScreenState();
  }
}

class ResturantsListScreenState extends State<ResturantsListScreen> {
  static final List<String> _menuOptions = ["Leave Group", "Admin Settings"];
  String menuItem;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Resturants"),
        actions: <Widget>[
          PopupMenuButton<String>(
              initialValue: null,
              onSelected: (menuOption) {
                setState(() {
                  menuItem = menuOption;
                  print("MenuItem is now $menuItem");
                });
                _onMenuItemChanged(context, menuOption);
              },
              itemBuilder: (context) {
                return _menuOptions.map((menuItem) {
                  return PopupMenuItem<String>(
                    child: Text(menuItem),
                    value: menuItem,
                  );
                }).toList();
              }),
        ],
      ),
      body: StreamBuilder(
          stream: widget.resturantsAndOrdersBloc.resturants,
          builder: (BuildContext context,
              AsyncSnapshot<List<Resturant>> resturants) {
            if (resturants.hasData) {
              return ListView(
                children: resturants.data
                    .map((resturant) => ResturantListItem(
                        resturant: resturant,
                        onTap: () =>
                            _onResturantListItemTap(context, resturant),
                        onLongPress: () =>
                            _onResturantListItemLongPress(context, resturant)))
                    .toList(),
              );
            }
            return Text("Add A Resturant");
          }),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return AddEditResturantScreen(
                isEdit: false,
                onAdd: (resturant) {
                  widget.resturantsAndOrdersBloc
                      .addResturantToFirestore(resturant, widget.group);
                  widget.groupsBloc
                      .addResturantToGroup(resturant, widget.group);
                },
                onEdit:
                    widget.resturantsAndOrdersBloc.updateResturantToFirestore,
                onDelete:
                    widget.resturantsAndOrdersBloc.deleteResturantToFirestore,
              );
            }));
          }),
    );
  }

  _onResturantListItemTap(BuildContext context, Resturant resturant) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new OrdersListScreen(
                widget.resturantsAndOrdersBloc, widget.usersBloc, resturant)));
  }

  _onResturantListItemLongPress(BuildContext context, Resturant resturant) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new AddEditResturantScreen(
                  isEdit: true,
                  existingResturant: resturant,
                  onAdd: (resturant) {
                    widget.resturantsAndOrdersBloc
                        .addResturantToFirestore(resturant, widget.group);
                  },
                  onEdit:
                      widget.resturantsAndOrdersBloc.updateResturantToFirestore,
                  onDelete:
                      widget.resturantsAndOrdersBloc.deleteResturantToFirestore,
                )));
  }

  void _onMenuItemChanged(BuildContext context, String menuOption) {
    if (menuOption != null) {
      switch (menuOption) {
        case "Leave Group":
          widget.usersBloc.leaveGroup(widget.group.id);
          Navigator.pop(context, widget.usersBloc.signedInUser);
          break;
        case "Admin Settings":
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminSettingsScreen(
                        group: widget.group,
                        usersBloc: widget.usersBloc,
                        resturantsAndOrdersBloc:
                            ResturantsAndOrdersBloc(widget.group),
                        groupsBloc:
                            GroupsBloc(user: widget.usersBloc.signedInUser),
                      )));
      }
    }
  }
}
