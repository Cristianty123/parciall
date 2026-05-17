import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/chat_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatelessWidget {
  static const routeName = '/chat-list';

  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chats')),
        body: const Center(child: Text('Inicia sesión para ver tus chats.')),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: StreamBuilder<List<ChatModel>>(
        stream: context.read<ChatProvider>().chatsStream(user.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snap.data ?? [];

          if (chats.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 72, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aún no tienes conversaciones.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Contacta a un emprendedor desde un servicio.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final chat = chats[index];
              final otherName = chat.getOtherParticipantName(user.uid);
              final otherPhoto = chat.getOtherParticipantPhoto(user.uid);
              final otherId = chat.getOtherParticipantId(user.uid);
              final unread = chat.getUnreadCount(user.uid);

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                leading: CircleAvatar(
                  radius: 26,
                  backgroundImage: otherPhoto != null
                      ? NetworkImage(otherPhoto)
                      : null,
                  child: otherPhoto == null
                      ? Text(otherName.isNotEmpty
                          ? otherName[0].toUpperCase()
                          : '?')
                      : null,
                ),
                title: Text(
                  otherName,
                  style: TextStyle(
                    fontWeight: unread > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (chat.serviceTitle != null)
                      Text(
                        chat.serviceTitle!,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF4F46E5)),
                      ),
                    Text(
                      chat.lastMessage.isEmpty
                          ? 'Sin mensajes aún'
                          : chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: unread > 0
                            ? Colors.black87
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(chat.lastMessageAt),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    if (unread > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4F46E5),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unread',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    ChatDetailScreen.routeName,
                    arguments: {
                      'chatId': chat.id,
                      'otherUserId': otherId,
                      'otherUserName': otherName,
                      'otherUserPhoto': otherPhoto,
                    },
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Ayer';
    } else if (diff.inDays < 7) {
      const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return days[dt.weekday - 1];
    }
    return '${dt.day}/${dt.month}';
  }
}
