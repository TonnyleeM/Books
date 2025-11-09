import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/message.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUserName(String uid, String name) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String?> getUserName(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['name'] as String?;
  }

  Stream<List<Book>> streamAllBooks() {
    // Get all books and filter client-side to avoid index issues
    return _db
        .collection('books')
        .snapshots()
        .map((snap) {
          try {
            final books = snap.docs.map((d) {
              try {
                final book = Book.fromDoc(d);
                // Only return books with status 'available'
                return book.status == 'available' ? book : null;
              } catch (e) {
                // Skip invalid documents
                return null;
              }
            }).whereType<Book>().toList();
            return books;
          } catch (e) {
            // Return empty list on error
            return <Book>[];
          }
        });
  }

  Stream<List<Book>> streamUserBooks(String uid) {
    if (uid.isEmpty) {
      return Stream.value(<Book>[]);
    }
    return _db
        .collection('books')
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          try {
            return snap.docs.map((d) {
              try {
                return Book.fromDoc(d);
              } catch (e) {
                return null;
              }
            }).whereType<Book>().toList();
          } catch (e) {
            return <Book>[];
          }
        });
  }

  Future<void> createBook(Book book) async {
    await _db.collection('books').add(book.toMap());
  }

  Future<void> updateBook(String id, Map<String, dynamic> data) async {
    await _db.collection('books').doc(id).update(data);
  }

  Future<void> deleteBook(String id) async {
    await _db.collection('books').doc(id).delete();
  }

  // Swap offer
  Future<void> createSwapOffer(
      {required String bookId,
      required String fromUid,
      required String toUid}) async {
    try {
      // Create swap offer
      final swapRef = _db.collection('swaps').doc();
      await swapRef.set({
        'bookId': bookId,
        'from': fromUid,
        'to': toUid,
        'state': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Update book status
      await updateBook(bookId, {'status': 'pending'});
      
      // Create or update chat room
      final chatId = _getChatId(fromUid, toUid);
      await _db.collection('chats').doc(chatId).set({
        'participants': [fromUid, toUid],
        'lastMessage': 'Swap request sent',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'bookId': bookId,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create swap offer: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> streamChats(String uid) {
    // Get all chats where user is a participant, then sort client-side
    return _db
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snap) {
          final chats = snap.docs.map((d) {
            final data = d.data();
            return {
              'id': d.id,
              ...data,
            };
          }).toList();
          
          // Sort by lastMessageTime descending (most recent first)
          chats.sort((a, b) {
            final timeA = a['lastMessageTime'] as Timestamp?;
            final timeB = b['lastMessageTime'] as Timestamp?;
            if (timeA == null && timeB == null) return 0;
            if (timeA == null) return 1;
            if (timeB == null) return -1;
            return timeB.compareTo(timeA);
          });
          
          return chats;
        });
  }

  Stream<List<Map<String, dynamic>>> streamMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) {
          try {
            return snap.docs.map((d) {
              final data = d.data();
              return {
                'id': d.id,
                ...data,
              };
            }).toList();
          } catch (e) {
            return <Map<String, dynamic>>[];
          }
        });
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    try {
      // Add message to subcollection
      await _db.collection('chats').doc(chatId).collection('messages').add({
        'senderId': senderId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Update chat last message
      await _db.collection('chats').doc(chatId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<List<Message>> getMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) {
          try {
            return snap.docs.map((d) {
              try {
                return Message.fromMap(d.data(), d.id);
              } catch (e) {
                return null;
              }
            }).whereType<Message>().toList();
          } catch (e) {
            return <Message>[];
          }
        });
  }

  String _getChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  // Swap offers
  Stream<List<Map<String, dynamic>>> streamReceivedSwapOffers(String uid) {
    return _db
        .collection('swaps')
        .where('to', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          try {
            return snap.docs.map((d) {
              final data = d.data();
              return {
                'id': d.id,
                ...data,
              };
            }).toList();
          } catch (e) {
            return <Map<String, dynamic>>[];
          }
        });
  }

  Stream<List<Map<String, dynamic>>> streamSentSwapOffers(String uid) {
    return _db
        .collection('swaps')
        .where('from', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          try {
            return snap.docs.map((d) {
              final data = d.data();
              return {
                'id': d.id,
                ...data,
              };
            }).toList();
          } catch (e) {
            return <Map<String, dynamic>>[];
          }
        });
  }

  Future<Book?> getBook(String bookId) async {
    try {
      final doc = await _db.collection('books').doc(bookId).get();
      if (!doc.exists) return null;
      return Book.fromDoc(doc);
    } catch (e) {
      return null;
    }
  }

  Future<void> acceptSwapOffer(String swapId, String bookId) async {
    try {
      // Update swap status
      await _db.collection('swaps').doc(swapId).update({
        'state': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });
      
      // Update book status to swapped
      await updateBook(bookId, {'status': 'swapped'});
    } catch (e) {
      throw Exception('Failed to accept swap offer: $e');
    }
  }

  Future<void> declineSwapOffer(String swapId, String bookId) async {
    try {
      // Update swap status
      await _db.collection('swaps').doc(swapId).update({
        'state': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
      });
      
      // Update book status back to available
      await updateBook(bookId, {'status': 'available'});
    } catch (e) {
      throw Exception('Failed to decline swap offer: $e');
    }
  }

  Future<void> ensureChatExists({
    required String chatId,
    required String userId1,
    required String userId2,
    required String bookId,
  }) async {
    final chatRef = _db.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();
    
    if (!chatDoc.exists) {
      await chatRef.set({
        'participants': [userId1, userId2],
        'lastMessage': 'Chat started',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'bookId': bookId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      // Delete all messages in the chat
      final messagesRef = _db
          .collection('chats')
          .doc(chatId)
          .collection('messages');
      
      final messagesSnapshot = await messagesRef.get();
      for (var doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Delete the chat document
      await _db.collection('chats').doc(chatId).delete();
    } catch (e) {
      throw Exception('Failed to delete chat: $e');
    }
  }
}
