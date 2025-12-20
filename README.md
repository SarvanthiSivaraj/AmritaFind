# AmritaFind - Lost & Found Platform for Amrita University

## Problem Statement

Amrita University operates across multiple campuses and serves thousands of students, yet there is no unified platform to manage lost and found items efficiently. As a result, students who misplace personal belongings—such as wallets, ID cards, books, or water bottles—face significant challenges. Currently, they lack a structured system to:

- **Report lost items** with clear and detailed descriptions
- **Browse or search for found items** submitted by other students
- **Communicate directly** with individuals who have located their belongings
- **Receive intelligent, AI-driven assistance** to help trace or identify items

The absence of such a coordinated solution leads to many lost items remaining unclaimed, increased administrative workload, and unnecessary inconvenience for students and staff.

---

## Proposed Solution

AmritaFind is a dedicated Flutter-based mobile application designed to establish a community-driven Lost & Found ecosystem for Amrita University. The platform streamlines communication between students who have lost items and those who have found them by offering a seamless, technology-enhanced experience. Key features include:

- **Real-time item listings** powered by Firebase Firestore for instant updates
- **AI-driven assistance** using the Google Gemini API to help users locate items efficiently
- **Secure user authentication** through Firebase Auth
- **Image-supported item documentation** using Firebase Storage for accurate identification
- **Location- and time-based filtering** to narrow down searches with high precision
- **Built-in direct messaging** enabling students to connect quickly and securely
- **Comprehensive user profiles** containing verified academic details (department, year, roll number)

AmritaFind enhances campus connectivity, reduces unclaimed items, and modernizes the lost-and-found process through intelligent, user-friendly features.

---

## Key Features
1. **User Authentication**
   - Secure login and registration using Firebase Authentication
   - Managed user profiles with verified academic details
   - Seamless access control for students across all campuses

2. **Lost & Found Posting**
   - Create detailed Lost or Found item posts with:
     - Item name and comprehensive description
     - Support for multiple image uploads
     - Optional contact information
   - Instant synchronization of posts through Firebase Firestore

3. **Smart Search & Advanced Filtering**
   - Filter results by item status (Lost / Found / All)
   - Location-based search to narrow down results
   - Date-range filtering to track recent activity
   - Full-text search across item names and descriptions
   - Multiple sorting modes (e.g., date added, relevance)

4. **AI-Powered Chatbot**
   - Integrated assistant powered by the Google Gemini API
   - Provides context-aware guidance related to lost and found items
   - Real-time conversational interface for quick support
   - Secure API configuration through environment variables

5. **Direct Messaging System**
   - Real-time peer-to-peer chat between students
   - Instant message updates with Firestore synchronization
   - User avatar integration for better identification

6. **User Profile Management**
   - View and maintain personal details:
     - Full name
     - Department
     - Academic year
     - Roll number (standard format: CB.SC.U4CSE29999)
   - Edit and update profile information anytime
   - Access a dashboard of the user's own Lost & Found posts

---

## Architecture

```
lostandfound/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   │
│   ├── pages/
│   │   ├── app_routes.dart
│   │   ├── onboarding_screen.dart
│   │   ├── login_page.dart
│   │   ├── home_page.dart
│   │   ├── post_item_form_page.dart
│   │   ├── profile_page.dart
│   │   ├── edit_profile_page.dart
│   │   ├── chat_list_page.dart
│   │   ├── chat_page.dart
│   │   ├── chat_bot_page.dart
│   │   └── message.dart
│   │
│   └── services/
│       ├── auth_service.dart
│       ├── ai_service.dart
│       └── chat_service.dart
│
├── android/
├── ios/
└── pubspec.yaml

```

### Technology Stack

| Component | Technology |
|-----------|-----------|
| Frontend | Flutter 3.0+ |
| Backend | Firebase (Auth, Firestore, Storage) |
| AI/ML | Google Gemini 2.5 Flash API |
| Image Upload | Cloudinary |
| Real-time DB | Cloud Firestore |

---

## Installation

### Prerequisites

- **Flutter SDK** 3.0 or higher ([Download](https://flutter.dev/docs/get-started/install))
- **Dart** 3.0+ (included with Flutter)
- **Firebase Account** ([Create Free Account](https://firebase.google.com))
- **Cloudinary Account** ([Create Free Account](https://cloudinary.com/))
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

### Step 4: Configure Cloudinary

1. Create Account: Go to Cloudinary and sign up for a free account at [Cloudinary](https://cloudinary.com/).
2. Get Credentials:
   - From your Dashboard, copy your Cloud Name.
   - Go to Settings > Upload, create an Unsigned Upload Preset (e.g., A_uploads), and copy its name.
3. Update App Code: In **lib/pages/post_item_form_page.dart** and **lib/pages/profile_page.dart**, add your credentials:

### Step 5: Setup Environment Variables

1. Create a `.env` file in the `lostandfound/` directory:

```bash
cp .env.example .env
```

2. Add your Google Gemini API key to `.env`:

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

### Step 6: Run the Application

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

## Usage

### First-Time Users

1. **Onboarding**: Review the welcome screens to understand app features
2. **Login/Sign-up**: Create an account using email
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
3. Submit to make it visible to all users

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

## Security & Privacy

- **Authentication**: Secure Firebase authentication with password encryption
- **Data Privacy**: User data stored securely in Firestore
- **Image Security**: Images uploaded to Firebase Storage with proper permissions
- **API Keys**: Sensitive keys managed through environment variables (`.env`)

---

## Database Schema

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

Team:
- Sarvanthikha SR
- Sanjjiiev S
- Eshanaa Ajith K
- Sanjai P G
