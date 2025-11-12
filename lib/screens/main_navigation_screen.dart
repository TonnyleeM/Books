import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'explore_books_screen.dart';
import 'my_library_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late AnimationController _slideController;

  final List<NavTab> _tabs = [
    NavTab(
      icon: Icons.home_rounded,
      label: 'Home',
      screen: const DashboardScreen(),
    ),
    NavTab(
      icon: Icons.search_rounded,
      label: 'Discover',
      screen: const ExploreBooksScreen(),
    ),
    NavTab(
      icon: Icons.bookmark_rounded,
      label: 'Library',
      screen: const MyLibraryScreen(),
    ),
    NavTab(
      icon: Icons.notifications_rounded,
      label: 'Notifications',
      screen: const NotificationsScreen(),
    ),
    NavTab(
      icon: Icons.account_circle_rounded,
      label: 'Profile',
      screen: const ProfileScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: _tabs.map((tab) => tab.screen).toList(),
          ),
          if (_selectedIndex == 1)
            Positioned(
              bottom: 100,
              right: 20,
              child: FloatingActionButton(
                onPressed: () => Navigator.pushNamed(context, '/add-book'),
                child: const Icon(Icons.add_rounded),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;
                final isSelected = _selectedIndex == index;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onTabTapped(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              tab.icon,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tab.label,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class NavTab {
  final IconData icon;
  final String label;
  final Widget screen;

  NavTab({
    required this.icon,
    required this.label,
    required this.screen,
  });
}