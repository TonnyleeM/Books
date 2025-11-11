import 'package:flutter/material.dart';

class BookGlobeLogo extends StatelessWidget {
  final double size;
  
  const BookGlobeLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2196F3), // Blue
            Color(0xFF4CAF50), // Green
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Book icons arranged in a globe pattern
          _buildBookIcon(0.5, 0.1, 0.8), // Top center
          _buildBookIcon(0.2, 0.25, 0.7), // Top left
          _buildBookIcon(0.8, 0.25, 0.7), // Top right
          _buildBookIcon(0.1, 0.5, 0.6), // Middle left
          _buildBookIcon(0.9, 0.5, 0.6), // Middle right
          _buildBookIcon(0.3, 0.75, 0.7), // Bottom left
          _buildBookIcon(0.7, 0.75, 0.7), // Bottom right
          _buildBookIcon(0.5, 0.9, 0.8), // Bottom center
        ],
      ),
    );
  }

  Widget _buildBookIcon(double x, double y, double opacity) {
    return Positioned(
      left: size * x - 12,
      top: size * y - 8,
      child: Opacity(
        opacity: opacity,
        child: const Icon(
          Icons.menu_book_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}