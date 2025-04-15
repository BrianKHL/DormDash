import 'package:flutter/material.dart';

// Represents a lost or found item with an ID and description.
class Item {
  final String id;
  final String description;

  Item(this.id, this.description);
}

/// concept of hungarian algorithm
/// 
///    F1 F2
/// L1 4   9
/// L2 8   3
/// 
///    F1 F2
/// L1 0   5
/// L2 5   0
/// 
/// cost matrix = 4 + 3 = 7


// Hungarian Algorithm to match lost items to found items based on a cost matrix.
class HungarianAlgorithm {
  static List<int> findMatching(List<List<double>> costMatrix) {
    if (costMatrix.isEmpty || costMatrix[0].isEmpty) {
      print("⚠️ No items to match - cost matrix is empty.");
      return [];
    }

    int rows = costMatrix.length;
    int cols = costMatrix[0].length;
    int n = rows < cols ? rows : cols; // square matrix 

    //cost matrix for debugging
    print("\n📊 Initial Cost Matrix:");
    for (int i = 0; i < rows; i++) {
      print("L${i + 1} -> ${costMatrix[i]}");
    }

    List<double> u = List.filled(n + 1, 0.0); // potentials values
    List<double> v = List.filled(n + 1, 0.0);
    List<int> match = List.filled(n + 1, 0);
    List<int> way = List.filled(n + 1, 0); //backtracking array
    List<int> result = List.filled(rows, -1);

    //init
    for (int i = 1; i <= n; i++) {
      match[0] = i; 
      int j0 = 0; //current column
      List<double> minCost = List.filled(n + 1, double.infinity);
      List<bool> used = List.filled(n + 1, false);
      
      //matching lost item L1
      print("\n🔍 Matching lost item L$i:");
      do {
        used[j0] = true;
        int i0 = match[j0];
        double delta = double.infinity;
        int j1 = -1; //found item
        
        //all possible matches
        for (int j = 1; j <= n && j <= cols; j++) {
          if (!used[j]) {
            double curCost = costMatrix[i0 - 1][j - 1] - u[i0] - v[j]; //reduce cost (orginal)
            if (curCost < minCost[j]) {
              minCost[j] = curCost;
              way[j] = j0;
            }
            if (minCost[j] < delta) { // overall cost
              delta = minCost[j];
              j1 = j;
            }
          }
        }
        
        //upate dul variables
        for (int j = 0; j <= n && j <= cols; j++) {
          if (used[j]) {
            u[match[j]] += delta;
            v[j] -= delta;
          } else {
            minCost[j] -= delta;
          }
        }
        j0 = j1; // move to the next best match
        print("  ↪️ Updating potentials and looking for new minimal match...");
      } while (j0 != -1 && match[j0] != 0);

      do {
        int nextJ = way[j0];
        match[j0] = match[nextJ];
        j0 = nextJ;
      } while (j0 != 0);
    }
    //backtracking unitl reach the starting column

    print("\n✅ Match array after processing: $match");
    print("📎 Final matches:");
    for (int j = 1; j <= n && j <= cols; j++) {
      if (match[j] != 0) {
        result[match[j] - 1] = j - 1;
        print("  L${match[j]} ➜ F$j");
      }
    }

    double totalCost = 0;
    for (int i = 0; i < result.length; i++) {
      if (result[i] != -1) {
        totalCost += costMatrix[i][result[i]];
      }
    }
    print("🧮 Total matching cost: $totalCost");

    return result;
  }
}


// Lost and Found Screen
class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key});

  @override
  _LostFoundScreenState createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen> {
  List<Item> lostItems = [
    // Item("L1", "blue jacket"),
    // Item("L2", "silver ring"),
  ];
  List<Item> foundItems = [
    // Item("F1", "blue coat"),
    // Item("F2", "silver band"),
  ];

  final _lostController = TextEditingController();
  final _foundController = TextEditingController();
  int _lostIdCounter = 3;
  int _foundIdCounter = 3;

  // Calculate Levenshtein distance between two strings.
  int _levenshteinDistance(String s1, String s2) {
    List<List<int>> dp = List.generate(
      s1.length + 1,
      (i) => List.filled(s2.length + 1, 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      dp[i][0] = i; // Cost of deleting all chars from s1.
    }
    for (int j = 0; j <= s2.length; j++) {
      dp[0][j] = j; // Cost of inserting all chars from s2.
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        if (s1[i - 1] == s2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1]; // No cost if characters match.
        } else {
          dp[i][j] = 1 +
              [
                dp[i - 1][j], // Deletion.
                dp[i][j - 1], // Insertion.
                dp[i - 1][j - 1], // Substitution.
              ].reduce((a, b) => a < b ? a : b);
        }
      }
    }
    return dp[s1.length][s2.length];
  }

  List<String> getMatches() {
    if (lostItems.isEmpty || foundItems.isEmpty) {
      return ["No items to match"];
    }

    int rows = lostItems.length;
    int cols = foundItems.length;

    // Use Levenshtein distance as the cost metric.
    List<List<double>> costMatrix = List.generate(
      rows,
      (i) => List.generate(
        cols,
        (j) => _levenshteinDistance(lostItems[i].description, foundItems[j].description).toDouble(),
      ),
    );
    print("\nCost Matrix (Levenshtein Distance):");
    for (int i = 0; i < rows; i++) {
      print("  ${lostItems[i].description}: ${costMatrix[i]}");
    }

    List<int> matches = HungarianAlgorithm.findMatching(costMatrix);
    print("Matches array from algorithm: $matches");

    List<String> result = [];
    for (int i = 0; i < matches.length && i < rows; i++) {
      if (matches[i] != -1 && matches[i] < cols) {
        result.add("${lostItems[i].description} matched with ${foundItems[matches[i]].description}");
        print("UI match: ${lostItems[i].description} -> ${foundItems[matches[i]].description}");
      }
    }
    return result.isEmpty ? ["No matches found"] : result;
  }

  void _addLostItem() {
    if (_lostController.text.isNotEmpty) {
      setState(() {
        lostItems.add(Item("L$_lostIdCounter", _lostController.text));
        _lostIdCounter++;
        print("Added lost item: L${_lostIdCounter - 1} - ${_lostController.text}");
        _lostController.clear();
      });
    }
  }

  void _addFoundItem() {
    if (_foundController.text.isNotEmpty) {
      setState(() {
        foundItems.add(Item("F$_foundIdCounter", _foundController.text));
        _foundIdCounter++;
        print("Added found item: F${_foundIdCounter - 1} - ${_foundController.text}");
        _foundController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> matches = getMatches();
    return Scaffold(
      appBar: AppBar(title: Text("Lost & Found")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _lostController,
              decoration: InputDecoration(labelText: "Add Lost Item"),
            ),
            ElevatedButton(
              onPressed: _addLostItem,
              child: Text("Add Lost Item"),
            ),
            TextField(
              controller: _foundController,
              decoration: InputDecoration(labelText: "Add Found Item"),
            ),
            ElevatedButton(
              onPressed: _addFoundItem,
              child: Text("Add Found Item"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(matches[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}