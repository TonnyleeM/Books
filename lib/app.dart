import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'models/book.dart';
import 'screens/auth_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/post_book_screen.dart';
import 'screens/book_detail_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/swap_selection_screen.dart';
import 'screens/saved_books_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
      ],
      child: Consumer<AuthProvider>(builder: (context, auth, _) {
        Widget home;
        
        if (auth.isSignedIn) {
          home = const MainNavigationScreen();
        } else if (auth.isSignedInButUnverified) {
          home = EmailVerificationScreen(email: auth.user?.email ?? '');
        } else {
          home = const AuthScreen();
        }

        return MaterialApp(
          title: 'BookNexus',
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
          onGenerateRoute: (settings) {
            try {
              switch (settings.name) {
                case '/book-detail':
                  final args = settings.arguments;
                  if (args is Book) {
                    return MaterialPageRoute(builder: (_) => BookDetailScreen(book: args));
                  }
                  break;
                case '/swap-selection':
                  final args = settings.arguments;
                  if (args is Book) {
                    return MaterialPageRoute(builder: (_) => SwapSelectionScreen(targetBook: args));
                  }
                  break;
              }
              return null;
            } catch (e) {
              return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
            }
          },
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Inter',
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1), // Indigo
              primaryContainer: Color(0xFF8B5CF6), // Purple
              secondary: Color(0xFF06B6D4), // Cyan
              secondaryContainer: Color(0xFFE0E7FF), // Light Indigo
              tertiary: Color(0xFF10B981), // Emerald
              surface: Color(0xFFFAFAFA), // Light Gray
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Color(0xFF1F2937), // Dark Gray
              error: Color(0xFFEF4444), // Red
              outline: Color(0xFFE5E7EB),
            ),
            scaffoldBackgroundColor: const Color(0xFFF9FAFB),
            cardTheme: CardThemeData(
              elevation: 0,
              color: Colors.white,
              shadowColor: Colors.black.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: const Color(0xFFE5E7EB).withOpacity(0.5),
                  width: 1,
                ),
              ),
            ),
            iconTheme: const IconThemeData(
              color: Color(0xFF6366F1),
              size: 24,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              foregroundColor: Color(0xFF111827),
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                color: Color(0xFF111827),
                fontSize: 28,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
              iconTheme: IconThemeData(
                color: Color(0xFF6366F1),
              ),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6366F1),
                side: const BorderSide(color: Color(0xFF6366F1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
            ),
            textTheme: const TextTheme(
              displayLarge: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
                height: 1.2,
              ),
              displayMedium: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                height: 1.3,
              ),
              headlineLarge: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
                height: 1.3,
              ),
              headlineMedium: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
                height: 1.4,
              ),
              titleLarge: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
                height: 1.4,
              ),
              bodyLarge: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF374151),
                height: 1.5,
              ),
              bodyMedium: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ),
          home: home,
          routes: {
            '/home': (ctx) => const MainNavigationScreen(),
            '/auth': (ctx) => const AuthScreen(),
            '/verify': (ctx) => EmailVerificationScreen(
              email: auth.user?.email ?? '',
            ),
            '/add-book': (ctx) => const PostBookScreen(),
            '/book-detail': (ctx) {
              final args = ModalRoute.of(ctx)?.settings.arguments;
              if (args is Book) {
                return BookDetailScreen(book: args);
              }
              return const MainNavigationScreen();
            },
            '/chat': (ctx) => const ChatScreen(),
            '/browse': (ctx) => const MainNavigationScreen(),
            '/swap-selection': (ctx) {
              final args = ModalRoute.of(ctx)?.settings.arguments;
              if (args is Book) {
                return SwapSelectionScreen(targetBook: args);
              }
              return const MainNavigationScreen();
            },
            '/saved-books': (ctx) => const SavedBooksScreen(),
          },
        );
      }),
    );
  }
}
