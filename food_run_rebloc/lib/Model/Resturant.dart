import 'package:cloud_firestore/cloud_firestore.dart';

class Resturant {
  String id;
  String name;
  int numberOfOrders = 0;
  String telephoneNumber;
  String address;
  String website;

  Resturant(
      {this.id,
      this.name,
      this.numberOfOrders: 0,
      this.telephoneNumber,
      this.address,
      this.website});

  static Map<String, dynamic> toMap(Resturant resturant) {
    return <String, dynamic>{
      "name": resturant.name,
      "numberOfOrders": resturant.numberOfOrders,
      "telephoneNumber": resturant.telephoneNumber,
      "address": resturant.address,
      "website": resturant.website
    };
  }

  static Resturant fromDocument(DocumentSnapshot docSnapshot) {
    return new Resturant(
      id: docSnapshot.documentID,
      name: docSnapshot["name"],
      numberOfOrders: docSnapshot["numberOfOrders"],
      telephoneNumber: docSnapshot["telephoneNumber"],
      address: docSnapshot["address"],
      website: docSnapshot["website"],
    );
  }

  static Resturant copyWith(Resturant resturant) {
    return Resturant(
        id: resturant.id,
        name: resturant.name,
        numberOfOrders: resturant.numberOfOrders,
        telephoneNumber: resturant.telephoneNumber,
        address: resturant.address,
        website: resturant.website);
  }

  @override
  bool operator ==(other) {
    if (other is Resturant) {
      return this.id == other.id &&
          this.name == other.name &&
          this.numberOfOrders == other.numberOfOrders &&
          this.telephoneNumber == other.telephoneNumber &&
          this.website == other.website;
    }
    return false;
  }
}
