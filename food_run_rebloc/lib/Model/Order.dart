import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/material/time.dart';
import 'package:food_run_rebloc/Model/User.dart';

class Order {
  String order;
  User user;
  String id;
  String resturantId;
  TimeOfDay timeOfDay;

  Order(
      {this.order, User user, this.id, this.resturantId, TimeOfDay timeOfDay}) {
    this.user = user == null ? new User() : user;
    this.timeOfDay = timeOfDay == null ? TimeOfDay.now() : timeOfDay;
  }

  //returns true if admin or if the sameUser
  bool isEditable(User currentSignInUser) {
    if (this.user == currentSignInUser || (this.user.isAdmin ?? false)) {
      return true;
    }
    return false;
  }

  static Order fromDocument(DocumentSnapshot documentSnap) {
    var something = documentSnap;
    var somethingMap = documentSnap["timeOfDay"];
    int hour = somethingMap["hour"];
    int minute = somethingMap["minute"];
    TimeOfDay timeOfDay = TimeOfDay(hour: hour, minute: minute);
    return new Order(
      id: documentSnap.documentID,
      order: documentSnap["order"],
      user: User.fromMap(documentSnap["user"]),
      resturantId: documentSnap["resturantName"],
      timeOfDay: timeOfDay,
    );
  }

  static Map<String, dynamic> toMap(Order order) {
    return <String, dynamic>{
      "order": order.order,
      "user": User.toMap(order.user),
      "resturantName": order.resturantId,
      "timeOfDay": timeOfDayToMap(order.timeOfDay)
    };
  }

  @override
  bool operator ==(other) {
    if (other is Order) {
      return this.order == other.order &&
          this.user == other.user &&
          this.resturantId == other.resturantId &&
          this.timeOfDay == other.timeOfDay;
    }
    return false;
  }

  static Order copyWith(Order existingOrder) {
    return new Order(
        order: existingOrder.order,
        user: existingOrder.user,
        resturantId: existingOrder.resturantId,
        id: existingOrder.id,
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
}
