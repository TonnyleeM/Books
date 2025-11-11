import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class BookProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();
  final StorageService _storage = StorageService();

  Stream<List<Book>> allBooks() => _db.streamAllBooks();

  Stream<List<Book>> myBooks(String uid) => _db.streamUserBooks(uid);

  Future<void> postBook({
    required String ownerId,
    required String title,
    required String author,
    required String condition,
    File? image,
    Uint8List? webImage,
  }) async {
    // Validate required fields more thoroughly
    if (ownerId.trim().isEmpty) {
      throw Exception('Owner ID cannot be empty');
    }
    if (title.trim().isEmpty) {
      throw Exception('Title cannot be empty');
    }
    if (author.trim().isEmpty) {
      throw Exception('Author cannot be empty');
    }
    if (condition.trim().isEmpty) {
      throw Exception('Condition cannot be empty');
    }
    
    final id = const Uuid().v4();
    String imageUrl = '';
    
    // Upload image if provided
    if (image != null || webImage != null) {
      try {
        if (webImage != null) {
          imageUrl = await _storage.uploadWebImage(webImage, id);
        } else if (image != null) {
          imageUrl = await _storage.uploadBookImage(image, id);
        }
      } catch (e) {
        // If image upload fails, continue without image
        imageUrl = '';
      }
    }
    
    // Ensure all values are non-null
    final bookData = {
      'ownerId': ownerId.trim(),
      'title': title.trim(),
      'author': author.trim(),
      'condition': condition.trim(),
      'imageUrl': imageUrl,
      'status': 'available',
    };
    
    final book = Book(
      id: id,
      ownerId: ownerId.trim(),
      title: title.trim(),
      author: author.trim(),
      condition: condition.trim(),
      imageUrl: imageUrl,
      status: 'available',
    );
    
    try {
      await _db.createBook(book);
    } catch (e) {
      print('Error creating book: $e');
      print('Book data: ${book.toMap()}');
      throw Exception('Failed to create book: $e');
    }
  }

  Future<void> deleteBook(String id) async => await _db.deleteBook(id);

  Future<void> updateBook({
    required String bookId,
    required String title,
    required String author,
    required String condition,
    File? image,
    String? existingImageUrl,
  }) async {
    String imageUrl = existingImageUrl ?? '';
    
    // Upload new image if provided
    if (image != null) {
      try {
        imageUrl = await _storage.uploadBookImage(image, bookId);
        if (imageUrl.isEmpty) {
          imageUrl = existingImageUrl ?? '';
        }
      } catch (e) {
        // If image upload fails, keep existing image if available
        if (existingImageUrl == null || existingImageUrl.isEmpty) {
          imageUrl = '';
        } else {
          imageUrl = existingImageUrl;
        }
      }
    }
    
    // Update book data
    final updateData = {
      'title': title,
      'author': author,
      'condition': condition,
      'imageUrl': imageUrl,
    };
    
    try {
      await _db.updateBook(bookId, updateData);
    } catch (e) {
      throw Exception('Failed to update book: $e');
    }
  }

  Future<void> createSwapOffer(
      {required String bookId,
      required String fromUid,
      required String toUid}) async {
    await _db.createSwapOffer(bookId: bookId, fromUid: fromUid, toUid: toUid);
    notifyListeners();
  }
}
