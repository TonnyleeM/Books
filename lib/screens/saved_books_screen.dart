import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart';
import '../models/book.dart';
import '../widgets/modern_book_card.dart';
import 'book_detail_screen.dart';

class SavedBooksScreen extends StatelessWidget {
  const SavedBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final bookProvider = Provider.of<BookProvider>(context);
    
    if (auth.user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Saved Books'),
          elevation: 0,
        ),
        body: const Center(
          child: Text('Please sign in to view saved books'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Books'),
        elevation: 0,
      ),
      body: StreamBuilder<List<Book>>(
        stream: bookProvider.savedBooks(auth.user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Saved books error: ${snapshot.error}');
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
                    'Error loading saved books',
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Trigger rebuild
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SavedBooksScreen()),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final savedBooks = snapshot.data ?? <Book>[];

          if (savedBooks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 80,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Saved Books',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Books you save will appear here',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: savedBooks.length,
            itemBuilder: (context, index) {
              final book = savedBooks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ModernBookCard(
                  book: book,
                  showOwner: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookDetailScreen(book: book),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}