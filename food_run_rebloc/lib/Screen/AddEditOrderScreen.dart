import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Model/Order.dart';
import 'package:food_run_rebloc/Model/Resturant.dart';
import 'package:food_run_rebloc/Model/User.dart';

class AddEditOrderScreen extends StatefulWidget {
  final bool isEdit;
  final Order existingOrder;
  final Function(Order, Resturant) onAdd;
  final Function(Order, Resturant) onDelete;
  final Function(Order, Resturant) onEdit;
  final Resturant resturant;
  final User user;
  AddEditOrderScreen(
      {@required this.isEdit,
      this.existingOrder,
      this.onAdd,
      this.onDelete,
      this.onEdit,
      this.resturant,
      this.user});

  @override
  AddEditOrderScreenState createState() {
    return new AddEditOrderScreenState(isEdit, existingOrder);
  }
}

class AddEditOrderScreenState extends State<AddEditOrderScreen> {
  Order _order;
  var _globalKey = GlobalKey<FormState>();

  AddEditOrderScreenState(bool isEdit, Order existingOrder) {
    _order = isEdit ? Order.copyWith(existingOrder) : new Order();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isEdit ? Text("Edit Order") : Text("Add Order"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              if (_globalKey.currentState.validate()) {
                //submit
                _globalKey.currentState.save();
                if (widget.isEdit) {
                  if (_didOrderChange(widget.existingOrder, _order)) {
                    widget.onEdit(_order, widget.resturant);
                  }
                } else {
                  _order.user = widget.user;
                  widget.onAdd(_order, widget.resturant);
                }
                Navigator.pop(context);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              widget.onDelete(_order, widget.resturant);
              Navigator.pop(
                context,
              );
            },
          )
        ],
      ),
      body: Form(
        key: _globalKey,
        child: ListView(
          children: <Widget>[
            TextFormField(
              initialValue: _order.order,
              validator: (order) {
                if (order == null || order == " ") {
                  return "Order can't be empty";
                }
              },
              onSaved: (order) => _order.order = order,
              decoration: InputDecoration(hintText: "What's your order?"),
            ),
            Text("Selected Time: ${_order.timeOfDay.format(context)}"),
            RaisedButton(
              child: Text("Select time"),
              onPressed: () {
                showTimePicker(context: context, initialTime: TimeOfDay.now())
                    .then((timeOfDay) {
                  setState(() {
                    _order.timeOfDay = timeOfDay;
                    print(
                        "timeofday selected is ${_order.timeOfDay.toString()}");
                  });
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _didOrderChange(Order oldOrder, Order newOrder) {
    return !(oldOrder == newOrder);
  }
}
