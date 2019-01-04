import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_run_rebloc/Bloc/GroupsBloc.dart';
import 'package:food_run_rebloc/Bloc/ResturantsAndOrdersBloc.dart';
import 'package:food_run_rebloc/Bloc/SharedPreferencesBloc.dart';
import 'package:food_run_rebloc/Bloc/UsersBloc.dart';
import 'package:food_run_rebloc/Model/Group.dart';
import 'package:food_run_rebloc/Model/Resturant.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:food_run_rebloc/Screen/AddEditGroupScreen.dart';
import 'package:food_run_rebloc/Screen/AddEditResturantScreen.dart';
import 'package:food_run_rebloc/Screen/AdminSettingsScreen.dart';
import 'package:food_run_rebloc/Screen/GroupMembersScreen.dart';
import 'package:food_run_rebloc/Screen/OrdersListScreen.dart';
import 'package:food_run_rebloc/Widgets/ResturantListItem.dart';

class ResturantsListScreen extends StatefulWidget {
  final ResturantsAndOrdersBloc resturantsAndOrdersBloc;
  final Group group;
  final User user;
  final SharedPreferencesBloc sharedPreferencesBloc;
  final GroupsBloc groupsBloc;
  final UsersBloc usersBloc;
  final bool canAddEdit;
  final bool canRemove;

  ResturantsListScreen(
      {@required this.usersBloc,
      @required this.groupsBloc,
      @required this.resturantsAndOrdersBloc,
      @required this.sharedPreferencesBloc,
      @required this.group,
      @required this.canAddEdit,
      @required this.canRemove,
      @required this.user});

  @override
  ResturantsListScreenState createState() {
    return new ResturantsListScreenState(
        canAddEdit: canAddEdit, canRemove: canRemove);
  }
}

class ResturantsListScreenState extends State<ResturantsListScreen> {
  static final List<String> _menuOptions = [
    "Edit Group",
    "Admin Settings",
    "Leave Group"
  ];
  String menuItem;
  User _user;

  bool canAddEdit;
  bool canRemove;
  ResturantsListScreenState({this.canAddEdit, this.canRemove});

  @override
  void dispose() {}

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    widget.usersBloc.userStream.listen((user) {
      setState(() {
        _user = user;
        canAddEdit = Resturant.canAddEdit(user, widget.group);
        canRemove = Resturant.canRemove(user, widget.group);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Resturants for ${widget.group.name}"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.people),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GroupMembersScreen(
                            group: widget.group,
                            usersBloc: widget.usersBloc,
                          )))),
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
                        onTap: () => _goToOrdersList(context, resturant),
                        onLongPress: () {
                          if (canAddEdit) {
                            _goToAddEditResturant(isEdit: true);
                          } else {
                            Fluttertoast.showToast(
                                msg: "Must be admin to add/edit resturants");
                          }
                        }))
                    .toList(),
              );
            }
            return Text("Add A Resturant");
          }),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            if (canAddEdit) {
              _goToAddEditResturant(isEdit: false);
            } else {
              Fluttertoast.showToast(msg: "Must be admin to add resturant");
            }
          }),
    );
  }

  _goToOrdersList(BuildContext context, Resturant resturant) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new OrdersListScreen(
                  group: widget.group,
                  user: _user,
                  resturantsAndOrdersBloc: widget.resturantsAndOrdersBloc,
                  usersBloc: widget.usersBloc,
                  resturant: resturant,
                )));
  }

  void _onMenuItemChanged(BuildContext context, String menuOption) {
    if (menuOption != null) {
      switch (menuOption) {
        case "Edit Group":
          if (canAddEdit) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddEditGroupScreen(
                          groupsBloc: widget.groupsBloc,
                          isEdit: true,
                          existingGroup: widget.group,
                        )));
          } else {
            Fluttertoast.showToast(msg: "Must be admin to edit group!");
          }
          break;
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

  void _goToAddEditResturant({bool isEdit}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddEditResturantScreen(
        isEdit: isEdit,
        onAdd: (resturant) {
          widget.resturantsAndOrdersBloc
              .addResturantToFirestore(resturant, widget.group);
          widget.groupsBloc.addResturantToGroup(resturant, widget.group);
        },
        onEdit: widget.resturantsAndOrdersBloc.updateResturantToFirestore,
        onDelete: (Resturant resturant) {
          if (canRemove) {
            widget.resturantsAndOrdersBloc
                .deleteResturantToFirestore(resturant);
          } else {
            Fluttertoast.showToast(msg: "Must be admin to delete resturant");
          }
        },
      );
    }));
  }
}
