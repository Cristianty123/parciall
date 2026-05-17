// lib/screens/shared/chat_list_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/api_client.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<ConversationItem> _convs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    timeago.setLocaleMessages('es', timeago.EsMessages());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.get('/chat/conversations');
      if (res.statusCode == 200) {
        final list = json.decode(res.body) as List;
        setState(() =>
            _convs = list.map((e) => ConversationItem.fromJson(e)).toList());
      }
    } catch (_) {
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensajes')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _convs.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('No tienes conversaciones aún',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _convs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final c = _convs[i];
                        return ListTile(
                          leading: UserAvatar(
                              photoUrl: c.partnerPhoto, radius: 24),
                          title: Text(
                            c.partnerName ?? 'Usuario',
                            style: TextStyle(
                                fontWeight: c.unreadCount > 0
                                    ? FontWeight.bold
                                    : FontWeight.normal),
                          ),
                          subtitle: Text(
                            c.lastMessage ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: c.unreadCount > 0
                                    ? Colors.black87
                                    : Colors.grey),
                          ),
                          trailing: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            crossAxisAlignment:
                                CrossAxisAlignment.end,
                            children: [
                              if (c.lastMessageAt != null)
                                Text(
                                  _formatTime(c.lastMessageAt!),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey),
                                ),
                              if (c.unreadCount > 0) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF5C6BC0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Text(
                                    '${c.unreadCount}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                partnerId: c.partnerId,
                                partnerName:
                                    c.partnerName ?? 'Usuario',
                                partnerPhoto: c.partnerPhoto,
                              ),
                            ),
                          ).then((_) => _load()),
                        );
                      },
                    ),
            ),
    );
  }

  String _formatTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return timeago.format(dt, locale: 'es');
    } catch (_) {
      return '';
    }
  }
}
