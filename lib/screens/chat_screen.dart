import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Messages',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search_rounded),
                    ),
                  ),
                ],
              ),
            ),
            
            // Chat List
            Expanded(
              child: Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  if (auth.user == null) {
                    return const Center(
                      child: Text('Please sign in to view chats'),
                    );
                  }
                  
                  return StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _firestoreService.streamChats(auth.user!.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }
                      
                      final chats = snapshot.data ?? [];
                      
                      if (chats.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No chats yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Chats are created when you:',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '• Request a swap on a book',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              const Text(
                                '• Click "Chat" on a book detail',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/browse');
                                },
                                child: const Text('Browse Books'),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final chat = chats[index];
                          return _buildChatTile(chat, theme, auth.user!.uid);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat, ThemeData theme, String currentUserId) {
    final participants = List<String>.from(chat['participants'] ?? []);
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => 'Unknown',
    );
    
    return FutureBuilder<String?>(
      future: _firestoreService.getUserName(otherUserId),
      builder: (context, snapshot) {
        final displayName = snapshot.data ?? 'User';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                displayName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (chat['unread'] == true)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      chat['lastMessage'] ?? 'No messages yet',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (chat['lastMessageTime'] != null)
                    Text(
                      _formatTime(chat['lastMessageTime'].toDate()),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatDetailScreen(
                    chatId: chat['id'],
                    otherUserName: displayName,
                    otherUserId: otherUserId,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  final String? otherUserId;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
    this.otherUserId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user == null) return;
    
    setState(() => _isLoading = true);
    _messageController.clear();
    
    try {
      await _firestoreService.sendMessage(
        chatId: widget.chatId,
        senderId: auth.user!.uid,
        text: text,
      );
      
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                widget.otherUserName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(widget.otherUserName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _firestoreService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                
                final messages = snapshot.data ?? [];
                
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Start the conversation!'),
                  );
                }
                
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    final isMe = message.senderId == auth.user?.uid;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe
                                ? theme.colorScheme.primary
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 16),
                            ),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _isLoading ? null : _sendMessage,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}