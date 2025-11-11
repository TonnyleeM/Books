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
    // Validate required fields
    if (ownerId.isEmpty || title.isEmpty || author.isEmpty) {
      throw Exception('Missing required fields');
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
        // If imageUrl is still empty, something went wrong but we'll continue without image
        if (imageUrl.isEmpty) {
          imageUrl = '';
        }
      } catch (e) {
        // If image upload fails, continue without image
        // The error message should indicate what happened
        imageUrl = '';
        // Don't throw - allow book to be created without image
      }
    }
    
    final book = Book(
      id: id,
      ownerId: ownerId,
      title: title,
      author: author,
      condition: condition,
      imageUrl: imageUrl,
      status: 'available',
    );
    
    try {
      await _db.createBook(book);
    } catch (e) {
      // Re-throw Firestore errors so UI can show them
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
