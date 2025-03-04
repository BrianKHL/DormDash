import 'package:flutter/material.dart';
import '../utils/optimized_item_database.dart';  // ✅ Import Optimized Database

class SellGiveAwayScreen extends StatefulWidget {
  const SellGiveAwayScreen({super.key});

  @override
  _SellGiveAwayScreenState createState() => _SellGiveAwayScreenState();
}

class _SellGiveAwayScreenState extends State<SellGiveAwayScreen> {
  final _formKey = GlobalKey<FormState>();
  final OptimizedItemDatabase _database = OptimizedItemDatabase();

  String itemName = '';
  String itemCondition = '';
  double itemPrice = 0.0;
  String itemDescription = '';
  String searchQuery = '';
  List<Item> searchResults = [];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Item newItem = Item(
        name: itemName,
        condition: itemCondition,
        price: itemPrice,
        description: itemDescription,
      );
      _database.addItem(newItem);
      _formKey.currentState!.reset();
      setState(() {}); // Update UI
    }
  }

  void _searchItems() {
    setState(() {
      searchResults = _database.fuzzySearch(searchQuery, 2); // ✅ Max distance = 2 for typo tolerance
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DormDash - Fuzzy Search & 2-3 Tree')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔍 Fuzzy Search Bar
            TextField(
              decoration: InputDecoration(
                labelText: 'Search Item (with typo tolerance)',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchItems,
                ),
              ),
              onChanged: (value) => searchQuery = value,
            ),
            SizedBox(height: 10),

            // Display Search Results
            if (searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final item = searchResults[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text("Condition: ${item.condition} | Price: \$${item.price}"),
                    );
                  },
                ),
              ),

            // Divider
            Divider(height: 20, thickness: 2),

            // 🧩 2-3 Tree Insertion Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Item Name'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter the item name' : null,
                    onSaved: (value) => itemName = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Condition'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please specify the item condition' : null,
                    onSaved: (value) => itemCondition = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Price (if selling)'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => itemPrice = double.tryParse(value!) ?? 0.0,
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    onSaved: (value) => itemDescription = value!,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Add Item'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
