import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_run_rebloc/FoodRunBlocInterface.dart';
import 'package:food_run_rebloc/Model/Order.dart';
import 'package:food_run_rebloc/Model/Resturant.dart';

class ResturantsAndOrdersBloc {
  static final String resturantsCollectionRefrence = "Resturants";
  Stream<List<Resturant>> get resturants => getResturantsFromFirestore();
  static final String ordersCollectionRefrence = "Orders";
  //Stream<List<Order>> get orders => getOrdersFromFirestore();

  void addResturantToFirestore(Resturant resturant) {
    Firestore.instance
        .collection(resturantsCollectionRefrence)
        .add(Resturant.toMap(resturant))
        .then((_) => print("Resturant: ${resturant.name} Added"))
        .catchError(
            (_) => print("Resturant: ${resturant.name} being added failed"));
  }

  void deleteResturantToFirestore(Resturant resturant) {
    Firestore.instance
        .collection(resturantsCollectionRefrence)
        .document(resturant.id)
        .delete()
        .then((_) => print("Resturant: ${resturant.name} Deleted"))
        .catchError(
            (_) => print("Resturant: ${resturant.name} being deleted failed"));
  }

  void updateResturantToFirestore(Resturant resturant) {
    Firestore.instance
        .collection(resturantsCollectionRefrence)
        .document(resturant.id)
        .updateData(Resturant.toMap(resturant))
        .then((_) => print("Resturant: ${resturant.name} updated"))
        .catchError(
            (_) => print("Resturant: ${resturant.name} being updated failed"));
  }

  //We want a Stream<List<Resturant>> so we need to convert
  //AsyncSnapshot -> List<Resturant>
  Stream<List<Resturant>> getResturantsFromFirestore() {
    Stream<List<Resturant>> resturantStream = Firestore.instance
        .collection(resturantsCollectionRefrence)
        .snapshots()
        .asyncMap((snapshot) => snapshot.documents.map((docSnapshot) {
              return Resturant.fromDocument(docSnapshot);
            }).toList());
    return resturantStream;
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //Orders

  Future<Null> addOrderToFirestore(
      Order orderToAdd, Resturant resturant) async {
    CollectionReference collectionReference = Firestore.instance
        .collection(ordersCollectionRefrence)
        .document(resturant.id)
        .collection(ordersCollectionRefrence);
    await collectionReference.add(Order.toMap(orderToAdd)).then((_) {
      print("Order Added");
      _incrementResturantToFirestore(resturant);
    }).catchError((_) => print("Order being added failed"));
  }

  Future<Null> deleteOrderToFirestore(
      Order orderToDelete, Resturant resturant) {
    Firestore.instance
        .collection(ordersCollectionRefrence)
        .document(resturant.id)
        .collection(ordersCollectionRefrence)
        .document(orderToDelete.id)
        .delete()
        .then((_) {
      print("${orderToDelete.order} by ADD_USER_HERE deleted");
      _decrementResturantToFirestore(resturant);
    }).catchError((_) => print("Order failed to delete"));
  }

  void updateOrderToFirestore(Order orderToEdit, Resturant resturant) {
    Firestore.instance
        .collection(ordersCollectionRefrence)
        .document(resturant.id)
        .collection(ordersCollectionRefrence)
        .document(orderToEdit.id)
        .updateData(Order.toMap(orderToEdit))
        .then((_) => print("${orderToEdit.order} by ADD_USER_HERE edited"))
        .catchError((_) => print("Order failed to edit"));
  }
  //What happens if you just map the async data???

  //Need to map async since we only want to map once we recieve the data

  Stream<List<Order>> getOrdersFromFirestore(Resturant resturant) {
    Stream<List<Order>> ordersStream = Firestore.instance
        .collection(ordersCollectionRefrence)
        .document(resturant.id)
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

  void _decrementResturantToFirestore(Resturant resturant) {
    resturant.numberOfOrders--;
    Firestore.instance
        .collection("Resturants")
        .document(resturant.id)
        .updateData(Resturant.toMap(resturant))
        .then((_) => print("Resturant: ${resturant.name} deleted an order"))
        .catchError((_) => print(
            "Resturant: ${resturant.name} failed to decrement order number"));
  }

  void _incrementResturantToFirestore(Resturant resturant) {
    resturant.numberOfOrders++;
    Firestore.instance
        .collection("Resturants")
        .document(resturant.id)
        .updateData(Resturant.toMap(resturant))
        .then((_) => print("Resturant: ${resturant.name} added an order"))
        .catchError((_) => print(
            "Resturant: ${resturant.name} failed to increment order number"));
  }
}
