import 'package:flutter/material.dart';
import 'pages/sell_giveaway_page.dart';
import 'pages/chat_page.dart';
import 'pages/admin_page.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

// SHA256 and AuthService classes remain the same, but at the end
// First, added sha256 to main.dart and create the AuthScreen

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
      home: AuthScreen(), // Changed from HomeScreen to AuthScreen
    );
  }
}

// ==================== AUTHENTICATION SCREEN ====================
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginMode = true;
  String? _errorMessage;

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    try {
      if (_isLoginMode) {
        bool success = await AuthService.loginUser(username, password);
        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          setState(() {
            _errorMessage = 'Invalid username or password';
          });
        }
      } else {
        await AuthService.registerUser(username, password);
        setState(() {
          _errorMessage = 'Registration successful! Please login';
          _isLoginMode = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DormDash - ${_isLoginMode ? 'Login' : 'Register'}')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (_errorMessage != null)
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text(_isLoginMode ? 'Login' : 'Register'),
            ),
            TextButton(
              onPressed: _toggleMode,
              child: Text(_isLoginMode
                  ? 'Need an account? Register'
                  : 'Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== HOME SCREEN ====================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DormDash - Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text("Sell/Give Away Items"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SellGiveAwayScreen()),
                );
              },
            ),
            ElevatedButton(
              child: Text("Go to Chat"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatPage()),
                );
              },
            ),
            ElevatedButton(
              child: Text("Admin Panel"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

//SHA256 with AuthService classes
class SHA256 {
  static final List<int> _hashConstants = [
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
    0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19 
  ];
  //Derived from the first 64 prime numbers
  static final List<int> _roundConstants = [
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1,
    0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
    0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
    0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
    0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
    0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
  ];

  static String hash(String input) {
    Uint8List bytes = Uint8List.fromList(utf8.encode(input));
    List<int> padded = _padMessage(bytes);
    List<int> hashValues = List.from(_hashConstants);
    
    for (int i = 0; i < padded.length; i += 64) { // creates 64 word array
      List<int> chunk = padded.sublist(i, i + 64); 
      List<int> words = List.filled(64, 0);
      for (int j = 0; j < 16; j++) { // 64bytes to 16 32 bit words
        words[j] = (chunk[j * 4] << 24) | // bits shifting to left
                   (chunk[j * 4 + 1] << 16) |
                   (chunk[j * 4 + 2] << 8) |
                   chunk[j * 4 + 3];
      }
      // The combination of operations (rotations, shifts, XORs)
      for (int j = 16; j < 64; j++) { 
        int s0 = _rightRotate(words[j - 15], 7) ^ _rightRotate(words[j - 15], 18) ^ (words[j - 15] >> 3);
        int s1 = _rightRotate(words[j - 2], 17) ^ _rightRotate(words[j - 2], 19) ^ (words[j - 2] >> 10);
        words[j] = words[j - 16] + s0 + words[j - 7] + s1;
      }
      int a = hashValues[0], b = hashValues[1], c = hashValues[2], d = hashValues[3];
      int e = hashValues[4], f = hashValues[5], g = hashValues[6], h = hashValues[7];
      //e to a
      for (int j = 0; j < 64; j++) {
        int S1 = _rightRotate(e, 6) ^ _rightRotate(e, 11) ^ _rightRotate(e, 25);
        int ch = (e & f) ^ ((~e) & g);
        int temp1 = h + S1 + ch + _roundConstants[j] + words[j];
        int S0 = _rightRotate(a, 2) ^ _rightRotate(a, 13) ^ _rightRotate(a, 22);
        int maj = (a & b) ^ (a & c) ^ (b & c);
        int temp2 = S0 + maj;
        h = g;
        g = f;
        f = e;
        e = d + temp1;
        d = c;
        c = b;
        b = a;
        a = temp1 + temp2;
      }
      //refining
      hashValues[0] += a; hashValues[1] += b; hashValues[2] += c;
      hashValues[3] += d; hashValues[4] += e; hashValues[5] += f;
      hashValues[6] += g; hashValues[7] += h;
    }
    // 8 values to the sha256 hash
    return hashValues.map((h) => h.toRadixString(16).padLeft(8, '0')).join();
  }
  static List<int> _padMessage(Uint8List bytes) {
    int originalLength = bytes.length * 8;
    List<int> padded = List.from(bytes)..add(0x80); //ensures the message is properly padded
    while ((padded.length * 8 + 64) % 512 != 0) {
      padded.add(0);
    }
    padded.addAll(List.filled(8, 0));
    for (int i = 0; i < 8; i++) {
      padded[padded.length - 1 - i] = (originalLength >> (8 * i)) & 0xff;
    }
    return padded;
  }
  // shifts x right by n bits filling wth zeros, moves the leftmost n bits to the rightmost position.
  static int _rightRotate(int x, int n) => (x >>> n) | (x << (32 - n)); 
}

// Hash password using sha256 and keeps passswords safe in SharedPreferences
class AuthService {
  static Future<void> registerUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    String hashedPassword = SHA256.hash(password);
    await prefs.setString(username, hashedPassword);
  }
  static Future<bool> loginUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    String? storedPassword = prefs.getString(username);
    return storedPassword == SHA256.hash(password);
  }
}


//need to convert 32 bit hashvalues into hex string, 8 characters long
//need to make pads the input message so that its length becomes a multiple of 512 bits