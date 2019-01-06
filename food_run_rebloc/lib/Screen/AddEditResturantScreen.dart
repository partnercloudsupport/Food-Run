import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_run_rebloc/Model/Resturant.dart';
import 'package:url_launcher/url_launcher.dart';

class AddEditResturantScreen extends StatefulWidget {
  static const MethodChannel platform = const MethodChannel('foodRun');
  final String groupDocId;
  final bool isEdit;
//  final GlobalKey<ChoiceTextFieldFormsState> _choiceFormsKey =
//      GlobalKey<ChoiceTextFieldFormsState>();
  final Resturant existingResturant;
  final Function onAdd;
  final Function onEdit;
  final Function onDelete;

  AddEditResturantScreen(
      {@required this.isEdit,
      this.onAdd,
      this.onEdit,
      this.onDelete,
      this.existingResturant,
      this.groupDocId});

  @override
  AddEditResturantScreenState createState() {
    return new AddEditResturantScreenState(isEdit, existingResturant);
  }

  Future<Null> _dialNumber(String phoneNumber) async {
    //method is call
    try {
      await platform.invokeMethod('sendNumberToPhone', <String, dynamic>{
        "phone_number": phoneNumber,
      });
    } on PlatformException catch (e) {
      print("Failed to dial: '${e.message}'.");
    }
  }

  Future<Null> _goToMapsAddress(String address) async {
    try {
      await platform.invokeMethod('sendToMaps', <String, dynamic>{
        "address": address,
      });
    } on PlatformException catch (e) {
      print("Failed to go to address: '${e.message}'.");
    }
  }

  void _goToWebsite(String webstite) async {
    //https:<URL>, e.g. http://flutter.io
    String url = "https:" + webstite;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class AddEditResturantScreenState extends State<AddEditResturantScreen> {
  List<Resturant> resturants = [];
//  final GlobalKey<ChoiceTextFieldFormsState> _resturantFormsKey =
//      GlobalKey<ChoiceTextFieldFormsState>();
  final GlobalKey<FormState> _resturantFormsKey = new GlobalKey<FormState>();
  Resturant _resturant;

  TextEditingController _nameController;
  TextEditingController _telephoneController;
  TextEditingController _addressController;
  TextEditingController _websiteController;

  AddEditResturantScreenState(bool isEdit, Resturant existingResturant) {
    if (isEdit) {
      _nameController = new TextEditingController(text: existingResturant.name);
      _telephoneController =
          new TextEditingController(text: existingResturant.telephoneNumber);
      _addressController =
          new TextEditingController(text: existingResturant.address);
      _websiteController =
          new TextEditingController(text: existingResturant.website);
    } else {
      _nameController = new TextEditingController();
      _telephoneController = new TextEditingController();
      _addressController = new TextEditingController();
      _websiteController = new TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    _resturant = widget.isEdit
        ? Resturant.copyWith(widget.existingResturant)
        : new Resturant();
    return new Scaffold(
      appBar: new AppBar(
        title: widget.isEdit
            ? new Text("Edit Resturant")
            : new Text("Add Resturant"),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.save),
              onPressed: () {
                if (_resturantFormsKey.currentState.validate()) {
//                  Resturant newEditedChoice = new Resturant(
//                    id: widget.groupDocId,
//                    numberOfOrders: 0,
//                    name:
//                        _resturantFormsKey.currentState.nameKey.currentState.value,
//                    telephoneNumber: _resturantFormsKey
//                        .currentState.numberKey.currentState.value,
//                    address: _resturantFormsKey
//                        .currentState.addressKey.currentState.value,
//                    website: _resturantFormsKey
//                        .currentState.websiteKey.currentState.value,
//                  );
                  _resturantFormsKey.currentState.save();
                  if (widget.isEdit) {
                    if (_didResturantChange(
                        widget.existingResturant, _resturant))
                      widget.onEdit(_resturant);
                  } else {
                    widget.onAdd(_resturant);
                  }
                  Navigator.pop(context);
                }
              }),
          widget.isEdit
              ? new IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    if (widget.isEdit) {
                      widget.onDelete(widget.existingResturant);
                    }
                    Navigator.pop(context);
                  })
              : Container(),
        ],
      ),
      body: SingleChildScrollView(
        child: new Column(
          children: <Widget>[_buildResturantForms(), _buildNavigationRow()],
        ),
      ),
    );
  }

  Row _buildNavigationRow() {
    return new Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        new IconButton(
          icon: new Icon(Icons.map),
          onPressed: () {
            if (_isTextValid(_addressController.text.toString())) {
              widget._goToMapsAddress(_addressController.text.toString());
            }
          },
          iconSize: 48.0,
        ),
        new IconButton(
          icon: new Icon(Icons.computer),
          onPressed: () {
            if (_isTextValid(_websiteController.text.toString())) {
              widget._goToWebsite(_websiteController.text.toString());
            }
          },
          iconSize: 48.0,
        ),
        new IconButton(
          icon: new Icon(Icons.phone),
          onPressed: () {
            if (_isTextValid(_telephoneController.text.toString())) {
              widget._dialNumber(_telephoneController.text.toString());
            }
          },
          iconSize: 48.0,
        ),
      ],
    );
  }

  Widget _buildResturantForms() {
    return SingleChildScrollView(
      child: Form(
        key: _resturantFormsKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              validator: (input) => _generalValidator(input),
              onSaved: (name) {
                _resturant.name = name;
              },
              decoration: InputDecoration(
                  labelText: "Resturant Name",
                  contentPadding: EdgeInsets.all(16.0)),
            ),
            TextFormField(
              controller: _telephoneController,
              onSaved: (telephoneNumber) =>
                  _resturant.telephoneNumber = telephoneNumber,
              decoration: InputDecoration(
                  labelText: "Telephone Number",
                  contentPadding: EdgeInsets.all(16.0)),
            ),
            TextFormField(
              controller: _addressController,
              onSaved: (address) => _resturant.address = address,
              decoration: InputDecoration(
                  labelText: "Address", contentPadding: EdgeInsets.all(16.0)),
            ),
            TextFormField(
              controller: _websiteController,
              onSaved: (website) => _resturant.website = website,
              decoration: InputDecoration(
                  labelText: "Website", contentPadding: EdgeInsets.all(16.0)),
            ),
          ],
        ),
      ),
    );
  }

  String _generalValidator(String input) {
    if (input == null || input.isEmpty) {
      return "Can't be empty";
    }
    return null;
  }

  bool _isTextValid(String text) {
    return text != null && text != "";
  }

  bool _didResturantChange(Resturant existingResturant, Resturant resturant) {
    return existingResturant != resturant;
  }

//  _buildMenuButton(){
//    new RaisedButton(
//        child: new Text("Menu"),
//        onPressed: () {
//          if (widget.resturant == null) {
//            print("widget choice is null");
//          }
//          MaterialPageRoute route;
//          if (widget.resturant.menuCatagories != [] ||
//              widget.resturant.menuCatagories.length != 0) {
//            print("Going to editmenu");
//            route = new MaterialPageRoute(
//                builder: (context) => new EditMenu(
//                  resturant: widget.resturant,
//                  resturants: widget.resturant.menuCatagories,
//                ));
//          } else {
////                    route = new MaterialPageRoute(
////                        builder: (context) => new AddMenu(
////                              choice: widget.choice,
////                              catagories: widget.choice.menuCatagories,
////                            ));
//          }
//          Navigator.of(context).push(route).then((catagories) {
//            if (catagories is List<ResturantCatagory>) {
//              return this.resturants = catagories;
//            }
//          });
//        }),
//  }
}
