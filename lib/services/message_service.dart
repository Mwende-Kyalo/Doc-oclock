import '../models/message_model.dart';

class MessageService {
  // Mock data for chat previews (for patients)
  static List<Map<String, dynamic>> _getMockChatPreviews() {
    final now = DateTime.now();
    return [
      {
        'chatId': '1',
        'doctorId': '1',
        'doctorName': 'Dr. Sarah Johnson',
        'doctorImageUrl': null,
        'lastMessage': 'Thank you for your appointment. Please follow the prescription.',
        'lastMessageTime': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'unreadCount': 2,
        'isOnline': true,
      },
      {
        'chatId': '2',
        'doctorId': '2',
        'doctorName': 'Dr. Michael Chen',
        'doctorImageUrl': null,
        'lastMessage': 'Your test results look good. We can discuss them in detail.',
        'lastMessageTime': now.subtract(const Duration(days: 1)).toIso8601String(),
        'unreadCount': 0,
        'isOnline': false,
      },
      {
        'chatId': '3',
        'doctorId': '3',
        'doctorName': 'Dr. Emily Rodriguez',
        'doctorImageUrl': null,
        'lastMessage': 'I recommend scheduling a follow-up appointment.',
        'lastMessageTime': now.subtract(const Duration(days: 3)).toIso8601String(),
        'unreadCount': 1,
        'isOnline': true,
      },
    ];
  }

  // Mock data for patient chat previews (for doctors)
  static List<Map<String, dynamic>> _getMockPatientChatPreviews() {
    final now = DateTime.now();
    return [
      {
        'chatId': '1',
        'patientId': '1',
        'patientName': 'John Doe',
        'patientImageUrl': null,
        'lastMessage': 'Thank you for your appointment. Please follow the prescription.',
        'lastMessageTime': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'unreadCount': 0,
        'isOnline': true,
      },
      {
        'chatId': '2',
        'patientId': '2',
        'patientName': 'Jane Smith',
        'patientImageUrl': null,
        'lastMessage': 'Your test results look good. We can discuss them in detail.',
        'lastMessageTime': now.subtract(const Duration(days: 1)).toIso8601String(),
        'unreadCount': 1,
        'isOnline': false,
      },
      {
        'chatId': '3',
        'patientId': '3',
        'patientName': 'Robert Williams',
        'patientImageUrl': null,
        'lastMessage': 'I recommend scheduling a follow-up appointment.',
        'lastMessageTime': now.subtract(const Duration(days: 3)).toIso8601String(),
        'unreadCount': 0,
        'isOnline': true,
      },
    ];
  }

  // Get chat previews (using mock data)
  // Note: Using mock data instead of API calls
  static Future<List<ChatPreviewModel>> getChatPreviews(
      String userId, {bool isDoctor = false}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (isDoctor) {
      // For doctors, return patient chat previews
      return _getMockPatientChatPreviews().map((json) {
        return ChatPreviewModel.fromJson({
          'chatId': json['chatId'] ?? '',
          'doctorId': json['patientId'] ?? '', // For doctors, this is patientId
          'doctorName': json['patientName'] ?? '', // For doctors, this is patientName
          'doctorImageUrl': json['patientImageUrl'],
          'lastMessage': json['lastMessage'] ?? '',
          'lastMessageTime': json['lastMessageTime'] ?? DateTime.now().toIso8601String(),
          'unreadCount': json['unreadCount'] ?? 0,
          'isOnline': json['isOnline'] ?? false,
        });
      }).toList();
    } else {
      // For patients, return doctor chat previews
      return _getMockChatPreviews().map((json) {
        return ChatPreviewModel.fromJson({
          'chatId': json['chatId'] ?? '',
          'doctorId': json['doctorId'] ?? '',
          'doctorName': json['doctorName'] ?? '',
          'doctorImageUrl': json['doctorImageUrl'],
          'lastMessage': json['lastMessage'] ?? '',
          'lastMessageTime': json['lastMessageTime'] ?? DateTime.now().toIso8601String(),
          'unreadCount': json['unreadCount'] ?? 0,
          'isOnline': json['isOnline'] ?? false,
        });
      }).toList();
    }
  }

