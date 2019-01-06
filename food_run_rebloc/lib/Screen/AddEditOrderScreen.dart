import 'package:flutter/material.dart';
import 'package:food_run_rebloc/Model/Order.dart';
import 'package:food_run_rebloc/Model/Resturant.dart';
import 'package:food_run_rebloc/Model/User.dart';
import 'package:food_run_rebloc/Widgets/WillPopForm.dart';

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
  TextEditingController _orderController;
  Order _existingOrder;

  AddEditOrderScreenState(bool isEdit, Order existingOrder) {
    _order = isEdit ? Order.copyWith(existingOrder) : new Order();
    if (isEdit) {
      _orderController = TextEditingController(text: existingOrder.order);
      _existingOrder = existingOrder;
    } else {
      _orderController = TextEditingController();
    }
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
                    _order.userAttributes["userId"] = widget.user.id;
                    widget.onAdd(_order, widget.resturant);
                    sendMessage();
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
        body: WillPopForm(
          child: _buildForm(),
          didDataChange: _didDataChange,
        ));
  }

  bool _didOrderChange(Order oldOrder, Order newOrder) {
    return !(oldOrder == newOrder);
  }

  void sendMessage() {
    //_firebaseMessaging.subscribeToTopic(topic);
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Form(
        key: _globalKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _orderController,
              validator: (order) {
                if (order == null || order == " ") {
                  return "Order can't be empty";
                }
              },
              onSaved: (order) {
                setState(() {
                  _order.order = order;
                });
              },
              decoration: InputDecoration(
                  labelText: "What's your order?",
                  contentPadding: EdgeInsets.all(16.0)),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Selected Time: ${_order.timeOfDay.format(context)}",
              ),
            ),
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

  bool _didDataChange() {
    Order currentFieldsOrder = _getOrderUsingControllers();
    if (widget.isEdit) {
      return !orderFieldsAreEqual(currentFieldsOrder, _existingOrder);
    }
    return !Order.isEmpty(currentFieldsOrder);
  }

  Order _getOrderUsingControllers() {
    return Order(
        order: _orderController.text.toString(), timeOfDay: _order.timeOfDay);
  }

  bool orderFieldsAreEqual(Order currentFieldsOrder, Order order) {
    return currentFieldsOrder.order == order.order &&
        currentFieldsOrder.timeOfDay == order.timeOfDay;
  }
}
