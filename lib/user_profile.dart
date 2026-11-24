// lib/user_profile.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'profile_manager.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  final _nameController    = TextEditingController();
  final _emailController   = TextEditingController();
  final _mobileController  = TextEditingController();
  final _addressController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving  = false;

  final _nameFocus    = FocusNode();
  final _emailFocus   = FocusNode();
  final _mobileFocus  = FocusNode();
  final _addressFocus = FocusNode();

  static const Color _navy    = Color(0xFF0D2137);
  static const Color _blue    = Color(0xFF1565C0);
  static const Color _surface = Color(0xFFF4F7FB);

  @override
  void initState() {
    super.initState();
    _loadProfile();
    for (final fn in [_nameFocus, _emailFocus, _mobileFocus, _addressFocus]) {
      fn.addListener(() => setState(() {}));
    }
  }

  void _loadProfile() {
    _nameController.text    = ProfileManager.userName;
    _emailController.text   = ProfileManager.email;
    _mobileController.text  = ProfileManager.mobile;
    _addressController.text = ProfileManager.address;
  }

  @override
  void dispose() {
    for (final c in [
      _nameController,
      _emailController,
      _mobileController,
      _addressController
    ]) {
      c.dispose();
    }
    for (final fn in [
      _nameFocus,
      _emailFocus,
      _mobileFocus,
      _addressFocus
    ]) {
      fn.dispose();
    }
    super.dispose();
  }

  // ── SAVE — writes to both ProfileManager AND Firestore ───
  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    HapticFeedback.lightImpact();

    final name    = _nameController.text.trim();
    final email   = _emailController.text.trim();
    final mobile  = _mobileController.text.trim();
    final address = _addressController.text.trim();

    // 1. Update local ProfileManager
    ProfileManager.updateField('name',    name);
    ProfileManager.updateField('email',   email);
    ProfileManager.updateField('mobile',  mobile);
    ProfileManager.updateField('address', address);
    await ProfileManager.saveProfile();

    // 2. Update Firestore so the drawer sees the new name immediately
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({
          'name':    name,
          'email':   email,
          'mobile':  mobile,
          'address': address,
        });
      }
    } catch (e) {
      // Firestore update failed — local save still succeeded
      debugPrint('Firestore update error: $e');
    }

    if (!mounted) return;
    setState(() {
      _isSaving  = false;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          SizedBox(width: 10),
          Text('Profile updated!',
              style: TextStyle(fontFamily: 'Outfit', fontSize: 14)),
        ]),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _cancelEdit() {
    _loadProfile();
    setState(() => _isEditing = false);
  }

  // ─────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final initials = ProfileManager.userName.isNotEmpty
        ? ProfileManager.userName
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .take(2)
        .join()
        : 'U';

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      stretch: true,
      backgroundColor: _navy,
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
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isEditing
                ? TextButton(
              key: const ValueKey('cancel'),
              onPressed: _cancelEdit,
              child: const Text('Cancel',
                  style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Outfit',
                      fontSize: 14)),
            )
                : GestureDetector(
              key: const ValueKey('edit'),
              onTap: () => setState(() => _isEditing = true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white30),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.edit_rounded,
                        color: Colors.white, size: 14),
                    SizedBox(width: 5),
                    Text('Edit',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_navy, _blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                  top: -40, right: -50, child: _circle(180, 0.05)),
              Positioned(
                  bottom: 10, left: -30, child: _circle(120, 0.04)),
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      FadeInDown(
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(
                                color: Colors.white38, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ProfileManager.profilePhoto != null
                              ? ClipOval(
                              child: Image.file(
                                  ProfileManager.profilePhoto!,
                                  fit: BoxFit.cover))
                              : Center(
                              child: Text(initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Outfit',
                                  ))),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // ── Live name — rebuilds when setState called ──
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          // Show the text field value while editing
                          // so the header updates in real time
                          _isEditing
                              ? (_nameController.text.isNotEmpty
                              ? _nameController.text
                              : ProfileManager.userName)
                              : ProfileManager.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FadeInUp(
                        duration: const Duration(milliseconds: 550),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            ProfileManager.role[0].toUpperCase() +
                                ProfileManager.role.substring(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Outfit',
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circle(double size, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity)),
  );

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            child: _buildInfoCard(),
          ),
          if (_isEditing) ...[
            const SizedBox(height: 16),
            FadeInUp(
              duration: const Duration(milliseconds: 450),
              child: _buildSaveButton(),
            ),
          ],
          const SizedBox(height: 24),
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: _buildAccountCard(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              border: Border(
                  bottom:
                  BorderSide(color: Colors.grey.shade100, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: _blue, size: 18),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _isEditing
                    ? _editField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  keyboard: TextInputType.name,
                  // rebuild header as user types
                  onChanged: (_) => setState(() {}),
                )
                    : _infoRow(Icons.person_outline_rounded, 'Full Name',
                    ProfileManager.userName),
                _divider(),
                _isEditing
                    ? _editField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  label: 'Email Address',
                  icon: Icons.alternate_email_rounded,
                  keyboard: TextInputType.emailAddress,
                )
                    : _infoRow(
                    Icons.alternate_email_rounded,
                    'Email Address',
                    ProfileManager.email),
                _divider(),
                _isEditing
                    ? _editField(
                  controller: _mobileController,
                  focusNode: _mobileFocus,
                  label: 'Mobile Number',
                  icon: Icons.phone_outlined,
                  keyboard: TextInputType.phone,
                  prefixText: '+91  ',
                )
                    : _infoRow(
                  Icons.phone_outlined,
                  'Mobile Number',
                  ProfileManager.mobile.isNotEmpty
                      ? '+91 ${ProfileManager.mobile}'
                      : 'Not set',
                ),
                _divider(),
                _isEditing
                    ? _editField(
                  controller: _addressController,
                  focusNode: _addressFocus,
                  label: 'Home Address',
                  icon: Icons.location_on_outlined,
                  keyboard: TextInputType.streetAddress,
                  maxLines: 2,
                )
                    : _infoRow(
                  Icons.location_on_outlined,
                  'Home Address',
                  ProfileManager.address.isNotEmpty
                      ? ProfileManager.address
                      : 'Not set',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Divider(color: Colors.grey.shade100, height: 1),
  );

  Widget _infoRow(IconData icon, String label, String value) {
    final isEmpty = value == 'Not set';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.grey.shade400, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontFamily: 'Outfit')),
                const SizedBox(height: 3),
                Text(value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isEmpty ? Colors.grey.shade400 : _navy,
                      fontFamily: 'Outfit',
                      fontStyle: isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    String? prefixText,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    final focused = focusNode.hasFocus;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: focused ? _blue : Colors.grey.shade200,
            width: focused ? 1.5 : 1,
          ),
          boxShadow: focused
              ? [
            BoxShadow(
                color: _blue.withOpacity(0.1), blurRadius: 10)
          ]
              : [],
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboard,
          maxLines: maxLines,
          onChanged: onChanged,
          style: const TextStyle(
              fontSize: 15, color: _navy, fontFamily: 'Outfit'),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
                color: focused ? _blue : Colors.grey.shade500,
                fontFamily: 'Outfit',
                fontSize: 13),
            prefixText: prefixText,
            prefixIcon: Icon(icon,
                color: focused ? _blue : Colors.grey.shade400,
                size: 18),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: maxLines > 1 ? 14 : 0),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: _isSaving
          ? Container(
        decoration: BoxDecoration(
          gradient:
          const LinearGradient(colors: [_navy, _blue]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2.5),
          ),
        ),
      )
          : ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_navy, _blue],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _blue.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_rounded,
                    color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Outfit',
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Colors.grey.shade100, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.shield_outlined,
                      color: Colors.green.shade600, size: 18),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Account Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _accountRow(
                  icon: Icons.verified_user_rounded,
                  iconColor: Colors.green.shade600,
                  bgColor: Colors.green.shade50,
                  label: 'Account Status',
                  value: 'Active',
                  valueColor: Colors.green.shade600,
                ),
                _divider(),
                _accountRow(
                  icon: Icons.badge_rounded,
                  iconColor: _blue,
                  bgColor: _blue.withOpacity(0.08),
                  label: 'Account Role',
                  value: ProfileManager.role[0].toUpperCase() +
                      ProfileManager.role.substring(1),
                  valueColor: _blue,
                ),
                _divider(),
                _accountRow(
                  icon: Icons.security_rounded,
                  iconColor: Colors.orange.shade600,
                  bgColor: Colors.orange.shade50,
                  label: 'Data & Privacy',
                  value: 'Protected',
                  valueColor: Colors.orange.shade700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountRow({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontFamily: 'Outfit')),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: valueColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                  fontFamily: 'Outfit',
                )),
          ),
        ],
      ),
    );
  }
}