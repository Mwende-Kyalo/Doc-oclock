import '../models/message_model.dart';
import 'api_service.dart';
// ...existing code...

class MessageService {
  // Get chat previews for a patient
  static Future<List<ChatPreviewModel>> getChatPreviews(
      String patientId) async {
    try {
      final response =
          await ApiService.get('messages/chats.php?patient_id=$patientId');
      if (response['data'] is List) {
        return (response['data'] as List)
            .map((json) => ChatPreviewModel.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to fetch chat previews: $e');
    }
  }

  // Get messages for a specific chat
  static Future<List<MessageModel>> getChatMessages(String chatId) async {
    try {
      final response = await ApiService.get('messages/get.php?chat_id=$chatId');
      if (response['data'] is List) {
        return (response['data'] as List)
            .map((json) => MessageModel.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  // Send a message
  static Future<MessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String message,
    String type = 'text',
  }) async {
    try {
      final response = await ApiService.post('messages/send.php', {
        'chat_id': chatId,
        'sender_id': senderId,
        'sender_name': senderName,
        'receiver_id': receiverId,
        'receiver_name': receiverName,
        'message': message,
        'type': type,
      });
      if (response['data'] != null) {
        return MessageModel.fromJson(response['data']);
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Create or get chat with doctor
  static Future<String> getOrCreateChat(
      String patientId, String doctorId) async {
    try {
      final response = await ApiService.post('messages/create_chat.php', {
        'patient_id': patientId,
        'doctor_id': doctorId,
      });
      if (response['data'] != null && response['data']['chatId'] != null) {
        return response['data']['chatId'];
      } else {
        throw Exception('Failed to create/get chat');
      }
    } catch (e) {
      throw Exception('Failed to create/get chat: $e');
    }
  }
}
