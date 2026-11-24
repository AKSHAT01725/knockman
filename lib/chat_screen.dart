// lib/chat_screen.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'profile_manager.dart';

class ChatScreen extends StatefulWidget {
  final String orderId;
  final String otherPartyName;
  final String serviceName;

  const ChatScreen({
    Key? key,
    required this.orderId,
    required this.otherPartyName,
    required this.serviceName,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin {

  // ── palette ──────────────────────────────────────────────
  static const Color _navy    = Color(0xFF0D2137);
  static const Color _blue    = Color(0xFF1565C0);
  static const Color _surface = Color(0xFFF0F4FA);

  // ── state ────────────────────────────────────────────────
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  String _myUid = '';
  bool _isSending = false;
  bool _hasText = false;

  // typing indicator animation
  late AnimationController _typingDotCtrl;

  @override
  void initState() {
    super.initState();
    _myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _typingDotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _textController.addListener(() {
      final has = _textController.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    // mark messages read when screen opens
    _markRead();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingDotCtrl.dispose();
    super.dispose();
  }

  CollectionReference get _chatRef => FirebaseFirestore.instance
      .collection('orders')
      .doc(widget.orderId)
      .collection('messages');

  Future<void> _markRead() async {
    // optionally update unread count in order doc
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({'unread_$_myUid': 0});
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;
    HapticFeedback.lightImpact();
    setState(() => _isSending = true);
    _textController.clear();
    try {
      await _chatRef.add({
        'text':      text,
        'senderId':  _myUid,
        'senderName': ProfileManager.userName,
        'timestamp': FieldValue.serverTimestamp(),
        'type':      'text',
      });
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to send: $e',
              style: const TextStyle(fontFamily: 'Outfit')),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animated) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 80,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent + 80);
        }
      }
    });
  }

  String _serviceEmoji(String service) {
    final s = service.toLowerCase();
    if (s.contains('clean'))  return '🧹';
    if (s.contains('plumb') || s.contains('pipe')) return '🔧';
    if (s.contains('ac') || s.contains('gas'))    return '❄️';
    if (s.contains('paint'))  return '🖌️';
    if (s.contains('furni'))  return '🪑';
    if (s.contains('pest'))   return '🦟';
    return '🏠';
  }

  // ─────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: Column(
        children: [
          _buildAppBar(),
          _buildServiceBanner(),
          Expanded(child: _buildMessageList()),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  APP BAR
  // ─────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    final initials = widget.otherPartyName.trim().split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .take(2).join();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_navy, _blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // decorative circle
            Positioned(top: -20, right: -20,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
              child: Row(
                children: [
                  // back button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                  ),

                  // avatar
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                      border: Border.all(color: Colors.white30, width: 1.5),
                    ),
                    child: Center(
                      child: Text(initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Outfit',
                          )),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // name + status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.otherPartyName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Outfit',
                              letterSpacing: -0.2,
                            )),

                      ],
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

  // ─────────────────────────────────────────────────────────
  //  SERVICE BANNER
  // ─────────────────────────────────────────────────────────
  Widget _buildServiceBanner() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(_serviceEmoji(widget.serviceName),
                  style: const TextStyle(fontSize: 17)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.serviceName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _navy,
                      fontFamily: 'Outfit',
                    )),
                Text('Order #${widget.orderId.substring(0, 8).toUpperCase()}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                      fontFamily: 'Outfit',
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Text('Active',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.green.shade700,
                  fontFamily: 'Outfit',
                )),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  MESSAGE LIST
  // ─────────────────────────────────────────────────────────
  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatRef
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  color: _blue, strokeWidth: 2.5));
        }

        final docs = snap.data?.docs ?? [];

        if (docs.isEmpty) {
          return _buildEmptyChat();
        }

        // auto-scroll on new message
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final doc  = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            final isMe = (data['senderId'] ?? '') == _myUid;

            // show date divider if this is first msg or date changed
            bool showDate = false;
            if (i == 0) {
              showDate = true;
            } else {
              final prevData =
              docs[i - 1].data() as Map<String, dynamic>;
              final prevTs =
              (prevData['timestamp'] as Timestamp?)?.toDate();
              final curTs =
              (data['timestamp'] as Timestamp?)?.toDate();
              if (prevTs != null && curTs != null) {
                showDate = curTs.day != prevTs.day ||
                    curTs.month != prevTs.month;
              }
            }

            return Column(
              children: [
                if (showDate) _buildDateDivider(
                    (data['timestamp'] as Timestamp?)?.toDate()),
                FadeInUp(
                  duration: const Duration(milliseconds: 200),
                  child: _buildBubble(data, isMe),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline_rounded,
                size: 36, color: _blue.withOpacity(0.4)),
          ),
          const SizedBox(height: 16),
          const Text('No messages yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _navy,
                fontFamily: 'Outfit',
              )),
          const SizedBox(height: 6),
          Text('Say hello to get the conversation started!',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade400,
                fontFamily: 'Outfit',
              )),
        ],
      ),
    );
  }

  Widget _buildDateDivider(DateTime? date) {
    String label = 'Today';
    if (date != null) {
      final now = DateTime.now();
      final diff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(date.year, date.month, date.day))
          .inDays;
      if (diff == 1) {
        label = 'Yesterday';
      } else if (diff > 1) {
        label =
        '${date.day} ${_monthName(date.month)} ${date.year}';
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
              child: Divider(
                  color: Colors.grey.shade200, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border:
                Border.all(color: Colors.grey.shade200),
              ),
              child: Text(label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400,
                    fontFamily: 'Outfit',
                  )),
            ),
          ),
          Expanded(
              child: Divider(
                  color: Colors.grey.shade200, thickness: 1)),
        ],
      ),
    );
  }

  String _monthName(int m) => const [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ][m];

  // ─────────────────────────────────────────────────────────
  //  BUBBLE
  // ─────────────────────────────────────────────────────────
  Widget _buildBubble(Map<String, dynamic> data, bool isMe) {
    final text = (data['text'] ?? '').toString();
    final ts   = (data['timestamp'] as Timestamp?)?.toDate();
    final timeStr = ts != null
        ? '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}'
        : '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 2, bottom: 2,
          left:  isMe ? 60 : 0,
          right: isMe ? 0 : 60,
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // bubble
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              decoration: BoxDecoration(
                color: isMe ? _blue : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(18),
                  topRight:    const Radius.circular(18),
                  bottomLeft:  Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isMe
                        ? _blue.withOpacity(0.25)
                        : Colors.black.withOpacity(0.06),
                    blurRadius: isMe ? 10 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(text,
                  style: TextStyle(
                    fontSize: 14,
                    color: isMe ? Colors.white : _navy,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  )),
            ),

            // timestamp + read tick
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(timeStr,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                        fontFamily: 'Outfit',
                      )),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.done_all_rounded,
                        size: 13, color: Colors.blue.shade400),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  INPUT BAR
  // ─────────────────────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 46, maxHeight: 120),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  fontSize: 14,
                  color: _navy,
                  fontFamily: 'Outfit',
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontFamily: 'Outfit',
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // send button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46, height: 46,
            decoration: BoxDecoration(
              gradient: _hasText
                  ? const LinearGradient(
                colors: [_navy, _blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null,
              color: _hasText ? null : Colors.grey.shade200,
              shape: BoxShape.circle,
              boxShadow: _hasText
                  ? [
                BoxShadow(
                  color: _blue.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
                  : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _hasText ? _sendMessage : null,
                borderRadius: BorderRadius.circular(23),
                child: Center(
                  child: _isSending
                      ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : Icon(
                    Icons.send_rounded,
                    size: 19,
                    color: _hasText
                        ? Colors.white
                        : Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}