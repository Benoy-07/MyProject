import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _ctrl = TextEditingController();
  int rating = 5;

  void submit() {
    final data = {
      'text': _ctrl.text,
      'rating': rating,
      'date': DateTime.now().toIso8601String(),
    };
    FirebaseFirestore.instance.collection('feedbacks').add(data);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thanks for feedback')));
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback & Rating')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Rate us:'),
            Slider(value: rating.toDouble(), min: 1, max: 5, divisions: 4, onChanged: (v) => setState(() => rating = v.toInt())),
            TextField(controller: _ctrl, decoration: InputDecoration(labelText: 'Your feedback')),
            SizedBox(height: 16),
            ElevatedButton(onPressed: submit, child: Text('Send')),
          ],
        ),
      ),
    );
  }
}
