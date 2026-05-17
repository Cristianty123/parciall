import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.createdAt,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'senderName': senderName,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

class ChatModel {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String?> participantPhotos;
  final String lastMessage;
  final DateTime lastMessageAt;
  final String? serviceId;
  final String? serviceTitle;
  final Map<String, int> unreadCount;

  const ChatModel({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantPhotos,
    required this.lastMessage,
    required this.lastMessageAt,
    this.serviceId,
    this.serviceTitle,
    this.unreadCount = const {},
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      participantNames: Map<String, String>.from(data['participantNames'] ?? {}),
      participantPhotos: Map<String, String?>.from(data['participantPhotos'] ?? {}),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      serviceId: data['serviceId'],
      serviceTitle: data['serviceTitle'],
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
    );
  }

  String getOtherParticipantId(String myId) =>
      participantIds.firstWhere((id) => id != myId, orElse: () => '');

  String getOtherParticipantName(String myId) {
    final otherId = getOtherParticipantId(myId);
    return participantNames[otherId] ?? 'Usuario';
  }

  String? getOtherParticipantPhoto(String myId) {
    final otherId = getOtherParticipantId(myId);
    return participantPhotos[otherId];
  }

  int getUnreadCount(String myId) => unreadCount[myId] ?? 0;
}
