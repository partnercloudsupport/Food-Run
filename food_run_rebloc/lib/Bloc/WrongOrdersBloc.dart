import 'package:food_run_rebloc/Model/Order.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

/*
Added the Future<Null> so that we can use then since we only want to increment or decrement
if add or delete was successful
 */
class OrdersBloc {
  static final String ordersCollectionRefrence = "Orders";
  Stream<List<Order>> get orders => getOrdersFromFirestore();

  OrdersBloc() {
//    _ordersReplaySubject = new ReplaySubject<List<Order>>();
//    _getOrders().then((_) {
//      _ordersReplaySubject.add(_orders);
//    });
  }

//  Using same method watching Boring Flutter Show
  // We dont need to control the stream since firestore takes care of theat
  // They needed middleman and used this approach
//  Future<Null> _getOrders() async {
//    CollectionReference collectionReference =
//        Firestore.instance.collection(OrdersCollectionRefrence);
//    await collectionReference.getDocuments().then((ordersSnap) {
//      _orders = ordersSnap.documents.map((docSnap) {
//        return Order.fromDocument(docSnap);
//      }).toList();
//    });
//  }

  Future<Null> addOrderToFirestore(Order orderToAdd) async {
    CollectionReference collectionReference =
        Firestore.instance.collection(ordersCollectionRefrence);
    await collectionReference
        .add(Order.toMap(orderToAdd))
        .then((_) => print("Order Added"))
        .catchError((_) => print("Order being added failed"));
  }

  Future<Null> deleteOrderToFirestore(Order orderToDelete) {
    Firestore.instance
        .collection(ordersCollectionRefrence)
        .document(orderToDelete.id)
        .delete()
        .then((_) => print("${orderToDelete.order} by ADD_USER_HERE deleted"))
        .catchError((_) => print("Order failed to delete"));
  }

  void updateOrderToFirestore(Order orderToEdit) {
    Firestore.instance
        .collection(ordersCollectionRefrence)
        .document(orderToEdit.id)
        .updateData(Order.toMap(orderToEdit))
        .then((_) => print("${orderToEdit.order} by ADD_USER_HERE edited"))
        .catchError((_) => print("Order failed to edit"));
  }
  //What happens if you just map the async data???

  //Need to map async since we only want to map once we recieve the data

  Stream<List<Order>> getOrdersFromFirestore() {
    Stream<List<Order>> ordersStream = Firestore.instance
        .collection(ordersCollectionRefrence)
        .snapshots()
        .asyncMap((querySnapshot) {
      print("Looking at latest snapshot of orders list");
      return querySnapshot.documents
          .map((docSnap) => Order.fromDocument(docSnap))
          .toList();
    });
    return ordersStream;
  }
}
