// lib/login_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _createUserDoc(cred.user!.uid);
        await _redirect('user');
        return;
      }

      final data = userDoc.data()!;
      final isBanned = data['isBanned'] == true;

      if (isBanned) {
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your account is banned. Contact admin.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Update last login
      await userDoc.reference.update({'lastLogin': FieldValue.serverTimestamp()});

      await _loadProfile(data);
      await _redirect(data['role'] ?? 'user');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future _createUserDoc(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': 'User',
      'email': _emailController.text.trim(),
      'mobile': '',
      'address': '',
      'role': 'user',
      'isBanned': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future _loadProfile(Map<String, dynamic> data) async {
    ProfileManager.updateField('name', data['name'] ?? 'User');
    ProfileManager.updateField('email', data['email']);
    ProfileManager.updateField('mobile', data['mobile'] ?? '');
    ProfileManager.updateField('address', data['address'] ?? '');
    ProfileManager.updateField('role', data['role'] ?? 'user');
    await ProfileManager.saveProfile();
  }

  Future _redirect(String role) async {
    final target = role == 'admin'
        ? '/admin'
        : role == 'vendor'
        ? '/vendor'
        : '/home';
    if (mounted) Navigator.pushReplacementNamed(context, target);
  }

  Future _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await _createUserDoc(cred.user!.uid);
      await _redirect('user');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Sign up failed')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [Colors.blue.shade900, Colors.blue.shade800, Colors.blue.shade400],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 1000),
                    child: const Text('Login', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                  ),
                  const SizedBox(height: 10),
                  FadeInDown(
                    duration: const Duration(milliseconds: 1200),
                    child: const Text('Welcome Back to KnockMan', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Outfit')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          FadeInUp(
                            duration: const Duration(milliseconds: 1400),
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [
                                BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                              ]),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      hintText: 'Email',
                                      hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Outfit'),
                                      contentPadding: EdgeInsets.all(16),
                                      border: InputBorder.none,
                                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
                                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue), borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
                                    ),
                                    validator: (v) => v!.isEmpty ? 'Enter email' : !v.contains('@') ? 'Invalid email' : null,
                                  ),
                                  const Divider(height: 1, color: Colors.grey),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      hintText: 'Password',
                                      hintStyle: TextStyle(color: Colors.grey, fontFamily: 'Outfit'),
                                      contentPadding: EdgeInsets.all(16),
                                      border: InputBorder.none,
                                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))),
                                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue), borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))),
                                    ),
                                    validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          _isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade900,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text('Login', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: _signUp,
                            child: const Text('Don’t have an account? Sign Up', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontFamily: 'Outfit')),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}