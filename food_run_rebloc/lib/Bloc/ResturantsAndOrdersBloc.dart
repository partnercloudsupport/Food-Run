import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_run_rebloc/Model/Group.dart';
import 'package:food_run_rebloc/Model/Order.dart';
import 'package:food_run_rebloc/Model/Resturant.dart';
import 'package:food_run_rebloc/Model/User.dart';

class ResturantsAndOrdersBloc {
  static final String resturantsCollectionRefrence = "Resturants";
  static final String ordersCollectionRefrence = "Orders";

  Stream<List<Resturant>> get resturants => getResturantsFromFirestore();
  List<Resturant> _resturants;
  List<Order> _orders;
  //Stream<List<Order>> get orders => getOrdersFromFirestore();
  Group group;
  static ResturantsAndOrdersBloc _resturantsAndOrdersBlocInstance;

//  factory ResturantsAndOrdersBloc(Group group) {
//    this.group = group;
//    return _resturantsAndOrdersBlocInstance;
//  }
  factory ResturantsAndOrdersBloc(Group group) {
    if (_resturantsAndOrdersBlocInstance == null) {
      _resturantsAndOrdersBlocInstance =
          ResturantsAndOrdersBloc._internal(group);
    }
    return _resturantsAndOrdersBlocInstance;
  }

  ResturantsAndOrdersBloc._internal(this.group);

  void addResturantToFirestore(Resturant resturant) {
    Firestore.instance
        .collection(resturantsCollectionRefrence)
        .document(resturant.groupId)
        .collection(resturantsCollectionRefrence)
        .add(Resturant.toMap(resturant))
        .then((_) => print("Resturant: ${resturant.name} Added"))
        .catchError(
            (_) => print("Resturant: ${resturant.name} being added failed"));
  }

