// ==================== ✅ ITEM CLASS (WITH COMPARABLE) ====================
class Item implements Comparable<Item> {
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

  // ✅ Implement compareTo method
  @override
  int compareTo(Item other) {
    return name.toLowerCase().compareTo(other.name.toLowerCase());
  }

  @override
  String toString() {
    return name;
  }
}

// ==================== ✅ OPTIMIZED ITEM DATABASE ====================
// 2-3 Tree + Fuzzy Search Logic
class OptimizedItemDatabase {
  final TwoThreeTree<Item> _twoThreeTree = TwoThreeTree<Item>();

  // ✅ 2-3 TREE INSERTION
  void addItem(Item item) {
    _twoThreeTree.insert(item);
  }

  // ✅ 2-3 TREE SEARCH
  List<Item> searchItems(String query) {
    List<Item> results = [];
    for (Item item in _twoThreeTree.inorderTraversal()) {
      if (item.name.toLowerCase().contains(query.toLowerCase())) {
        results.add(item);
      }
    }
    return results;
  }

  // 🔍 FUZZY SEARCH USING LEVENSHTEIN DISTANCE
  List<Item> fuzzySearch(String query, int maxDistance) {
    List<Item> results = [];
    for (Item item in _twoThreeTree.inorderTraversal()) {
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

    for (int i = 0; i <= lenA; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= lenB; j++) {
      dp[0][j] = j;
    }

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

// ==================== ✅ TWO-THREE TREE IMPLEMENTATION ====================
class TwoThreeTreeNode<T extends Comparable> {
  T? value1;
  T? value2;
  TwoThreeTreeNode<T>? left;
  TwoThreeTreeNode<T>? middle;
  TwoThreeTreeNode<T>? right;
  TwoThreeTreeNode<T>? parent;

  bool isLeaf() => left == null && middle == null && right == null;
  bool is2Node() => value2 == null;
  bool is3Node() => value2 != null;
}

class TwoThreeTree<T extends Comparable> {
  TwoThreeTreeNode<T>? root;

  // ✅ Insert a value into the 2-3 Tree
  void insert(T value) {
    if (root == null) {
      root = TwoThreeTreeNode<T>()..value1 = value;
    } else {
      _insert(root!, value); // new location for new value
    }
  }

  void _insert(TwoThreeTreeNode<T> node, T value) {
    if (node.isLeaf()) {
      if (node.is2Node()) {
        if (value.compareTo(node.value1!) < 0) {
          node.value2 = node.value1;
          node.value1 = value;
        } else {
          node.value2 = value;
        }
      } else {
        _split(node, value); // when node with two values
      }
    } else {
      if (value.compareTo(node.value1!) < 0) {
        _insert(node.left!, value);
      } else if (node.is2Node() || value.compareTo(node.value2!) < 0) {
        _insert(node.middle!, value);
      } else {
        _insert(node.right!, value);
      }
    }
  }

  // ✅ Split a 3-node during insertion
  void _split(TwoThreeTreeNode<T> node, T value) {
    List<T> values = [node.value1!, node.value2!, value]..sort();
    node.value1 = values[1];
    node.value2 = null;
    node.left = TwoThreeTreeNode<T>()..value1 = values[0];
    node.right = TwoThreeTreeNode<T>()..value1 = values[2];
  }

  // ✅ Search for a value in the 2-3 Tree
  bool search(T value) {
    return _search(root, value);
  }

  bool _search(TwoThreeTreeNode<T>? node, T value) {
    if (node == null) return false;
    if (value.compareTo(node.value1!) == 0 || (node.value2 != null && value.compareTo(node.value2!) == 0)) {
      return true; //match w parent node first
    }
    if (value.compareTo(node.value1!) < 0) {
      return _search(node.left, value);
    } else if (node.value2 == null || value.compareTo(node.value2!) < 0) {
      return _search(node.middle, value);
    } else {
      return _search(node.right, value);
    }
  }

  // ✅ In-order Traversal (values sorting)
  List<T> inorderTraversal() {
    List<T> result = [];
    _inorderTraversal(root, result);
    return result;
  }

  void _inorderTraversal(TwoThreeTreeNode<T>? node, List<T> result) {
    if (node == null) return;
    _inorderTraversal(node.left, result);
    result.add(node.value1!);
    _inorderTraversal(node.middle, result);
    if (node.value2 != null) result.add(node.value2!);
    _inorderTraversal(node.right, result);
  }
}
