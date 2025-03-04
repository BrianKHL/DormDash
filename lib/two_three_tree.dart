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
      _insert(root!, value);
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
        _split(node, value);
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
      return true;
    }
    if (value.compareTo(node.value1!) < 0) {
      return _search(node.left, value);
    } else if (node.value2 == null || value.compareTo(node.value2!) < 0) {
      return _search(node.middle, value);
    } else {
      return _search(node.right, value);
    }
  }

  // ✅ In-order Traversal (to get sorted values)
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
