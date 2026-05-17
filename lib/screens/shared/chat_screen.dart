// lib/screens/shared/chat_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class ChatScreen extends StatefulWidget {
  final int partnerId;
  final String partnerName;
  final String? partnerPhoto;

  const ChatScreen({
    super.key,
    required this.partnerId,
    required this.partnerName,
    this.partnerPhoto,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> _messages = [];
  bool _loading = true;
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  int? _myId;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadMyId();
    _loadMessages();
    _markRead();
    // Auto-refresh every 5s (simple polling)
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadMessages(silent: true),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMyId() async {
    try {
      final res = await ApiClient.get('/users/me');
      if (res.statusCode == 200) {
        setState(() => _myId = json.decode(res.body)['id']);
      }
    } catch (_) {}
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final res = await ApiClient.get(
          '/chat/messages/${widget.partnerId}',
          {'page': '0', 'size': '50'});
      if (res.statusCode == 200) {
        final paged = PagedResponse.fromJson(
            json.decode(res.body), ChatMessage.fromJson);
        // Messages come newest first; reverse for display
        final msgs = paged.content.reversed.toList();
        setState(() => _messages = msgs);
        _scrollToBottom();
      }
    } catch (_) {
    } finally {
      if (!silent) setState(() => _loading = false);
    }
  }

  Future<void> _markRead() async {
    try {
      await ApiClient.patch('/chat/messages/read/${widget.partnerId}');
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    try {
      final res = await ApiClient.post('/chat/messages',
          {'receiverId': widget.partnerId, 'content': text});
      if (res.statusCode == 201) {
        await _loadMessages(silent: true);
      }
    } catch (_) {}
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            UserAvatar(photoUrl: widget.partnerPhoto, radius: 16),
            const SizedBox(width: 10),
            Text(widget.partnerName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final m = _messages[i];
                      final isMe = _myId != null && m.senderId == _myId;
                      return _MessageBubble(message: m, isMe: isMe);
                    },
                  ),
          ),
          _InputBar(
            controller: _msgCtrl,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: const Offset(0, 1)),
          ],
        ),
        child: Text(
          message.content,
          style: TextStyle(
              color: isMe ? Colors.white : Colors.black87, fontSize: 15),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, -1))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                maxLines: null,
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              mini: true,
              onPressed: onSend,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
