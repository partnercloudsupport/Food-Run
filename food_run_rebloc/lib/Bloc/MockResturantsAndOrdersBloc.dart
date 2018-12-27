//import 'package:flutter/material.dart';
//import 'package:food_run_rebloc/Model/Group.dart';
//import 'package:food_run_rebloc/Model/Order.dart';
//import 'package:food_run_rebloc/Model/Resturant.dart';
//
//class MockResturantsAndOrdersBloc {
//  List<Resturant> _zeroResturantList = [
//    Resturant(
//      id: UniqueKey().toString(),
//      name: "Chipotle",
//      numberOfOrders: 0,
//    ),
//    Resturant(
//      id: UniqueKey().toString(),
//      name: "Philippes",
//      numberOfOrders: 0,
//    ),
//  ];
//
//  List<Resturant> _firstResturantList = [
//    Resturant(
//      id: UniqueKey().toString(),
//      name: "McDonald's",
//      numberOfOrders: 0,
//    ),
//    Resturant(
//      id: UniqueKey().toString(),
//      name: "Philippes",
//      numberOfOrders: 0,
//    ),
//  ];
//
//  Stream<List<Resturant>> get resturants => getResturantsFromFirestore();
//  //Stream<List<Order>> get orders => getOrdersFromFirestore();
//  Group group;
//
//  MockResturantsAndOrdersBloc(this.group);
//
//  void addResturantToFirestore(Resturant resturant) {
//    List<Resturant> newResturant = _getResturantList(group);
//    newResturant.add(resturant);
//    Future.delayed(Duration(seconds: 1))
//        .then((_) => print("Resturant: ${resturant.name} Added"))
//        .catchError(
//            (_) => print("Resturant: ${resturant.name} being added failed"));
//  }
//
//  void deleteResturantToFirestore(Resturant resturant) {
//    List<Resturant> newResturant = _getResturantList(group);
//    newResturant.remove(resturant);
//    Future.delayed(Duration(seconds: 1))
//        .then((_) => print("Resturant: ${resturant.name} Deleted"))
//        .catchError(
//            (_) => print("Resturant: ${resturant.name} being deleted failed"));
//  }
//
//  void updateResturantToFirestore(Resturant resturant) {
//    List<Resturant> newResturant = _getResturantList(group);
//    for(int i = 0; i < newResturant.length; i++){
//      if(newResturant[i].id == resturant.id){
//        newResturant[i] = Resturant.copyWith(resturant);
//      }
//    }
//    Future.delayed(Duration(seconds: 1))
//        .then((_) => print("Resturant: ${resturant.name} updated"))
//        .catchError(
//            (_) => print("Resturant: ${resturant.name} being updated failed"));
//  }
//
//  //We want a Stream<List<Resturant>> so we need to convert
//  //AsyncSnapshot -> List<Resturant>
//  Stream<List<Resturant>> getResturantsFromFirestore() {
//    Future<List<Resturant>> resturant =
//        Future.delayed(Duration(seconds: 3)).then((_) {
//      switch (group.id) {
//        case "0":
//          return _zeroResturantList;
//        case "1":
//          {
//            return _firstResturantList;
//          }
//          ;
//      }
//    });
//    Stream<List<Resturant>> resturantStream = Firestore.instance
//        .collection(resturantsCollectionRefrence)
//        .document(group.id)
//        .collection(resturantsCollectionRefrence)
//        .snapshots()
//        .asyncMap((snapshot) => snapshot.documents.map((docSnapshot) {
//              return Resturant.fromDocument(docSnapshot);
//            }).toList());
//    return resturantStream;
//  }
//
//  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  //Consider having the resturant a field so that when we're working with orders we ahve an associated resturant
//
//  //Orders
//
//  Future<Null> addOrderToFirestore(
//      Order orderToAdd, Resturant resturant) async {
//    CollectionReference collectionReference = Firestore.instance
//        .collection(ordersCollectionRefrence)
//        .document(resturant.id)
//        .collection(ordersCollectionRefrence);
//    await collectionReference.add(Order.toMap(orderToAdd)).then((_) {
//      print("Order Added");
//      _incrementResturantToFirestore(resturant);
//    }).catchError((_) => print("Order being added failed"));
//  }
//
//  Future<Null> deleteOrderToFirestore(
//      Order orderToDelete, Resturant resturant) {
//    Firestore.instance
//        .collection(ordersCollectionRefrence)
//        .document(resturant.id)
//        .collection(ordersCollectionRefrence)
//        .document(orderToDelete.id)
//        .delete()
//        .then((_) {
//      print("${orderToDelete.order} by ADD_USER_HERE deleted");
//      _decrementResturantToFirestore(resturant);
//    }).catchError((_) => print("Order failed to delete"));
//  }
//
//  void updateOrderToFirestore(Order orderToEdit, Resturant resturant) {
//    Firestore.instance
//        .collection(ordersCollectionRefrence)
//        .document(resturant.id)
//        .collection(ordersCollectionRefrence)
//        .document(orderToEdit.id)
//        .updateData(Order.toMap(orderToEdit))
//        .then((_) => print("${orderToEdit.order} by ADD_USER_HERE edited"))
//        .catchError((_) => print("Order failed to edit"));
//  }
//  //What happens if you just map the async data???
//
//  //Need to map async since we only want to map once we recieve the data
//
//  Stream<List<Order>> getOrdersFromFirestore(Resturant resturant) {
//    Stream<List<Order>> ordersStream = Firestore.instance
//        .collection(ordersCollectionRefrence)
//        .document(resturant.id)
//        .collection(ordersCollectionRefrence)
//        .snapshots()
//        .asyncMap((querySnapshot) {
//      print("Looking at latest snapshot of orders list");
//      return querySnapshot.documents
//          .map((docSnap) => Order.fromDocument(docSnap))
//          .toList();
//    });
//    return ordersStream;
//  }
//
//  void _decrementResturantToFirestore(Resturant resturant) {
//    resturant.numberOfOrders--;
//    Firestore.instance
//        .collection("Resturants")
//        .document(resturant.id)
//        .updateData(Resturant.toMap(resturant))
//        .then((_) => print("Resturant: ${resturant.name} deleted an order"))
//        .catchError((_) => print(
//            "Resturant: ${resturant.name} failed to decrement order number"));
//  }
//
//  void _incrementResturantToFirestore(Resturant resturant) {
//    resturant.numberOfOrders++;
//    Firestore.instance
//        .collection("Resturants")
//        .document(resturant.id)
//        .updateData(Resturant.toMap(resturant))
//        .then((_) => print("Resturant: ${resturant.name} added an order"))
//        .catchError((_) => print(
//            "Resturant: ${resturant.name} failed to increment order number"));
//  }
//
//  List<Resturant> _getResturantList(Group group) {
//    switch (group.id) {
//      case "0":
//        return _zeroResturantList;
//      case "1":
//        {
//          return _firstResturantList;
//        }
//        ;
//    }
//  }
//}
