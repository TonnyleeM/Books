import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart';
import '../models/book.dart';
import '../widgets/modern_book_card.dart';
import 'swap_selection_screen.dart';

class MyLibraryScreen extends StatefulWidget {
  const MyLibraryScreen({super.key});

  @override
  State<MyLibraryScreen> createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends State<MyLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final bookProvider = Provider.of<BookProvider>(context);
    
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: theme.colorScheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  Icons.library_books_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'My Library',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Manage your book collection',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              FloatingActionButton(
                                mini: true,
                                heroTag: "add_book_fab",
                                onPressed: () {
                                  Navigator.pushNamed(context, '/add-book');
                                },
                                backgroundColor: Colors.white.withOpacity(0.2),
                                foregroundColor: Colors.white,
                                child: const Icon(Icons.add_rounded),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.7),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                tabs: const [
                  Tab(text: 'My Books'),
                  Tab(text: 'Saved'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Swapped'),
                  Tab(text: 'Swaps'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMyBooksList(auth, bookProvider, theme),
            _buildSavedBooksList(auth, bookProvider, theme),
            _buildBooksList('pending', auth, bookProvider, theme),
            _buildBooksList('swapped', auth, bookProvider, theme),
            _buildSwapRequestsList(auth, bookProvider, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksList(String status, AuthProvider auth, 
                        BookProvider bookProvider, ThemeData theme) {
    return StreamBuilder<List<Book>>(
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
                  Icons.library_books_outlined,
                  size: 64,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading your library...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/add-book'),
                  child: const Text('Add Your First Book'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allBooks = snapshot.data!;
        final filteredBooks = allBooks.where((book) => book.status == status).toList();

        if (filteredBooks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getEmptyStateIcon(status),
                  size: 80,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  _getEmptyStateTitle(status),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getEmptyStateSubtitle(status),
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (status == 'available') ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/add-book');
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Your First Book'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: filteredBooks.length,
          itemBuilder: (context, index) {
            final book = filteredBooks[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ModernBookCard(
                book: book,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/book-detail',
                    arguments: book,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  IconData _getEmptyStateIcon(String status) {
    switch (status) {
      case 'available':
        return Icons.library_add_outlined;
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'swapped':
        return Icons.swap_horiz_rounded;
      default:
        return Icons.book_outlined;
    }
  }

  String _getEmptyStateTitle(String status) {
    switch (status) {
      case 'available':
        return 'No Available Books';
      case 'pending':
        return 'No Pending Swaps';
      case 'swapped':
        return 'No Completed Swaps';
      default:
        return 'No Books';
    }
  }

  String _getEmptyStateSubtitle(String status) {
    switch (status) {
      case 'available':
        return 'Add books to your library to start\nsharing with the community';
      case 'pending':
        return 'Books waiting for swap confirmation\nwill appear here';
      case 'swapped':
        return 'Your completed book swaps\nwill be shown here';
      default:
        return '';
    }
  }

  Widget _buildMyBooksList(AuthProvider auth, BookProvider bookProvider, ThemeData theme) {
    return StreamBuilder<List<Book>>(
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
                Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text('Error loading books', style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface)),
              ],
            ),
          );
        }

        final books = snapshot.data ?? [];
        if (books.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.library_add_outlined, size: 80, color: theme.colorScheme.primary.withOpacity(0.5)),
                const SizedBox(height: 24),
                Text('No Books Yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 8),
                Text('Add your first book to get started', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/add-book'),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Book'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ModernBookCard(
                book: book,
                onTap: () => Navigator.pushNamed(context, '/book-detail', arguments: book),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSavedBooksList(AuthProvider auth, BookProvider bookProvider, ThemeData theme) {
    return StreamBuilder<List<Book>>(
      stream: bookProvider.savedBooks(auth.user?.uid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final books = snapshot.data ?? [];
        if (books.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border, size: 80, color: theme.colorScheme.primary.withOpacity(0.5)),
                const SizedBox(height: 24),
                Text('No Saved Books', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 8),
                Text('Books you save will appear here', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                child: ModernBookCard(
                  book: book,
                  showOwner: true,
                  onTap: () => Navigator.pushNamed(context, '/book-detail', arguments: book),
                  trailing: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/swap-selection', arguments: book),
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text('Swap'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSwapRequestsList(AuthProvider auth, BookProvider bookProvider, ThemeData theme) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: bookProvider.pendingSwapRequests(auth.user?.uid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swap_horiz, size: 80, color: theme.colorScheme.primary.withOpacity(0.5)),
                const SizedBox(height: 24),
                Text('No Swap Requests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 8),
                Text('Incoming swap requests will appear here', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Swap Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                    const SizedBox(height: 8),
                    Text('Someone wants to swap with your book', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              await bookProvider.declineSwapRequest(request['id']);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Swap declined'), backgroundColor: Colors.orange),
                                );
                              }
                            },
                            child: const Text('Decline'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await bookProvider.acceptSwapRequest(request['id']);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Swap accepted!'), backgroundColor: Colors.green),
                                );
                              }
                            },
                            child: const Text('Accept'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}