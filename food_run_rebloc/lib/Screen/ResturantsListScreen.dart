import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Bloc/OrdersBloc.dart';
import 'package:food_run_rebloc/Bloc/ResturantsAndOrdersBloc.dart';
import 'package:food_run_rebloc/Model/Group.dart';
import 'package:food_run_rebloc/Model/Resturant.dart';
import 'package:food_run_rebloc/Screen/AddEditResturantScreen.dart';
import 'package:food_run_rebloc/Screen/OrdersListScreen.dart';
import 'package:food_run_rebloc/Widgets/ResturantListItem.dart';

class ResturantsListScreen extends StatelessWidget {
  final ResturantsAndOrdersBloc resturantsAndOrdersBloc;
  final Group group;
  ResturantsListScreen({this.resturantsAndOrdersBloc, this.group});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Resturants"),
      ),
      body: StreamBuilder(
          stream: resturantsAndOrdersBloc.resturants,
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
            return Container();
          }),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return AddEditResturantScreen(
                isEdit: false,
                onAdd: resturantsAndOrdersBloc.addResturantToFirestore,
                onEdit: resturantsAndOrdersBloc.updateResturantToFirestore,
                onDelete: resturantsAndOrdersBloc.deleteResturantToFirestore,
              );
            }));
          }),
    );
  }

  _onResturantListItemTap(BuildContext context, Resturant resturant) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                new OrdersListScreen(resturantsAndOrdersBloc, resturant)));
  }

  _onResturantListItemLongPress(BuildContext context, Resturant resturant) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new AddEditResturantScreen(
                  isEdit: true,
                  existingResturant: resturant,
                  onAdd: resturantsAndOrdersBloc.addResturantToFirestore,
                  onEdit: resturantsAndOrdersBloc.updateResturantToFirestore,
                  onDelete: resturantsAndOrdersBloc.deleteResturantToFirestore,
                )));
  }
}
