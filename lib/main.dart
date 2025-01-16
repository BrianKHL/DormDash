import 'package:flutter/material.dart';

void main() {
  runApp(DormDashApp());
}

class DormDashApp extends StatelessWidget {
  const DormDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DormDash',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SellGiveAwayScreen(),
    );
  }
}

class SellGiveAwayScreen extends StatefulWidget {
  const SellGiveAwayScreen({super.key});

  @override
  _SellGiveAwayScreenState createState() => _SellGiveAwayScreenState();
}

class _SellGiveAwayScreenState extends State<SellGiveAwayScreen> {
  final _formKey = GlobalKey<FormState>();
  String itemName = '';
  String itemCondition = '';
  double? itemPrice;
  String? itemDescription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sell or Give Away'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Item Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item name';
                  }
                  return null;
                },
                onSaved: (value) => itemName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Condition'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please specify the item condition';
                  }
                  return null;
                },
                onSaved: (value) => itemCondition = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price (if selling)'),
                keyboardType: TextInputType.number,
                onSaved: (value) =>
                    itemPrice = value != null ? double.tryParse(value) : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => itemDescription = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    print('Item Name: $itemName');
                    print('Condition: $itemCondition');
                    print('Price: $itemPrice');
                    print('Description: $itemDescription');
                    // Add functionality to save or upload item details
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