  // Mock messages for different chats
  static Map<String, List<Map<String, dynamic>>> _getMockMessages() {
    final now = DateTime.now();
    return {
      '1': [
        {
          'id': '1',
          'senderId': '1',
          'senderName': 'Dr. Sarah Johnson',
          'receiverId': 'patient1',
          'receiverName': 'You',
          'message': 'Hello! How can I help you today?',
          'timestamp': now.subtract(const Duration(hours: 3)).toIso8601String(),
          'isRead': true,
          'type': 'text',
        },
        {
          'id': '2',
          'senderId': 'patient1',
          'senderName': 'You',
          'receiverId': '1',
          'receiverName': 'Dr. Sarah Johnson',
          'message': 'I have been experiencing some symptoms.',
          'timestamp': now.subtract(const Duration(hours: 2, minutes: 45)).toIso8601String(),
          'isRead': true,
          'type': 'text',
        },
        {
          'id': '3',
          'senderId': '1',
          'senderName': 'Dr. Sarah Johnson',
          'receiverId': 'patient1',
          'receiverName': 'You',
          'message': 'I understand. Can you describe them in more detail?',
          'timestamp': now.subtract(const Duration(hours: 2, minutes: 30)).toIso8601String(),
          'isRead': true,
          'type': 'text',
        },
        {
          'id': '4',
          'senderId': '1',
          'senderName': 'Dr. Sarah Johnson',
          'receiverId': 'patient1',
          'receiverName': 'You',
          'message': 'Thank you for your appointment. Please follow the prescription.',
          'timestamp': now.subtract(const Duration(hours: 2)).toIso8601String(),
          'isRead': false,
          'type': 'text',
        },
      ],
      '2': [
        {
          'id': '5',
          'senderId': '2',
          'senderName': 'Dr. Michael Chen',
          'receiverId': 'patient1',
          'receiverName': 'You',
          'message': 'Your test results look good. We can discuss them in detail.',
          'timestamp': now.subtract(const Duration(days: 1)).toIso8601String(),
          'isRead': true,
          'type': 'text',
        },
      ],
      '3': [
        {
          'id': '6',
          'senderId': 'patient1',
          'senderName': 'You',
          'receiverId': '3',
          'receiverName': 'Dr. Emily Rodriguez',
          'message': 'When can I schedule a follow-up?',
          'timestamp': now.subtract(const Duration(days: 3)).toIso8601String(),
          'isRead': true,
          'type': 'text',
        },
        {
          'id': '7',
          'senderId': '3',
          'senderName': 'Dr. Emily Rodriguez',
          'receiverId': 'patient1',
          'receiverName': 'You',
          'message': 'I recommend scheduling a follow-up appointment.',
          'timestamp': now.subtract(const Duration(days: 3, hours: -1)).toIso8601String(),
          'isRead': false,
          'type': 'text',
        },
      ],
    };
  }
  
  // Store mock messages in memory (will persist during app session)
  static final Map<String, List<Map<String, dynamic>>> _mockMessages = {};

  // Get messages for a specific appointment (chat) - using mock data
  static Future<List<MessageModel>> getChatMessages(String appointmentId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Initialize mock messages if not already done
    if (_mockMessages.isEmpty) {
      _mockMessages.addAll(_getMockMessages());
    }
    
    final messages = _mockMessages[appointmentId] ?? [];
    
    return messages.map((json) => MessageModel.fromJson({
      'id': json['id'] ?? '',
      'chatId': appointmentId,
      'senderId': json['senderId'] ?? '',
      'senderName': json['senderName'] ?? '',
      'receiverId': json['receiverId'] ?? '',
      'receiverName': json['receiverName'] ?? '',
      'message': json['message'] ?? '',
      'timestamp': json['timestamp'] ?? DateTime.now().toIso8601String(),
      'isRead': json['isRead'] ?? false,
      'type': json['type'] ?? 'text',
    })).toList();
  }

  // Send a message (using mock data - just returns the message without saving)
  static Future<MessageModel> sendMessage({
    required String appointmentId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String message,
    String type = 'text',
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Initialize mock messages if not already done
    if (_mockMessages.isEmpty) {
      _mockMessages.addAll(_getMockMessages());
    }
    
    // Generate a mock message ID
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Add to mock messages if chat exists
    if (_mockMessages.containsKey(appointmentId)) {
      _mockMessages[appointmentId]!.add({
        'id': messageId,
        'senderId': senderId,
        'senderName': senderName,
        'receiverId': receiverId,
        'receiverName': receiverName,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
        'type': type,
      });
    } else {
      // Create new chat
      _mockMessages[appointmentId] = [
        {
          'id': messageId,
          'senderId': senderId,
          'senderName': senderName,
          'receiverId': receiverId,
          'receiverName': receiverName,
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
          'isRead': false,
          'type': type,
        },
      ];
    }
    
    return MessageModel.fromJson({
      'id': messageId,
      'chatId': appointmentId,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
      'type': type,
    });
  }

  // Get or create chat using appointment_id (using mock data)
  static Future<String> getOrCreateChat(
      String patientId, String doctorId, {String? appointmentId}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));
    
    // If appointmentId is provided, use it
    if (appointmentId != null && appointmentId.isNotEmpty) {
      return appointmentId;
    }
    
    // Initialize mock messages if not already done
    if (_mockMessages.isEmpty) {
      _mockMessages.addAll(_getMockMessages());
    }
    
    // For mock data, generate a chat ID based on patient and doctor IDs
    // This ensures consistent chat IDs for the same patient-doctor pair
    final chatId = '${patientId}_$doctorId';
    
    // Initialize mock messages if chat doesn't exist
    if (!_mockMessages.containsKey(chatId)) {
      _mockMessages[chatId] = [];
    }
    
    return chatId;
  }
}
