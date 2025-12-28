// admin_user_management.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserManagement extends StatefulWidget {
  const AdminUserManagement({super.key});

  @override
  State<AdminUserManagement> createState() => _AdminUserManagementState();
}

class _AdminUserManagementState extends State<AdminUserManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _debugLogs = [];
  bool _showDebug = false;

  void _addDebugLog(String message) {
    print(message);
    if (mounted) {
      setState(() {
        _debugLogs.add('${DateTime.now().toString().split(' ')[1]}: $message');
        if (_debugLogs.length > 10) _debugLogs.removeAt(0);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  void _initializeScreen() {
    _addDebugLog('🔍 UserManagementScreen initialized');
    _checkFirestoreConnection();
  }

  Future<void> _checkFirestoreConnection() async {
    try {
      _addDebugLog('🔄 Checking Firestore connection...');
      final userSnapshot = await _firestore.collection('users').get();
      _addDebugLog('👥 Total users in Firestore: ${userSnapshot.docs.length}');
      
      for (var doc in userSnapshot.docs) {
        _addDebugLog('📄 User: ${doc.data()['email']} (${doc.id})');
      }
    } catch (e) {
      _addDebugLog('❌ Firestore error: $e');
    }
  }

  Future<void> _deleteUser(String uid, String name) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      _addDebugLog('🗑️ User deleted: $name ($uid)');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$name deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _addDebugLog('❌ Delete error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error deleting user: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context, String uid, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete User"),
        content: Text("Are you sure you want to delete $name permanently?\n\nThis action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteUser(uid, name);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> _addTestUser() async {
    try {
      final testUserData = {
        'uid': 'test-user-${DateTime.now().millisecondsSinceEpoch}',
        'email': 'test${DateTime.now().millisecondsSinceEpoch}@test.com',
        'name': 'Test User',
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'isAdmin': false,
        'phone': '1234567890',
        'hall': 'Test Hall',
        'emailVerified': false,
      };
      
      await _firestore.collection('users').doc(testUserData['uid'] as String?).set(testUserData);
      _addDebugLog('✅ Test user added: ${testUserData['email']}');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Test user added!")),
      );
    } catch (e) {
      _addDebugLog('❌ Error adding test user: $e');
    }
  }

  void _refreshData() {
    _addDebugLog('🔄 Manually refreshing data...');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Management"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          // Toggle debug logs visibility
          IconButton(
            icon: Icon(_showDebug ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showDebug = !_showDebug;
              });
            },
            tooltip: 'Toggle Logs',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _addTestUser,
            tooltip: 'Add Test User',
          ),
        ],
      ),
      body: Column(
        children: [
          // Debug Panel (hidden by default; toggle with AppBar button)
          if (_showDebug) ...[
            if (_debugLogs.isNotEmpty)
              Container(
                width: double.infinity,
                color: Colors.grey[900],
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Debug Logs:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white, size: 18),
                          onPressed: () {
                            setState(() {
                              _debugLogs.clear();
                            });
                          },
                          tooltip: 'Clear logs',
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ..._debugLogs.reversed.map((log) => Text(
                      log,
                      style: TextStyle(
                        color: log.contains('❌') ? Colors.red : 
                               log.contains('✅') ? Colors.green : 
                               Colors.yellow,
                        fontSize: 10,
                      ),
                    )).toList(),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                color: Colors.grey[900],
                padding: const EdgeInsets.all(8),
                child: const Text('No debug logs', style: TextStyle(color: Colors.white)),
              ),
          ],
          
          // User List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('❌ Stream error: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text("Error: ${snapshot.error}"),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshData,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userDocs = snapshot.data?.docs ?? [];
                print('📊 Users in stream: ${userDocs.length}');

                if (userDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text("No users found", style: TextStyle(fontSize: 18, color: Colors.grey)),
                        const Text("Users will appear here after they sign up", style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _addTestUser,
                          child: const Text("Add Test User"),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: userDocs.length,
                  itemBuilder: (context, index) {
                    final doc = userDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    final String uid = doc.id;
                    final String email = data['email'] ?? 'No email';
                    final String name = data['name'] ?? email.split('@').first;
                    final bool isAdmin = data['isAdmin'] == true;
                    final bool emailVerified = data['emailVerified'] == true;
                    final String? photoUrl = data['photoUrl'];
                    final Timestamp? createdAt = data['createdAt'];
                    final String hall = data['hall'] ?? 'Not set';
                    final String phone = data['phone'] ?? 'Not set';

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isAdmin ? Colors.redAccent : 
                                        emailVerified ? Colors.green : Colors.blue,
                          child: photoUrl != null && photoUrl.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    photoUrl,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              : Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isAdmin)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(Icons.admin_panel_settings, size: 16, color: Colors.red),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(email),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  emailVerified ? Icons.verified : Icons.verified,
                                  size: 14,
                                  color: emailVerified ? Colors.green : Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  emailVerified ? 'Verified' : 'Not Verified',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: emailVerified ? Colors.green : Colors.orange,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.home_work, size: 14, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(
                                  hall,
                                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                                ),
                              ],
                            ),
                            if (phone.isNotEmpty && phone != 'Not set') ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.phone, size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    phone,
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                            if (createdAt != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Joined: ${_formatDate(createdAt.toDate())}',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                          onPressed: () => _showDeleteDialog(context, uid, name),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}