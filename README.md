# AmritaFind - Lost & Found Platform for Amrita University

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-orange?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green)](#license)
[![Status](https://img.shields.io/badge/Status-Active-success)](#)

A comprehensive mobile application designed to help Amrita University students locate lost items and report found items on campus.

[Features](#features) • [Installation](#installation) • [Usage](#usage) • [Architecture](#architecture)

</div>

---

## 📋 Problem Statement

Amrita University campus spans multiple locations with thousands of students. When students lose personal items—wallets, ID cards, books, water bottles—they have no centralized platform to:

- **Report lost items** and provide detailed descriptions
- **Search for found items** reported by other students
- **Connect directly** with those who've found their items
- **Verify item ownership** through security questions
- **Receive intelligent assistance** in locating items through AI

This lack of a coordinated system results in lost items remaining unclaimed and frustration for affected students.

---

## 💡 Solution

**AmritaFind** is a Flutter-based mobile application that creates a community-driven Lost & Found platform specifically for Amrita University. It bridges the gap between students who've lost items and those who've found them, featuring:

- **Real-time item listings** with Firebase Firestore integration
- **AI-powered chatbot** assistance using Google Gemini API
- **Secure authentication** via Firebase Auth with Outlook integration
- **Image-based item documentation** with Firebase Storage
- **Location and time-based filtering** for precise item searches
- **Direct messaging** between students
- **User profiles** with academic information (department, year, roll number)

---

## ✨ Key Features

### 1. **User Authentication**
- Firebase-based email/password authentication
- Outlook/Microsoft Account sign-in support
- Secure profile management with academic details

### 2. **Lost & Found Posting**
- Create lost or found item posts with:
  - Item name and detailed description
  - Multiple image uploads (up to 5 images)
  - Location selection from 10+ campus locations
  - Contact information
  - Secret questions for ownership verification
- Real-time Firestore database synchronization

### 3. **Smart Search & Filtering**
- Filter by status (Lost/Found/All)
- Location-based search
- Date range filtering
- Text-based search across item names and descriptions
- Multiple sorting options (date, relevance)

### 4. **AI-Powered Chatbot**
- Integrated Google Gemini API assistant
- Context-aware responses about lost/found items
- Real-time chat interface
- Environmental variable-based API configuration

### 5. **Direct Messaging**
- Peer-to-peer chat between students
- Real-time message synchronization
- User avatar display

### 6. **User Profile Management**
- View personal information:
  - Full name
  - Department
  - Academic year
  - Roll number (formatted as: `CB.SC.U4CSE29999`)
- Edit profile details
- View personal lost & found posts
- Activity tracking

### 7. **Responsive Design**
- Mobile-optimized UI
- Smooth animations and transitions
- Light theme with custom color scheme
- Adaptive layouts for various screen sizes

---

## 🏗️ Architecture

```
lostandfound/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── firebase_options.dart              # Firebase configuration
│   ├── pages/
│   │   ├── onboarding_screen.dart         # Welcome & feature overview
│   │   ├── login_page.dart                # Authentication screen
│   │   ├── home_page.dart                 # Main feed with filtering
│   │   ├── post_item_form_page.dart       # Create lost/found posts
│   │   ├── profile_page.dart              # User profile & posts
│   │   ├── chat_page.dart                 # Direct messaging
│   │   └── chat_bot_page.dart             # AI chatbot interface
│   └── services/
│       ├── auth_service.dart              # Firebase authentication
│       └── ai_service.dart                # Google Gemini integration
├── android/                               # Android platform code
├── ios/                                   # iOS platform code
└── pubspec.yaml                           # Dependencies configuration
```

### Technology Stack

| Component | Technology |
|-----------|-----------|
| Frontend | Flutter 3.0+ |
| Backend | Firebase (Auth, Firestore, Storage) |
| AI/ML | Google Gemini 2.5 Flash API |
| State Management | StatefulWidget |
| Image Upload | Firebase Storage |
| Real-time DB | Cloud Firestore |

---

## 🚀 Installation

### Prerequisites

- **Flutter SDK** 3.0 or higher ([Download](https://flutter.dev/docs/get-started/install))
- **Dart** 3.0+ (included with Flutter)
- **Firebase Account** ([Create Free Account](https://firebase.google.com))
- **Google Gemini API Key** ([Get API Key](https://ai.google.dev))

### Step 1: Clone the Repository

```bash
git clone https://github.com/SarvanthiSivaraj/AmritaFind.git
cd AmritaFind/lostandfound
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Configure Firebase

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Add Android, iOS, and Web apps to your Firebase project
3. The Firebase configuration is already included in `lib/firebase_options.dart`
4. Enable the following Firebase services:
   - **Authentication** (Email/Password, Google)
   - **Cloud Firestore** (Database)
   - **Storage** (for image uploads)

### Step 4: Setup Environment Variables

1. Create a `.env` file in the `lostandfound/` directory:

```bash
cp .env.example .env
```

2. Add your Google Gemini API key to `.env`:

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

### Step 5: Run the Application

#### For Android:
```bash
flutter run -d android
```

#### For iOS:
```bash
flutter run -d ios
```

#### For Web:
```bash
flutter run -d chrome
```

---

## 📱 Usage

### First-Time Users

1. **Onboarding**: Review the welcome screens to understand app features
2. **Login/Sign-up**: Create an account using email or Outlook
3. **Complete Profile**: Add your department, year, and roll number

### Finding Lost Items

1. Navigate to the **Home** tab
2. Use filters to narrow results:
   - Select "Found" status
   - Choose location where you lost the item
   - Set date range
3. Browse matching items and contact the finder

### Posting a Lost Item

1. Tap the **Create Post** button
2. Fill in item details:
   - Item name (e.g., "Blue Water Bottle")
   - Detailed description
   - Campus location
   - Contact information
   - Add up to 5 photos
3. Set a security question for ownership verification
4. Submit to make it visible to all users

### Using the AI Chatbot

1. Go to the **Chatbot** section
2. Ask questions like:
   - "I lost my ID card, what should I do?"
   - "Where can I find common items?"
3. Get AI-powered suggestions and guidance

### Direct Messaging

1. Find an item post that matches yours
2. Tap the user to open chat
3. Send messages directly to confirm item details

---

## 🔐 Security & Privacy

- **Authentication**: Secure Firebase authentication with password encryption
- **Data Privacy**: User data stored securely in Firestore
- **Image Security**: Images uploaded to Firebase Storage with proper permissions
- **Verification**: Secret questions prevent false claims
- **API Keys**: Sensitive keys managed through environment variables (`.env`)

---

## 📊 Database Schema

### Collections

#### `users`
```json
{
  "name": "Priya Sharma",
  "department": "CB.SC.U4CSE",
  "year": "29",
  "rollNumber": "9999",
  "contact": "+1 234 567 890",
  "email": "priya@amrita.edu",
  "timestamp": "2025-12-07T10:30:00Z"
}
```

#### `lost_items` / `found_items`
```json
{
  "userId": "user123",
  "item_name": "Blue Water Bottle",
  "description": "Insulated blue water bottle with white cap",
  "location": "AB1",
  "contact": "+1 234 567 890",
  "secret_question": "What's the brand?",
  "status": "Lost",
  "imageUrls": ["url1", "url2"],
  "timestamp": "2025-12-07T09:15:00Z"
}
```

---

## 🐛 Known Issues & Roadmap

### Current Limitations
- Outlook integration requires Azure AD configuration
- Image uploads limited to 5 per post

### Planned Features (v2.0)
- [ ] Push notifications for item matches
- [ ] Advanced location mapping (Google Maps integration)
- [ ] Item condition photos with AI analysis
- [ ] Reputation/rating system
- [ ] QR code-based item tracking
- [ ] SMS notifications
- [ ] Offline mode support

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

<div align="center">

**Built with ❤️ for the Amrita Community**

[⬆ Back to Top](#amritafind---lost--found-platform-for-amrita-university)

</div>