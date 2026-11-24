// lib/admin_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart'; // For navigatorKey

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedRole = 'user';

  // LOGOUT FUNCTION
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(
      navigatorKey.currentContext!,
      '/login',
          (route) => false,
    );
  }

  Future<void> _createAccount() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all fields')),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be 6+ chars')),
      );
      return;
    }

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'mobile': '',
        'address': '',
        'role': _selectedRole,
        'isBanned': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_selectedRole.toUpperCase()} created!')),
      );

      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error')),
      );
    }
  }

  Future<void> _toggleBan(String uid, bool current) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'isBanned': !current});
  }

  Future<void> _deleteUser(String uid) async {
    final confirmed = await _showConfirmDialog(
        'Delete Account', 'This will permanently delete the account data.');
    if (!confirmed) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.uid == uid) {
        await FirebaseAuth.instance.signOut();
        Navigator.pushNamedAndRemoveUntil(
          navigatorKey.currentContext!,
          '/login',
              (route) => false,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _changeRole(String uid, String currentRole) async {
    final newRole = currentRole == 'user' ? 'vendor' : 'user';
    final confirmed = await _showConfirmDialog(
        'Change Role', 'Switch from $currentRole to $newRole?');
    if (confirmed) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'role': newRole});
    }
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    final context = navigatorKey.currentContext!;
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontFamily: 'Outfit')),
        content: Text(content, style: const TextStyle(fontFamily: 'Outfit')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel', style: TextStyle(fontFamily: 'Outfit')),
          backgroundColor: Colors.blue[900],
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.white,           // WHITE TAB TEXT
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Create'),
              Tab(text: 'Users'),
              Tab(text: 'Vendors'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCreateTab(),
            _buildList('user'),
            _buildList('vendor'),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateTab() {
    return Container(
      color: Colors.white, // Keep dark background
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // BLACK TITLE
            const Text(
              'Create New Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
                color: Colors.black,  // BLACK
              ),
            ),
            const SizedBox(height: 20),

            // BLACK TEXT FIELDS
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.black), // BLACK TEXT
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: const TextStyle(color: Colors.black54), // DARK GRAY LABEL
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _passwordController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _selectedRole,
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black), // BLACK TEXT
              items: const [
                DropdownMenuItem(value: 'user', child: Text('User', style: TextStyle(color: Colors.black))),
                DropdownMenuItem(value: 'vendor', child: Text('Vendor', style: TextStyle(color: Colors.black))),
              ],
              onChanged: (v) => setState(() => _selectedRole = v!),
              decoration: InputDecoration(
                labelText: 'Role',
                labelStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black, width: 2)),
              ),
            ),
            const SizedBox(height: 24),

            // WHITE TEXT BUTTON
            ElevatedButton.icon(
              onPressed: _createAccount,
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text(
                'Create Account',
                style: TextStyle(
                  color: Colors.white,     // WHITE TEXT
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(String role) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: role)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No ${role}s found',
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, i) {
            final doc = snapshot.data!.docs[i];
            final data = doc.data()! as Map<String, dynamic>;
            final uid = doc.id;
            final name = data['name'] ?? 'No Name';
            final email = data['email'] ?? '';
            final mobile = data['mobile'] ?? '—';
            final isBanned = data['isBanned'] == true;
            final lastLogin = data['lastLogin'] as Timestamp?;

            return Card(
              color: Colors.blue[800],
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isBanned ? Colors.red[100] : Colors.blue[100],
                  child: Text(
                    name[0].toUpperCase(),
                    style: TextStyle(
                      color: isBanned ? Colors.red[900] : Colors.blue[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(name, style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(email, style: const TextStyle(color: Colors.white70)),
                    Text('Mobile: $mobile', style: const TextStyle(color: Colors.white70)),
                    if (lastLogin != null)
                      Text(
                        'Last Login: ${DateFormat('dd MMM yyyy, hh:mm a').format(lastLogin.toDate())}',
                        style: const TextStyle(fontSize: 12, color: Colors.white60),
                      ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  color: Colors.blue[700],
                  onSelected: (value) async {
                    if (value == 'ban') await _toggleBan(uid, isBanned);
                    if (value == 'delete') await _deleteUser(uid);
                    if (value == 'role') await _changeRole(uid, role);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'ban',
                      child: Row(
                        children: [
                          Icon(isBanned ? Icons.lock_open : Icons.lock,
                              color: isBanned ? Colors.green : Colors.red),
                          const SizedBox(width: 8),
                          Text(isBanned ? 'Unban' : 'Ban', style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'role',
                      child: Row(
                        children: [
                          Icon(Icons.swap_horiz, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Change Role', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_forever, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}