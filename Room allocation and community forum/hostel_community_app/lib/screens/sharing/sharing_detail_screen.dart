import 'package:flutter/material.dart';
import '../../models/sharing.dart';
import '../../models/sharing_reply.dart';
import '../../services/api_service.dart';

class SharingDetailScreen extends StatefulWidget {
  final Sharing sharing;

  const SharingDetailScreen({super.key, required this.sharing});

  @override
  State<SharingDetailScreen> createState() => _SharingDetailScreenState();
}

class _SharingDetailScreenState extends State<SharingDetailScreen> {
  late Future<List<dynamic>> _repliesFuture;
  final TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReplies();
  }

  void _loadReplies() {
    setState(() {
      _repliesFuture = ApiService.getSharingReplies(widget.sharing.id);
    });
  }

  Future<void> _addReply() async {
    if (_replyController.text.trim().isEmpty) return;

    try {
      await ApiService.addSharingReply(
        widget.sharing.id,
        _replyController.text.trim(),
      );
      _replyController.clear();
      _loadReplies();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reply added!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'borrow':
        return Colors.blue;
      case 'lend':
        return Colors.green;
      case 'request':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'borrow':
        return Icons.arrow_downward;
      case 'lend':
        return Icons.arrow_upward;
      case 'request':
        return Icons.help_outline;
      default:
        return Icons.swap_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor(widget.sharing.type);
    final icon = _getTypeIcon(widget.sharing.type);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sharing Details'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(color: color.withOpacity(0.3)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.sharing.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.sharing.type.toUpperCase(),
                            style: TextStyle(
                              color: color,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.sharing.description,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Posted by ${widget.sharing.postedBy}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '•',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.sharing.createdAt.split('T').first,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Replies Section
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _repliesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 8),
                        Text('Error: ${snapshot.error}'),
                        TextButton(
                          onPressed: _loadReplies,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final replies = snapshot.data ?? [];

                if (replies.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'No replies yet',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Be the first to reply!',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: replies.length,
                  itemBuilder: (context, index) {
                    final reply = SharingReply.fromJson(replies[index]);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: color.withOpacity(0.2),
                                  child: Icon(
                                    Icons.person,
                                    size: 18,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reply.userId,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        reply.createdAt.split('T').first,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              reply.message,
                              style: const TextStyle(fontSize: 14, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Reply Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
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
                      controller: _replyController,
                      decoration: InputDecoration(
                        hintText: 'Write a reply...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: _addReply,
                    mini: true,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }
}