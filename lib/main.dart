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
// Algorithm starts
// Item class
class Item {
  final String name;
  final String condition;
  final double price;
  final String description;
  final DateTime dateAdded;

  Item({
    required this.name,
    required this.condition,
    required this.price,
    required this.description,
  }) : dateAdded = DateTime.now();
}

// Optimized Item Database with Binary Search Insertions & Fuzzy Search
class OptimizedItemDatabase {
  final List<Item> _sortedItems = [];

  // Add item in sorted order (faster)
  void addItem(Item item) {
    int index = _binarySearchInsertPosition(item.price);
    _sortedItems.insert(index, item);
  }

  // Binary Search Insert Position (O(log n))
  int _binarySearchInsertPosition(double price) {
    int left = 0, right = _sortedItems.length;
    while (left < right) {
      int mid = (left + right) ~/ 2;
      if (_sortedItems[mid].price < price) {
        left = mid + 1;
      } else {
        right = mid;
      }
    }
    return left; // sorted position
  }

  // Retrieve all items
  List<Item> getAllItems() {
    return _sortedItems;
  }

  // Standard Search for Exact Matches
  List<Item> searchItems(String query) {
    return _sortedItems
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList(); //filter items to list
  }

  // **Fuzzy Search using Levenshtein Distance** (Typo)
  List<Item> fuzzySearch(String query, int maxDistance) {
    List<Item> results = [];
    for (Item item in _sortedItems) {
      int distance = _levenshteinDistance(item.name.toLowerCase(), query.toLowerCase());
      if (distance <= maxDistance) {
        results.add(item); // add to results
      }
    }
    return results;
  }

  // **Levenshtein Distance Algorithm (O(nm))** 2D Array dp
  int _levenshteinDistance(String s1, String s2) {
    List<List<int>> dp = List.generate(s1.length + 1, (_) => List.filled(s2.length + 1, 0));
    for (int i = 0; i <= s1.length; i++) {
      for (int j = 0; j <= s2.length; j++) {
        if (i == 0) {
          dp[i][j] = j;
        } else if (j == 0) {
          dp[i][j] = i;
        } else {
          dp[i][j] = [
            dp[i - 1][j] + 1,  //d
            dp[i][j - 1] + 1,  //i
            dp[i - 1][j - 1] + (s1[i - 1] == s2[j - 1] ? 0 : 1) // Substitution //Hard coded for 1 letter off
          ].reduce((a, b) => a < b ? a : b); //choose which one to use
        }
      }
    }
    // minium number of edits
    return dp[s1.length][s2.length]; 
  }
}

// ** UI Implementation **
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
      searchResults = _database.fuzzySearch(searchQuery, 2); // Max distance = 2
    });
  }

// UI ----Frontend--------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DormDash - Fuzzy Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
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

            // Item Form
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
