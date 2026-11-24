// lib/login_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading       = false;
  bool _obscurePassword = true;
  bool _isSignUp        = false;

  final _emailFocus = FocusNode();
  final _passFocus  = FocusNode();
  bool _emailFocused = false;
  bool _passFocused  = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() => _emailFocused = _emailFocus.hasFocus));
    _passFocus.addListener(()  => setState(() => _passFocused  = _passFocus.hasFocus));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email:    _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final userDoc = await FirebaseFirestore.instance
          .collection('users').doc(cred.user!.uid).get();

      if (!userDoc.exists) {
        await _createUserDoc(cred.user!.uid);
        await _redirect('user');
        return;
      }
      final data = userDoc.data()!;
      if (data['isBanned'] == true) {
        await FirebaseAuth.instance.signOut();
        _showError('Your account has been suspended.\nContact support.');
        return;
      }
      await userDoc.reference.update({'lastLogin': FieldValue.serverTimestamp()});
      _loadProfile(data);
      await _redirect(data['role'] ?? 'user');
    } on FirebaseAuthException catch (e) {
      _showError(_friendlyError(e.code));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email:    _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await _createUserDoc(cred.user!.uid);
      await _redirect('user');
    } on FirebaseAuthException catch (e) {
      _showError(_friendlyError(e.code));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createUserDoc(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': 'User', 'email': _emailController.text.trim(),
      'mobile': '', 'address': '', 'role': 'user',
      'isBanned': false, 'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void _loadProfile(Map<String, dynamic> data) {
    ProfileManager.updateField('name',    data['name']    ?? 'User');
    ProfileManager.updateField('email',   data['email']   ?? '');
    ProfileManager.updateField('mobile',  data['mobile']  ?? '');
    ProfileManager.updateField('address', data['address'] ?? '');
    ProfileManager.updateField('role',    data['role']    ?? 'user');
    ProfileManager.saveProfile();
  }

  Future<void> _redirect(String role) async {
    final target = role == 'admin' ? '/admin' : role == 'vendor' ? '/vendor' : '/home';
    if (mounted) Navigator.pushReplacementNamed(context, target);
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':       return 'No account found with this email.';
      case 'wrong-password':       return 'Incorrect password. Please try again.';
      case 'email-already-in-use': return 'An account already exists with this email.';
      case 'invalid-email':        return 'Please enter a valid email address.';
      case 'weak-password':        return 'Password must be at least 6 characters.';
      case 'too-many-requests':    return 'Too many attempts. Try again later.';
      default:                     return 'Something went wrong. Please try again.';
    }
  }

  void _showError(String msg) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline_rounded, color: Colors.white, size: 15),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: const TextStyle(fontFamily: 'Outfit', fontSize: 13))),
        ]),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade900,
                Colors.blue.shade800,
                Colors.blue.shade400,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),

              // ── brand / headline ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo — no box, just the image
                    FadeInDown(
                      duration: const Duration(milliseconds: 700),
                      child: Image.asset(
                        'assets/logo.png',
                        width: 68,
                        height: 68,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.home_repair_service_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          _isSignUp ? 'Create Account' : 'Welcome Back',
                          key: ValueKey(_isSignUp),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Outfit',
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInDown(
                      duration: const Duration(milliseconds: 900),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          _isSignUp
                              ? 'Join KnockMan — home services made easy'
                              : 'Sign in to book trusted home services',
                          key: ValueKey('sub_$_isSignUp'),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── white card ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft:  Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // email
                          FadeInUp(duration: const Duration(milliseconds: 600),
                              child: _fieldLabel('Email address')),
                          const SizedBox(height: 8),
                          FadeInUp(duration: const Duration(milliseconds: 650),
                              child: _buildEmailField()),

                          const SizedBox(height: 20),

                          // password
                          FadeInUp(duration: const Duration(milliseconds: 700),
                              child: _fieldLabel('Password')),
                          const SizedBox(height: 8),
                          FadeInUp(duration: const Duration(milliseconds: 750),
                              child: _buildPasswordField()),

                          if (!_isSignUp) ...[
                            const SizedBox(height: 10),
                            FadeInUp(
                              duration: const Duration(milliseconds: 780),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 13,
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),

                          FadeInUp(duration: const Duration(milliseconds: 800),
                              child: _buildSubmitButton()),

                          const SizedBox(height: 28),

                          FadeInUp(duration: const Duration(milliseconds: 850),
                              child: _buildToggle()),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── field helpers ───────────────────────────────────────
  Widget _fieldLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 13, fontWeight: FontWeight.w600,
      color: Colors.grey.shade600, fontFamily: 'Outfit',
    ),
  );

  Widget _buildEmailField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _emailFocused ? Colors.blue.shade600 : Colors.grey.shade200,
          width: _emailFocused ? 1.5 : 1,
        ),
        boxShadow: _emailFocused
            ? [BoxShadow(color: Colors.blue.shade100.withOpacity(0.5), blurRadius: 10)]
            : [],
      ),
      child: TextFormField(
        controller: _emailController,
        focusNode: _emailFocus,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Colors.black87, fontFamily: 'Outfit', fontSize: 15),
        decoration: InputDecoration(
          hintText: 'you@example.com',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontFamily: 'Outfit'),
          prefixIcon: Icon(
            Icons.alternate_email_rounded,
            color: _emailFocused ? Colors.blue.shade700 : Colors.grey.shade400,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Email is required';
          if (!v.contains('@')) return 'Enter a valid email';
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _passFocused ? Colors.blue.shade600 : Colors.grey.shade200,
          width: _passFocused ? 1.5 : 1,
        ),
        boxShadow: _passFocused
            ? [BoxShadow(color: Colors.blue.shade100.withOpacity(0.5), blurRadius: 10)]
            : [],
      ),
      child: TextFormField(
        controller: _passwordController,
        focusNode: _passFocus,
        obscureText: _obscurePassword,
        style: const TextStyle(
          color: Colors.black87, fontFamily: 'Outfit',
          fontSize: 15, letterSpacing: 1.2,
        ),
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontFamily: 'Outfit', letterSpacing: 1),
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: _passFocused ? Colors.blue.shade700 : Colors.grey.shade400,
            size: 20,
          ),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.grey.shade400, size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Password is required';
          if (v.length < 6) return 'Minimum 6 characters';
          return null;
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: _isLoading
          ? Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: SizedBox(
            width: 22, height: 22,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
          ),
        ),
      )
          : ElevatedButton(
        onPressed: _isSignUp ? _signUp : _login,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.blue.shade600],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade900.withOpacity(0.35),
                blurRadius: 16, offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isSignUp ? 'Create Account' : 'Sign In',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.w700, fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Center(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _isSignUp = !_isSignUp;
            _emailController.clear();
            _passwordController.clear();
          });
        },
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontFamily: 'Outfit', fontSize: 14),
            children: [
              TextSpan(
                text: _isSignUp ? "Already have an account?  " : "Don't have an account?  ",
                style: TextStyle(color: Colors.grey.shade500),
              ),
              TextSpan(
                text: _isSignUp ? 'Sign In' : 'Sign Up',
                style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}