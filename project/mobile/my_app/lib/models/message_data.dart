import 'package:meta/meta.dart';

@immutable
class MessageData {
  const MessageData({
    required this.senderName,
    required this.message,
    required this.dateMessage,
    required this.messageDate, 
    required this.chatId,
    required this. profilePicture
  });

  final String senderName;
  final String message;
  final DateTime messageDate;
  final String dateMessage;
  final String chatId;
  final String profilePicture;
}