import 'package:flutter/material.dart';
import 'responsive_utils.dart';
import 'services/api_service.dart';

class MessagesPage extends StatefulWidget {
  final String? bookingId;
  final String recipientId;
  final String recipientName;
  final String recipientType; // 'customer', 'cleaner', 'admin'
  final Map<String, dynamic>? bookingDetails;

  const MessagesPage({
    super.key,
    this.bookingId,
    required this.recipientId,
    required this.recipientName,
    required this.recipientType,
    this.bookingDetails,
  });

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, dynamic>> messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<dynamic> loadedMessages;

      if (widget.recipientType == 'admin') {
        loadedMessages = await ApiService.getAdminMessages();
      } else if (widget.bookingId != null) {
        loadedMessages = await ApiService.getMessagesForBooking(widget.bookingId!);
      } else {
        loadedMessages = [];
      }

      setState(() {
        messages = loadedMessages.map((m) => Map<String, dynamic>.from(m)).toList();
        _isLoading = false;
      });

      // Scroll to bottom after loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      // If loading fails, just show empty messages - don't show error
      // This allows the user to still try sending messages
      setState(() {
        messages = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      await ApiService.sendMessage(
        bookingId: widget.bookingId,
        recipientId: widget.recipientId,
        recipientType: widget.recipientType,
        message: messageText,
      );

      _messageController.clear();
      
      // Reload messages to show the new one
      await _loadMessages();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to send message: $e');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        // Today - show time
        final hour = dateTime.hour.toString().padLeft(2, '0');
        final minute = dateTime.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${dateTime.day} ${months[dateTime.month - 1]}';
      }
    } catch (e) {
      return '';
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, ResponsiveUtils responsive) {
    final userData = message['sender'] as Map<String, dynamic>?;
    final isMe = message['isFromCurrentUser'] ?? false;
    final messageText = message['message'] ?? '';
    final timestamp = message['createdAt'];

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: responsive.spacing(4),
          horizontal: responsive.spacing(12),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: responsive.spacing(14),
          vertical: responsive.spacing(10),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.green.shade500 : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: isMe ? Radius.circular(16) : Radius.circular(4),
            bottomRight: isMe ? Radius.circular(4) : Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe && userData != null) ...[
              Text(
                userData['name'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: responsive.responsiveFontSize(11),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: responsive.spacing(4)),
            ],
            Text(
              messageText,
              style: TextStyle(
                fontSize: responsive.responsiveFontSize(14),
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: responsive.spacing(4)),
            Text(
              _formatTimestamp(timestamp),
              style: TextStyle(
                fontSize: responsive.responsiveFontSize(10),
                color: isMe ? Colors.white.withOpacity(0.8) : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.recipientName,
              style: TextStyle(
                fontSize: responsive.responsiveFontSize(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.bookingDetails != null) ...[
              Text(
                widget.bookingDetails!['service']?['title'] ?? '',
                style: TextStyle(
                  fontSize: responsive.responsiveFontSize(12),
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Booking info banner (if applicable)
          if (widget.bookingDetails != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(responsive.spacing(12)),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                  SizedBox(width: responsive.spacing(8)),
                  Expanded(
                    child: Text(
                      'Booking: ${widget.bookingDetails!['bookingId'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: responsive.responsiveFontSize(12),
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: responsive.spacing(12)),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: responsive.responsiveFontSize(16),
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: responsive.spacing(8)),
                            Text(
                              'Start the conversation!',
                              style: TextStyle(
                                fontSize: responsive.responsiveFontSize(14),
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMessages,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(vertical: responsive.spacing(8)),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            return _buildMessageBubble(messages[index], responsive);
                          },
                        ),
                      ),
          ),

          // Message input
          Container(
            padding: EdgeInsets.all(responsive.spacing(12)),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
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
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: Colors.green.shade400),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: responsive.spacing(16),
                          vertical: responsive.spacing(10),
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      enabled: !_isSending,
                    ),
                  ),
                  SizedBox(width: responsive.spacing(8)),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isSending
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                      onPressed: _isSending ? null : _sendMessage,
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
