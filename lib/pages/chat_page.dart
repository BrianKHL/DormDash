import 'dart:math';
import 'package:flutter/material.dart';

// ==================== ✅ COSINE SIMILARITY ALGORITHM FOR CHAT FEATURE ====================
class CosineSimilarityChat {
  final List<Map<String, int>> messageHistory = []; // Stores message word frequency vectors -> List can be better than Map - > Slower but speed is not a concern here
  final List<String> rawMessages = []; 
  final double similarityThreshold = 0.8; 
  final int historySize = 10; 

  // ✅ Process Incoming Messages
  void processMessage(String newMessage) {
    Map<String, int> newVector = _vectorizeMessage(newMessage);
    
    if (_checkSimilarity(newVector, newMessage)) {
      print("[⚠️] Message is too similar to a previous message. Possiblity of Spam!");
      return;
    }

    // ✅ Maintain history size // historySize = address conversation scope not using the histyory size
    if (messageHistory.length >= historySize) {
      messageHistory.removeAt(0);
      rawMessages.removeAt(0);
    }

    messageHistory.add(newVector);
    rawMessages.add(newMessage);
    print("✅ Message accepted: $newMessage");
  }

  //Solution: Use weighted history retention—messages that appear more frequently or get higher similarity scores could be stored longer.



  // ✅ Convert message to a word frequency vector
  Map<String, int> _vectorizeMessage(String message) {
    Map<String, int> wordFrequency = {};
    List<String> words = message.toLowerCase().split(RegExp(r'\W+'));

    for (String word in words) {
      if (word.isNotEmpty) {
        wordFrequency[word] = (wordFrequency[word] ?? 0) + 1;
      }
    }
    return wordFrequency;
  }

  // ✅ Normalize Vector (Prevents bias from long messages) // why we have to normalize the vector - > what is bias here.
  Map<String, double> _normalizeVector(Map<String, int> vector) {
    double magnitude = sqrt(vector.values.fold(0, (sum, value) => sum + pow(value, 2))); // Euclidean Norm formula A = sqrt(a^2 + b^2 + c^2 + ...)
    return vector.map((key, value) => MapEntry(key, value / magnitude));
  }

  //Longer messages tend to have higher word frequencies, which can bias the cosine similarity score. 
  //Cos similarity is purely based on word content, not message size.
  //-> longer messages have more words, so they have more chances to be similar to other messages.
  //dividing each word frequency by the magnitude of the vector.



  // ✅ Extract Unique Words from All Messages (one key) // one dimension hash
  Set<String> _getUniqueWords() {
    Set<String> uniqueWords = {};
    for (var message in messageHistory) {
      uniqueWords.addAll(message.keys);
    }
    return uniqueWords;
  }

  // ✅ Check similarity with previous messages
  bool _checkSimilarity(Map<String, int> newVector, String newMessage) {
    Map<String, double> normalizedNewVector = _normalizeVector(newVector);

    for (int i = 0; i < messageHistory.length; i++) {
      double similarity = _cosineSimilarity(normalizedNewVector, _normalizeVector(messageHistory[i]));
      if (similarity >= similarityThreshold) {
        print("[💡] Similar to: '${rawMessages[i]}' (Similarity: ${similarity.toStringAsFixed(2)})");
        print("[🤖] Suggested Auto-Response: 'You might be asking the same thing!'");
        return true; // Mark as similar
      }
    }
    return false;
  }

  // ✅ Compute Cosine Similarity with a Global Vocabulary
  double _cosineSimilarity(Map<String, double> vec1, Map<String, double> vec2) {
    Set<String> uniqueWords = _getUniqueWords(); // Extract unique words from message history

    double dotProduct = 0;
    double magnitude1 = 0;
    double magnitude2 = 0;

    // ✅ Compute dot product and magnitudes
    for (String word in uniqueWords) {
      double val1 = vec1[word] ?? 0.0;
      double val2 = vec2[word] ?? 0.0;
      dotProduct += val1 * val2;
      magnitude1 += pow(val1, 2);
      magnitude2 += pow(val2, 2);
    }

    //message 1 : "Hello World"
    //message 2 : "Hello DormDash"
    //dotProduct = 1*1 + 1*0 + 0*1 = 1
    //magnitude1 = (1^2 + 1^2) = 2
    //magnitude2 = (1^2 + 1^2) = 2

    magnitude1 = sqrt(magnitude1);
    magnitude2 = sqrt(magnitude2);

    // ✅ Prevent division by zero
    if (magnitude1 * magnitude2 == 0) return 0;

    double similarityScore = dotProduct / (magnitude1 * magnitude2);
    
    // ✅ Debugging Logs
    print("[📊] Cosine Similarity Computation:");
    //print("     - Dot Product: $dotProduct"); // not nessary to print
    //print("     - Magnitude 1: $magnitude1"); 
    //print("     - Magnitude 2: $magnitude2");
    print("     - Cosine Similarity Score: ${similarityScore.toStringAsFixed(4)}");

    return similarityScore;
  }
}

// why do we have to use cosine similarity for chat feature?
// for word why ? 

//Cos similarity conceptual similarity between two vectors.


// ==================== ✅ END OF COSINE SIMILARITY ALGORITHM FOR CHAT FEATURE ====================

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final CosineSimilarityChat _chatProcessor = CosineSimilarityChat();
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];

  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _chatProcessor.processMessage(message);
      setState(() {
        _messages.add(message);
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DormDash - Chat Feature')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(labelText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
