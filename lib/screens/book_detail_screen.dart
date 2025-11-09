import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import 'edit_book_screen.dart';
import 'chat_screen.dart' show ChatDetailScreen;

class BookDetailScreen extends StatefulWidget {
  final Book book;
  
  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _isRequestingSwap = false;
  bool _isOpeningChat = false;
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final bookProv = Provider.of<BookProvider>(context, listen: false);
    final firestore = FirestoreService();
    final theme = Theme.of(context);
    
    final isMine = widget.book.ownerId == auth.user?.uid;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Book Image
              Container(
                height: 300,
                width: double.infinity,
                color: theme.colorScheme.surfaceVariant,
                child: widget.book.imageUrl.isNotEmpty
                    ? widget.book.imageUrl.startsWith('data:image')
                        ? Image.memory(
                            base64Decode(widget.book.imageUrl.split(',')[1]),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder(theme);
                            },
                          )
                        : Image.network(
                            widget.book.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholder(theme);
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: theme.colorScheme.primary,
                                ),
                              );
                            },
                          )
                    : _buildPlaceholder(theme),
              ),
              // Book Details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.book.title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Author
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.book.author,
                            style: TextStyle(
                              fontSize: 18,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Condition Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getConditionColor(widget.book.condition, theme).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getConditionColor(widget.book.condition, theme).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getConditionIcon(widget.book.condition),
                            size: 16,
                            color: _getConditionColor(widget.book.condition, theme),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.book.condition,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _getConditionColor(widget.book.condition, theme),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(widget.book.status, theme).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(widget.book.status, theme).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(widget.book.status),
                            size: 14,
                            color: _getStatusColor(widget.book.status, theme),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.book.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(widget.book.status, theme),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Action Buttons
                    if (isMine)
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditBookScreen(book: widget.book),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showSwapOptions(context, auth),
                                  icon: const Icon(Icons.swap_horiz, size: 18),
                                  label: const Text('Swap'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isDeleting ? null : () => _handleDelete(context, bookProv),
                              icon: _isDeleting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.delete_outline, size: 18),
                              label: Text(_isDeleting ? 'Deleting...' : 'Delete'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.error,
                                side: BorderSide(color: theme.colorScheme.error),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          if (widget.book.status == 'available')
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isRequestingSwap
                                    ? null
                                    : () => _handleRequestSwap(context, bookProv, auth),
                                icon: _isRequestingSwap
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Icon(Icons.swap_horiz, size: 18),
                                label: Text(_isRequestingSwap ? 'Requesting...' : 'Request Swap'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          if (widget.book.status == 'available') const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isOpeningChat
                                  ? null
                                  : () => _handleChat(context, firestore, auth),
                              icon: _isOpeningChat
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.chat_bubble_outline, size: 18),
                              label: Text(_isOpeningChat ? 'Opening...' : 'Chat'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.5),
            theme.colorScheme.secondaryContainer.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 80,
              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
            ),
            const SizedBox(height: 8),
            Text(
              'No Image',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onPrimaryContainer.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, BookProvider bookProv) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Are you sure you want to delete this book? This action cannot be undone.'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isDeleting = true);
      try {
        await bookProv.deleteBook(widget.book.id);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Book deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting book: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isDeleting = false);
        }
      }
    }
  }

  Future<void> _handleRequestSwap(
      BuildContext context, BookProvider bookProv, AuthProvider auth) async {
    if (auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to request a swap'),
          backgroundColor: Colors.red,
          padding: EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isRequestingSwap = true);
    try {
      await bookProv.createSwapOffer(
        bookId: widget.book.id,
        fromUid: auth.user!.uid,
        toUid: widget.book.ownerId,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Swap requested!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRequestingSwap = false);
      }
    }
  }

  Future<void> _handleChat(
      BuildContext context, FirestoreService firestore, AuthProvider auth) async {
    if (auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to chat'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isOpeningChat = true);
    try {
      // Get or create chat ID
      final chatId = _getChatId(auth.user!.uid, widget.book.ownerId);
      
      // Ensure chat exists
      try {
        await firestore.ensureChatExists(
          chatId: chatId,
          userId1: auth.user!.uid,
          userId2: widget.book.ownerId,
          bookId: widget.book.id,
        );
      } catch (e) {
        // Chat might already exist, continue anyway
      }

      // Get other user's name
      final otherUserName = await firestore.getUserName(widget.book.ownerId) ?? 'User';

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              chatId: chatId,
              otherUserId: widget.book.ownerId,
              otherUserName: otherUserName,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isOpeningChat = false);
      }
    }
  }

  String _getChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  void _showSwapOptions(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SwapOptionsSheet(book: widget.book, auth: auth),
    );
  }

  Color _getConditionColor(String condition, ThemeData theme) {
    switch (condition.toLowerCase()) {
      case 'new':
        return Colors.green;
      case 'like new':
        return Colors.blue;
      case 'good':
        return Colors.orange;
      case 'used':
        return Colors.grey;
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _getConditionIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'new':
        return Icons.star_rounded;
      case 'like new':
        return Icons.star_half_rounded;
      case 'good':
        return Icons.check_circle_outline_rounded;
      case 'used':
        return Icons.book_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'swapped':
        return Colors.blue;
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.pending;
      case 'swapped':
        return Icons.swap_horiz;
      default:
        return Icons.info_outline;
    }
  }
}

class _SwapOptionsSheet extends StatefulWidget {
  final Book book;
  final AuthProvider auth;

  const _SwapOptionsSheet({required this.book, required this.auth});

  @override
  State<_SwapOptionsSheet> createState() => _SwapOptionsSheetState();
}

class _SwapOptionsSheetState extends State<_SwapOptionsSheet> {
  final _firestore = FirestoreService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Swap "${widget.book.title}"',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose who you want to swap with:',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _firestore.streamReceivedSwapOffers(widget.auth.user?.uid ?? ''),
            builder: (context, snapshot) {
              final offers = snapshot.data ?? [];
              
              if (offers.isEmpty) {
                return Column(
                  children: [
                    Icon(
                      Icons.swap_horiz,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No swap requests yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Users need to request swaps first',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                );
              }
              
              return Column(
                children: [
                  ...offers.map((offer) => _buildOfferTile(offer, theme)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOfferTile(Map<String, dynamic> offer, ThemeData theme) {
    return FutureBuilder<String?>(
      future: _firestore.getUserName(offer['from'] ?? ''),
      builder: (context, snapshot) {
        final userName = snapshot.data ?? 'User';
        final status = offer['state'] ?? 'pending';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  userName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Status: ${status.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (status == 'pending')
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _handleDecline(offer),
                      icon: const Icon(Icons.close, color: Colors.red),
                      tooltip: 'Decline',
                    ),
                    IconButton(
                      onPressed: () => _handleAccept(offer),
                      icon: const Icon(Icons.check, color: Colors.green),
                      tooltip: 'Accept',
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleAccept(Map<String, dynamic> offer) async {
    setState(() => _isLoading = true);
    try {
      await _firestore.acceptSwapOffer(offer['id'], offer['bookId']);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Swap accepted!'),
            backgroundColor: Colors.green,
          ),
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDecline(Map<String, dynamic> offer) async {
    setState(() => _isLoading = true);
    try {
      await _firestore.declineSwapOffer(offer['id'], offer['bookId']);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Swap declined'),
            backgroundColor: Colors.orange,
          ),
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

