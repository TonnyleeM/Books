import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart';
import '../models/book.dart';
import '../widgets/modern_book_card.dart';

class SwapSelectionScreen extends StatelessWidget {
  final Book targetBook;

  const SwapSelectionScreen({super.key, required this.targetBook});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final bookProvider = Provider.of<BookProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Book to Swap'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Target book info
          Container(
            padding: const EdgeInsets.all(20),
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            child: Row(
              children: [
                Icon(
                  Icons.swap_horiz,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select one of your books to swap for "${targetBook.title}"',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // User's available books
          Expanded(
            child: StreamBuilder<List<Book>>(
              stream: bookProvider.myBooks(auth.user?.uid ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading your books',
                          style: TextStyle(
                            fontSize: 18,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final myBooks = snapshot.data ?? [];
                final availableBooks = myBooks.where((book) => 
                  book.status == 'available' && book.id != targetBook.id
                ).toList();

                if (availableBooks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.library_books_outlined,
                          size: 80,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No Available Books',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You need available books to make a swap',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/add-book');
                          },
                          child: const Text('Add a Book'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: availableBooks.length,
                  itemBuilder: (context, index) {
                    final book = availableBooks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Card(
                        child: InkWell(
                          onTap: () => _showSwapConfirmation(context, book, targetBook, bookProvider, auth),
                          borderRadius: BorderRadius.circular(12),
                          child: ModernBookCard(
                            book: book,
                            onTap: () => _showSwapConfirmation(context, book, targetBook, bookProvider, auth),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSwapConfirmation(
    BuildContext context,
    Book myBook,
    Book targetBook,
    BookProvider bookProvider,
    AuthProvider auth,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Swap Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You want to swap:'),
            const SizedBox(height: 8),
            Text(
              '"${myBook.title}" by ${myBook.author}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('For:'),
            const SizedBox(height: 8),
            Text(
              '"${targetBook.title}" by ${targetBook.author}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'This will send a swap request to the book owner.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close swap selection screen
              
              try {
                await bookProvider.createSwapRequest(
                  requesterId: auth.user!.uid,
                  requesterBookId: myBook.id,
                  targetBookId: targetBook.id,
                  targetOwnerId: targetBook.ownerId,
                );
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Swap request sent!'),
                      backgroundColor: Colors.green,
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
              }
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }
}