  void deleteResturantToFirestore(Resturant resturant) {
    Firestore.instance
        .collection(resturantsCollectionRefrence)
        .document(group.id)
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
        .document(group.id)
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
        .document(group.id)
        .collection(resturantsCollectionRefrence)
        .snapshots()
        .asyncMap((snapshot) {
      print("Got resturants for ${group.name}");
      _resturants = snapshot.documents.map((docSnapshot) {
        return Resturant.fromDocument(docSnapshot);
      }).toList();
      return _resturants;
    });
    return resturantStream;
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //Orders

  Future<Order> addOrderToFirestore(
      Order orderToAdd, Resturant resturant, User signedInUser) async {
    orderToAdd.resturantId = resturant.id;
    orderToAdd.userAttributes = {
      "userId": signedInUser.id,
      "userName": signedInUser.name
    };
    CollectionReference collectionReference = Firestore.instance
        .collection(ordersCollectionRefrence)
        .document(resturant.id)
        .collection(ordersCollectionRefrence);
    DocumentReference reference =
        await collectionReference.add(Order.toMap(orderToAdd)).catchError((_) {
      print("Order being added failed");
      return null;
    });
    print("Order Added");
    _incrementResturantToFirestore(resturant);
    orderToAdd.id = reference.documentID;
    return orderToAdd;
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
      return null;
    }).catchError((_) {
      print("Order failed to delete");
      return null;
    });
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
      _orders = querySnapshot.documents
          .map((docSnap) => Order.fromDocument(docSnap))
          .toList();
      return _orders;
    });
    return ordersStream;
  }

  void _decrementResturantToFirestore(Resturant resturant) {
    resturant.numberOfOrders--;
    Firestore.instance
        .collection("Resturants")
        .document(group.id)
        .collection(resturantsCollectionRefrence)
        .document(resturant.id)
        .updateData({"numberOfOrders": resturant.numberOfOrders})
        .then((_) => print("Resturant: ${resturant.name} deleted an order"))
        .catchError((_) => print(
            "Resturant: ${resturant.name} failed to decrement order number"));
  }

  void _incrementResturantToFirestore(Resturant resturant) {
    resturant.numberOfOrders++;
    Firestore.instance
        .collection(resturantsCollectionRefrence)
        .document(group.id)
        .collection(resturantsCollectionRefrence)
        .document(resturant.id)
        .updateData({"numberOfOrders": resturant.numberOfOrders})
        .then((_) => print("Resturant: ${resturant.name} added an order"))
        .catchError((_) => print(
            "Resturant: ${resturant.name} failed to increment order number"));
  }

  void updateResturantsVolunteers(Resturant resturant, User signedInUser) {
    Firestore.instance
        .collection(resturantsCollectionRefrence)
        .document(resturant.groupId);
  }

  void updateOrdersForGroup(Resturant resturant, User signedInUser) {
    List<Order> changedOrders = _orders.where((order) {
      if (order.userAttributes["userId"] == signedInUser.id) {
        return true;
      }
      return false;
    }).toList();

    WriteBatch writeBatch = Firestore.instance.batch();

    //Go to each changed order id and swap user
    changedOrders.forEach((order) {
      DocumentReference documentReference = Firestore.instance
          .collection(ordersCollectionRefrence)
          .document(resturant.id)
          .collection(ordersCollectionRefrence)
          .document(order.id);
      order.userAttributes["userId"] = signedInUser.id;
      writeBatch.updateData(documentReference, Order.toMap(order));
    });

    writeBatch.commit().then((_) {
      print("Writebatch successfull updated volunteer user");
    }).catchError((error) => print(error));
  }

  Future deleteResturantsAndOrders(Group group) async {
    group.resturantIds.forEach((resturantId) async {
      WriteBatch writeBatch = Firestore.instance.batch();
      QuerySnapshot querySnapshot = await Firestore.instance
          .collection(ordersCollectionRefrence)
          .document(resturantId)
          .collection(ordersCollectionRefrence)
          .getDocuments();
      querySnapshot.documents.forEach((documentSnap) {
        writeBatch.delete(documentSnap.reference);
      });

      writeBatch.commit().then((_) {
        print("Deleted orders");
      }).catchError((error) => print(error));

      Firestore.instance
          .collection(ordersCollectionRefrence)
          .document(resturantId)
          .delete()
          .then((_) {
        print("Deleted order head");
      }).catchError((error) => print(error));
    });

    WriteBatch resturantBatch = Firestore.instance.batch();
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection(resturantsCollectionRefrence)
        .document(group.id)
        .collection(resturantsCollectionRefrence)
        .getDocuments();

    querySnapshot.documents.forEach((docSnap) {
      resturantBatch.delete(docSnap.reference);
    });

    resturantBatch.commit().then((_) {
      print("Deletedresturants");
    }).catchError((error) => print(error));

    Firestore.instance
        .collection(resturantsCollectionRefrence)
        .document(group.id)
        .delete()
        .then((_) {
      print("Deleted resturant head");
    }).catchError((error) => print(error));
  }

  Future ADDTESTORDERSANDRESTURANTS(Group group, User user) async {
    Resturant resturant = Resturant(
      name: "MCDONALD'S",
      numberOfOrders: 1,
    );
    DocumentReference reference = await Firestore.instance
        .collection(resturantsCollectionRefrence)
        .document(group.id)
        .collection(resturantsCollectionRefrence)
        .add(Resturant.toMap(resturant));
    print("RESTURANTS ID IS ${reference.documentID}");
    Order order = Order(order: "Burger", resturantId: reference.documentID);
    Firestore.instance
        .collection(ordersCollectionRefrence)
        .document(reference.documentID)
        .collection(ordersCollectionRefrence)
        .add(Order.toMap(order));

    group.resturantIds.add(reference.documentID);
  }

  bool userHasOrder({User user, Resturant resturant}) {
    List<Order> usersOrders = _orders
        .where((order) => order.userAttributes["userId"] == user.id)
        .toList();
    if (usersOrders.length > 0) {
      return true;
    }
    return false;
  }

  static void updateUsernameOnOrders(User user) {
    //get all resturants
    //get all orders with name user.name
    user.activeResturants.forEach((resturantId) async {
      QuerySnapshot querySnapshot = await Firestore.instance
          .collection(ordersCollectionRefrence)
          .document(resturantId)
          .collection(ordersCollectionRefrence)
          .where("userAttributes", isGreaterThanOrEqualTo: {
        "userId": user.id,
        "userName": ""
      }).getDocuments();
      List<Order> usersOrders = querySnapshot.documents
          .map((docSnap) => Order.fromDocument(docSnap))
          .toList();
      usersOrders.forEach((order) {
        Firestore.instance
            .collection(ordersCollectionRefrence)
            .document(resturantId)
            .collection(ordersCollectionRefrence)
            .document(order.id)
            .updateData({
          "userAttributes": {"userId": user.id, "userName": user.name}
        }).then((_) {
          print("updated username in orders");
        });
      });
    });
  }
}
