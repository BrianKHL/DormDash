import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _word1Controller = TextEditingController();
  final TextEditingController _word2Controller = TextEditingController();
  String _result = "";

  void _calculateLevenshtein() {
    String word1 = _word1Controller.text.trim();
    String word2 = _word2Controller.text.trim();

    if (word1.isEmpty || word2.isEmpty) {
      setState(() {
        _result = "Please enter both words.";
      });
      return;
    }

    int distance = levenshteinDistance(word1, word2);
    setState(() {
      _result = "Levenshtein Distance between '$word1' and '$word2' is: $distance";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin - Levenshtein Debug")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Enter two words to compare their Levenshtein Distance."),
            SizedBox(height: 10),
            TextField(
              controller: _word1Controller,
              decoration: InputDecoration(labelText: "First Word"),
            ),
            TextField(
              controller: _word2Controller,
              decoration: InputDecoration(labelText: "Second Word"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _calculateLevenshtein,
              child: Text("Calculate Distance"),
            ),
            SizedBox(height: 10),
            Text(
              _result,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== ✅ LEVENSHTEIN DISTANCE ALGORITHM ====================
int levenshteinDistance(String a, String b) {
  int lenA = a.length, lenB = b.length;
  a = a.toLowerCase();
  b = b.toLowerCase();

  if (lenA == 0) return lenB;
  if (lenB == 0) return lenA;

  List<List<int>> dp = List.generate(lenA + 1, (_) => List.filled(lenB + 1, 0));

  initializeDpTable(dp, lenA, lenB);
  computeLevenshtein(dp, a, b, lenA, lenB);
  printDpTable(dp, a, b);

  return dp[lenA][lenB];
}

// ✅ Initialize DP Table
void initializeDpTable(List<List<int>> dp, int lenA, int lenB) {
  for (int i = 0; i <= lenA; i++) {
    dp[i][0] = i;
    printInitialization(i, 0, dp[i][0]);
  }
  for (int j = 0; j <= lenB; j++) {
    dp[0][j] = j;
    printInitialization(0, j, dp[0][j]);
  }
}

// ✅ Compute Levenshtein Distance using DP
void computeLevenshtein(List<List<int>> dp, String a, String b, int lenA, int lenB) {
  for (int i = 1; i <= lenA; i++) {
    for (int j = 1; j <= lenB; j++) {
      int cost = (a[i - 1] == b[j - 1]) ? 0 : 1;
      int deletion = dp[i - 1][j] + 1;
      int insertion = dp[i][j - 1] + 1;
      int substitution = dp[i - 1][j - 1] + cost;

      dp[i][j] = [deletion, insertion, substitution].reduce((a, b) => a < b ? a : b);

      printCellUpdate(i, j, a[i - 1], b[j - 1], cost, deletion, insertion, substitution, dp[i][j]);
    }
  }
  printResult(a, b, dp[lenA][lenB]);
}

// ✅ Print DP Table for Debugging
void printDpTable(List<List<int>> dp, String a, String b) {
    print("\nLevenshtein Distance DP Table:");

    // Print column headers (word `b`), aligned properly
    print("     ${b.split('').join("  ")}"); 

    for (int i = 0; i < dp.length; i++) { //i = row index
        String rowLabel = (i > 0 ? a[i - 1] : ' ');  

        // Format row data with consistent spacing
        String rowData = dp[i].map((e) => e.toString().padLeft(2)).join(" ");

        // Print row with proper indentation
        print("$rowLabel  $rowData");
    }
}


// ✅ Debugging: Print Initial DP Table Values
void printInitialization(int i, int j, int value) {
  print("Initializing DP[$i][$j] = $value");
}

// ✅ Debugging: Print Cell Updates (Step-by-step computation)
void printCellUpdate(int i, int j, String charA, String charB, int cost, int deletion, int insertion, int substitution, int newValue) {
  print("Updating DP[$i][$j] - Comparing '$charA' vs '$charB'");
  print("Costs -> Deletion: $deletion, Insertion: $insertion, Substitution: $substitution");
  print("Final Value: $newValue");
}

void printResult(String a, String b, int distance) {
    print("\nFinal Levenshtein Distance between '$a' and '$b' is: $distance");
}
