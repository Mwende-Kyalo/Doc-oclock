import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/message_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/patient_scaffold.dart';
import 'package:go_router/go_router.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<ChatPreviewModel> _chatPreviews = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChatPreviews();
  }

  Future<void> _loadChatPreviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final chatPreviews = await MessageService.getChatPreviews(authProvider.user!.id);
      setState(() {
        _chatPreviews = chatPreviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PatientScaffold(
      title: 'Messages',
      currentRoute: '/patient/messages',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_errorMessage'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadChatPreviews,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadChatPreviews,
                  child: _chatPreviews.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text(
                                'No messages yet',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _chatPreviews.length,
                          itemBuilder: (context, index) {
                            final chat = _chatPreviews[index];
                            return _buildChatPreviewCard(chat);
                          },
                        ),
                ),
    );
  }

  Widget _buildChatPreviewCard(ChatPreviewModel chat) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppTheme.primaryBlue,
              child: Text(
                chat.doctorName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (chat.isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          chat.doctorName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          chat.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(chat.lastMessageTime),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (chat.unreadCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${chat.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          context.push('/patient/chat/${chat.chatId}?doctorName=${Uri.encodeComponent(chat.doctorName)}&doctorId=${chat.doctorId}');
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE').format(dateTime);
    } else {
      return DateFormat('MMM dd').format(dateTime);
    }
  }
}

