import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/firestore_service.dart';

class ChatProvider extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  Stream<List<ChatModel>> chatsStream(String userId) =>
      _fs.chatsStream(userId);

  Stream<List<MessageModel>> messagesStream(String chatId) =>
      _fs.messagesStream(chatId);

  Future<String?> openOrCreateChat({
    required String currentUserId,
    required String currentUserName,
    required String? currentUserPhoto,
    required String otherUserId,
    required String otherUserName,
    required String? otherUserPhoto,
    String? serviceId,
    String? serviceTitle,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final chatId = await _fs.getOrCreateChat(
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        currentUserPhoto: currentUserPhoto,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
        otherUserPhoto: otherUserPhoto,
        serviceId: serviceId,
        serviceTitle: serviceTitle,
      );
      _loading = false;
      notifyListeners();
      return chatId;
    } catch (e) {
      _error = 'No se pudo abrir el chat: $e';
      _loading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
    required String otherUserId,
  }) async {
    if (content.trim().isEmpty) return;
    try {
      await _fs.sendMessage(
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        content: content.trim(),
        otherUserId: otherUserId,
      );
    } catch (e) {
      _error = 'Error al enviar mensaje.';
      notifyListeners();
    }
  }

  Future<void> markAsRead(String chatId, String userId) async {
    await _fs.markAsRead(chatId, userId);
  }
}
