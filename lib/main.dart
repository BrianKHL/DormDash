import 'package:flutter/material.dart';
import 'admin_page.dart'; // ✅ Import Admin Page

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

// ==================== DATA MODEL ====================

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

// ==================== OPTIMIZED DATABASE ====================

class OptimizedItemDatabase {
  final List<Item> _sortedItems = [];

  // ✅ Add item using Binary Search for sorted insertion (O(log n))
  void addItem(Item item) {
    int index = _binarySearchInsertPosition(item.price);
    _sortedItems.insert(index, item);
  }

  // ✅ Binary Search Insert Position (O(log n))
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

  // ✅ Retrieve all items
  List<Item> getAllItems() {
    return _sortedItems;
  }

  // ✅ Exact Match Search
  List<Item> searchItems(String query) {
    return _sortedItems
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // ✅ Fuzzy Search (Typo Correction using Levenshtein Distance)
  List<Item> fuzzySearch(String query, int maxDistance) {
    List<Item> results = [];
    for (Item item in _sortedItems) {
      int distance = _levenshteinDistance(item.name.toLowerCase(), query.toLowerCase());
      if (distance <= maxDistance) {
        results.add(item);
      }
    }
    return results;
  }

  // ==================== ✅ LEVENSHTEIN DISTANCE ALGORITHM ====================
  int _levenshteinDistance(String s1, String s2) {
    int lenA = s1.length, lenB = s2.length;
    if (lenA == 0) return lenB;
    if (lenB == 0) return lenA;

    List<List<int>> dp = List.generate(lenA + 1, (_) => List.filled(lenB + 1, 0));

    for (int i = 0; i <= lenA; i++) dp[i][0] = i;
    for (int j = 0; j <= lenB; j++) dp[0][j] = j;

    for (int i = 1; i <= lenA; i++) {
      for (int j = 1; j <= lenB; j++) {
        int cost = (s1[i - 1] == s2[j - 1]) ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,  // Deletion
          dp[i][j - 1] + 1,  // Insertion
          dp[i - 1][j - 1] + cost  // Substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    return dp[lenA][lenB];
  }
}

// ==================== UI IMPLEMENTATION ====================

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
      setState(() {}); // ✅ Refresh UI after adding item
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
      appBar: AppBar(
        title: Text('DormDash - Fuzzy Search'),
        actions: [
          // ✅ Admin Page Button
          IconButton(
            icon: Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminPage()), // ✅ Navigate to Admin Page
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ Search Bar
            TextField(
              decoration: InputDecoration(
                labelText: 'Search Item (Typo Tolerant)',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchItems,
                ),
              ),
              onChanged: (value) => searchQuery = value,
            ),
            SizedBox(height: 10),

            // ✅ Display Search Results
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

            // ✅ Divider
            Divider(height: 20, thickness: 2),

            // ✅ Item Form (Add Items)
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
