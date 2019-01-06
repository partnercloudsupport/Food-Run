import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/material/time.dart';
import 'package:food_run_rebloc/Model/Group.dart';
import 'package:food_run_rebloc/Model/User.dart';

class Order {
  String order;
  //User user;
  String id;
  Map<String, String> userAttributes;
  String resturantId;
  TimeOfDay timeOfDay;

  Order(
      {this.order,
      //User user,
      this.id,
      this.resturantId,
      this.userAttributes,
      TimeOfDay timeOfDay}) {
    //this.user = user == null ? new User() : user;
    this.timeOfDay = timeOfDay == null ? TimeOfDay.now() : timeOfDay;
    if (userAttributes == null) {
      userAttributes = {
        "userId": null,
        "userName": "",
      };
    }
  }

  //returns true if admin or if the sameUser
  bool isEditable(User currentSignInUser, Group group) {
    if (this.userAttributes["userId"] == currentSignInUser.id) {
      return true;
    }
    currentSignInUser.adminForGroups.forEach((groupId) {
      if (group.id == groupId) {
        return true;
      }
    });
    return false;
  }

  static Order fromDocument(DocumentSnapshot documentSnap) {
    var somethingMap = documentSnap["timeOfDay"];
    int hour = somethingMap["hour"];
    int minute = somethingMap["minute"];
    TimeOfDay timeOfDay = TimeOfDay(hour: hour, minute: minute);
    return new Order(
      id: documentSnap.documentID,
      order: documentSnap["order"],
      //user: User.fromMap(documentSnap["user"]),
      userAttributes: userAttributesFromMap(documentSnap["userAttributes"]),
      resturantId: documentSnap["resturantName"],
      timeOfDay: timeOfDay,
    );
  }

  static Map<String, dynamic> toMap(Order order) {
    return <String, dynamic>{
      "order": order.order,
      //"user": User.toMap(order.user),
      "userAttributes": order.userAttributes,
      "resturantName": order.resturantId,
      "timeOfDay": timeOfDayToMap(order.timeOfDay)
    };
  }

  @override
  bool operator ==(other) {
    if (other is Order) {
      return this.order == other.order &&
          //this.user == other.user &&
          this.resturantId == other.resturantId &&
          this.timeOfDay == other.timeOfDay;
    }
    return false;
  }

  static Order copyWith(Order existingOrder) {
    return new Order(
        order: existingOrder.order,
        //user: existingOrder.user,
        resturantId: existingOrder.resturantId,
        id: existingOrder.id,
        userAttributes: existingOrder.userAttributes,
        timeOfDay: existingOrder.timeOfDay);
  }

  static Map<String, dynamic> timeOfDayToMap(TimeOfDay timeOfDay) {
    return <String, dynamic>{
      "hour": timeOfDay.hour,
      "minute": timeOfDay.minute
    };
  }

  //Not sure why using this method to get TimeOfDay would cause an error
  static TimeOfDay mapToTimeOfDay(Map<String, dynamic> map) {
    return TimeOfDay(hour: map["hour"], minute: map["minute"]);
  }

  static canRemove(Order order, User signedInUser, Group group) {
    return signedInUser.isAdmin(group) ||
        group.canRemoveOrders ||
        order.userAttributes["userId"] == signedInUser.id;
  }

  static bool canAddEdit(Order order, User signedInUser, Group group) {
    return signedInUser.isAdmin(group) ||
        group.canAddOrders ||
        order.userAttributes["userId"] == signedInUser.id;
  }

  static Map<String, String> userAttributesFromMap(Map documentSnap) {
    return <String, String>{
      "userId": documentSnap["userId"],
      "userName": documentSnap["userName"]
    };
  }

  //empty if user didn't input
  static bool isEmpty(Order order) {
    return order.order == "";
  }
}
