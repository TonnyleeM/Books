# EcoBookHub 📚🌿

**A Sustainable Book Exchange Platform for Students**

EcoBookHub is a comprehensive Flutter-based mobile application that enables students to exchange textbooks in an eco-friendly marketplace. The app promotes sustainability by facilitating book swaps instead of purchases, reducing waste and making education more affordable.

## 📱 App Overview

EcoBookHub transforms the traditional textbook marketplace into a sustainable, community-driven platform where students can:
- List their unused textbooks for exchange
- Browse available books from other students
- Initiate swap offers and negotiate exchanges
- Chat with other users to coordinate swaps
- Manage their book collection and swap history

## 🎯 Assignment Requirements Fulfilled

This project successfully implements all requirements from Individual Assignment 2:

### ✅ **Authentication (Firebase Auth + Email Verification)**
- Complete user authentication flow with Firebase Auth
- Email/password registration and login
- Email verification enforcement (users cannot log in until verified)
- User profile creation and management
- Secure logout functionality

### ✅ **Book Listings (Full CRUD Operations)**
- **Create**: Post books with title, author, condition, and cover image
- **Read**: Browse all listings in a shared feed
- **Update**: Edit your own book listings
- **Delete**: Remove your own listings with confirmation

### ✅ **Swap Functionality & State Management**
- Initiate swap offers with a single tap
- Real-time state updates (Available → Pending → Swapped)
- Both users see instant updates via Firebase Firestore sync
- Provider state management for reactive UI updates

### ✅ **Navigation & Settings**
- Modern BottomNavigationBar with 5 screens:
  - **Dashboard**: Overview with stats and quick actions
  - **Explore Books**: Browse all available listings
  - **My Library**: Manage your book collection
  - **Community**: Swap offers and notifications
  - **Profile**: Settings and user preferences
- Toggle notification preferences
- Complete profile information display

### ✅ **Chat System (Bonus Feature)**
- Real-time messaging between users
- Chat initiated after swap offers
- Messages stored in Firebase Firestore
- Live message synchronization


**Why Provider?**
- Simple and efficient state management
- Built-in change notification system
- Excellent integration with Flutter widgets
- Perfect for Firebase real-time updates

### **Database Schema & Modeling**

#### **Users Collection**
```json
{
  "uid": "user_unique_id",
  "email": "user@email.com",
  "displayName": "User Name",
  "createdAt": "timestamp",
  "emailVerified": true,
  "booksListed": 5,
  "swapsCompleted": 3
}
```

#### **Books Collection**
```json
{
  "id": "book_unique_id",
  "title": "Book Title",
  "author": "Author Name",
  "condition": "New|Like New|Good|Used",
  "status": "available|pending|swapped",
  "ownerId": "user_uid",
  "imageUrl": "firebase_storage_url",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### **Swap Offers Collection**
```json
{
  "id": "offer_unique_id",
  "bookId": "target_book_id",
  "fromUserId": "requester_uid",
  "toUserId": "book_owner_uid",
  "status": "pending|accepted|rejected",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### **Chats Collection**
```json
{
  "chatId": "user1_uid_user2_uid",
  "participants": ["user1_uid", "user2_uid"],
  "lastMessage": "Latest message text",
  "lastMessageTime": "timestamp",
  "bookId": "related_book_id"
}
```

#### **Messages Subcollection**
```json
{
  "id": "message_unique_id",
  "senderId": "sender_uid",
  "text": "Message content",
  "timestamp": "timestamp",
  "read": false
}
```

## 🛠️ Installation & Setup

### **Prerequisites**
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Firebase Project Setup

### **Firebase Configuration**
1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Enable Authentication, Firestore, and Storage
3. Download configuration files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS
4. Update `firebase_options.dart` with your project configuration

### **Installation Steps**
```bash
# Clone the repository
git clone https://github.com/DLOADIN/Book-swap.git
cd Book-swap

# Install dependencies
flutter pub get

# Run the app
flutter run
```



## 🔧 Key Features Implemented

### **1. Authentication System**
- Firebase Auth integration
- Email verification requirement
- User profile management
- Persistent login state

### **2. Book Management (CRUD)**
- Create listings with image upload
- Browse all available books
- Edit own listings
- Delete with confirmation

### **3. Swap System**
- One-tap swap requests
- Real-time state updates
- Status tracking (Available → Pending → Swapped)
- Mutual visibility of swap states

### **4. Chat System**
- Real-time messaging
- Chat rooms for each swap
- Message persistence
- Read status tracking

### **5. Advanced UI Components**
- Custom navigation system
- Animated transitions
- Loading states
- Error handling
- Responsive design


## 🔮 Future Enhancements

1. **Advanced Search & Filtering**
   - Subject categories
   - Price range filters
   - Location-based filtering

2. **Rating System**
   - User ratings and reviews
   - Book condition verification
   - Trust scores

3. **Notification System**
   - Push notifications for swap offers
   - Chat message alerts
   - Listing expiration reminders

4. **Analytics Dashboard**
   - Swap statistics
   - Popular books tracking
   - User engagement metrics

## 👥 Contributing

This project was developed as part of Individual Assignment 2 for Mobile Application Development. The implementation demonstrates:

- **Clean Architecture** with separated concerns
- **SOLID Principles** in code organization
- **Firebase Best Practices** for real-time applications
- **Flutter UI/UX Standards** for mobile development

## 📄 License

This project is developed for educational purposes as part of a university assignment.

---

**EcoBookHub** - *Sustainable Learning Through Book Sharing* 🌱📖
