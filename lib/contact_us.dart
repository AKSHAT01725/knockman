// lib/contact_us.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _isSubmitting = false;

  // ── Design Tokens ──────────────────────────────────────────
  static const Color _navy          = Color(0xFF0B1D3A);
  static const Color _navyLight     = Color(0xFF162D56);
  static const Color _accent        = Color(0xFF2A7AF5);
  static const Color _surface       = Color(0xFFF7F9FC);
  static const Color _cardBg        = Colors.white;
  static const Color _textPrimary   = Color(0xFF0B1D3A);
  static const Color _textSecondary = Color(0xFF6B7A99);
  static const String _font         = 'Outfit';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance
          .collection('contact_messages')
          .add({
        'name':      _nameCtrl.text.trim(),
        'email':     _emailCtrl.text.trim(),
        'message':   _messageCtrl.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'status':    'unread',
      });

      if (!mounted) return;
      _showSuccessDialog();
    } on FirebaseException catch (e) {
      if (!mounted) return;
      _showErrorDialog(_firestoreErrorMessage(e.code));
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(
          'Unable to send your message right now.\nPlease try again later.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Friendly error messages ────────────────────────────────
  String _firestoreErrorMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'Permission denied. Please make sure you are logged in and try again.';
      case 'unavailable':
        return 'Service is temporarily unavailable. Please check your internet connection and try again.';
      case 'deadline-exceeded':
        return 'The request timed out. Please check your connection and try again.';
      case 'unauthenticated':
        return 'You need to be logged in to send a message.';
      case 'resource-exhausted':
        return 'Too many requests. Please wait a moment and try again.';
      default:
        return 'Unable to send your message right now.\nPlease try again later.';
    }
  }

  // ── Success Dialog ─────────────────────────────────────────
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // animated check circle
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (_, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.shade50,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(Icons.check_rounded,
                      color: Colors.green.shade600, size: 36),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Message Sent!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontFamily: _font,
                  color: _textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you, ${_nameCtrl.text.trim().split(' ').first}! '
                    'Our team will get back to you within 24 hours.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: _textSecondary,
                  fontFamily: _font,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _nameCtrl.clear();
                    _emailCtrl.clear();
                    _messageCtrl.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: _font,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
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

  // ── Error Dialog ───────────────────────────────────────────
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.shade50,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(Icons.wifi_off_rounded,
                    color: Colors.red.shade500, size: 34),
              ),
              const SizedBox(height: 20),
              const Text(
                'Could Not Send',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFamily: _font,
                  color: _textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: _textSecondary,
                  fontFamily: _font,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Try again
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _submitForm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _navy,
                        padding:
                        const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: _font,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Dismiss
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        padding:
                        const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Dismiss',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontFamily: _font,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── BUILD ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 820;

    return Scaffold(
      backgroundColor: _surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 48 : 20,
                vertical: 40,
              ),
              child: isWide
                  ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: _buildContactInfo()),
                  const SizedBox(width: 40),
                  Expanded(flex: 7, child: _buildContactForm()),
                ],
              )
                  : Column(
                children: [
                  _buildContactInfo(),
                  const SizedBox(height: 32),
                  _buildContactForm(),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }

  // ── Sliver App Bar ─────────────────────────────────────────
  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: _navy,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 16),
        ),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: const Text(
        'Contact Us',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          fontFamily: _font,
          letterSpacing: 0.3,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_navy, _navyLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              right: -40, top: -20,
              child: _decorativeCircle(160, _accent.withOpacity(0.08)),
            ),
            Positioned(
              left: -30, bottom: -30,
              child: _decorativeCircle(
                  120, const Color(0xFF1EC8C8).withOpacity(0.07)),
            ),
            Positioned(
              right: 80, bottom: 20,
              child: _decorativeCircle(60, _accent.withOpacity(0.12)),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 32),
                child: FadeInDown(
                  duration: const Duration(milliseconds: 700),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Get in Touch',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          fontFamily: _font,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "We'd love to hear from you.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 14,
                          fontFamily: _font,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _decorativeCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration:
    BoxDecoration(shape: BoxShape.circle, color: color),
  );

  // ── Contact Info ───────────────────────────────────────────
  Widget _buildContactInfo() {
    return FadeInLeft(
      duration: const Duration(milliseconds: 800),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('REACH US'),
          const SizedBox(height: 6),
          const Text(
            'Contact\nInformation',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
              fontFamily: _font,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Our support team is available Monday–Saturday,\n9 AM – 7 PM IST.',
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary,
              fontFamily: _font,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          _buildInfoCard(
            icon: Icons.phone_in_talk_rounded,
            iconColor: _accent,
            iconBg: const Color(0xFFE8F0FE),
            title: 'Call Us',
            subtitle: '+91 90546 47189',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.mail_outline_rounded,
            iconColor: const Color(0xFF1EC8C8),
            iconBg: const Color(0xFFE0F7FA),
            title: 'Email',
            subtitle: 'support@knockman.com',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.location_on_outlined,
            iconColor: const Color(0xFFFF7043),
            iconBg: const Color(0xFFFBE9E7),
            title: 'Office',
            subtitle:
            '11, Swastik Complex, CG Road,\nAhmedabad, India',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
  }) {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border:
          Border.all(color: const Color(0xFFE8EBF2), width: 1),
          boxShadow: [
            BoxShadow(
              color: _navy.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _textSecondary,
                      fontFamily: _font,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                      fontFamily: _font,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Contact Form ───────────────────────────────────────────
  Widget _buildContactForm() {
    return FadeInRight(
      duration: const Duration(milliseconds: 800),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('SEND A MESSAGE'),
          const SizedBox(height: 6),
          const Text(
            "We'll respond\nwithin 24 hours",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
              fontFamily: _font,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: const Color(0xFFE8EBF2), width: 1),
              boxShadow: [
                BoxShadow(
                  color: _navy.withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Full Name'),
                  const SizedBox(height: 6),
                  _buildField(
                    controller: _nameCtrl,
                    hint: 'e.g. Arjun Sharma',
                    icon: Icons.person_outline_rounded,
                    validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Please enter your name'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  _buildFieldLabel('Email Address'),
                  const SizedBox(height: 6),
                  _buildField(
                    controller: _emailCtrl,
                    hint: 'you@example.com',
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(v.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  _buildFieldLabel('Message'),
                  const SizedBox(height: 6),
                  _buildField(
                    controller: _messageCtrl,
                    hint: 'Tell us how we can help you…',
                    icon: Icons.chat_bubble_outline_rounded,
                    maxLines: 5,
                    validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Please enter your message'
                        : null,
                  ),
                  const SizedBox(height: 28),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: _textPrimary,
      fontFamily: _font,
      letterSpacing: 0.2,
    ),
  );

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        fontFamily: _font,
        fontSize: 14,
        color: _textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: _font,
          fontSize: 14,
          color: _textSecondary.withOpacity(0.6),
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: maxLines == 1
            ? Icon(icon,
            size: 20,
            color: _textSecondary.withOpacity(0.7))
            : null,
        alignLabelWithHint: true,
        filled: true,
        fillColor: _surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 14 : 0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFFE0E4EF), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFFE0E4EF), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFFE53935), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFFE53935), width: 1.5),
        ),
        errorStyle: const TextStyle(
            fontFamily: _font,
            fontSize: 12,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: _navy,
          disabledBackgroundColor: _navy.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: _isSubmitting
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.white),
        )
            : const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Send Message',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: _font,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.send_rounded,
                color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Container(
    padding: const EdgeInsets.symmetric(
        horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: _accent.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _accent,
        fontFamily: _font,
        letterSpacing: 1.2,
      ),
    ),
  );
}