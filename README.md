# AmritaFind - Lost & Found Platform for Amrita University

AmritaFind is a dedicated Flutter-based mobile application designed to establish a community-driven Lost & Found ecosystem for Amrita University. The platform streamlines communication between students who have lost items and those who have found them by offering a seamless, technology-enhanced experience.

### Get The App

You can download the latest version of the application for Android directly from our **GitHub Releases page**.

---

## Screenshots

*(To add screenshots, create a folder named `screenshots` in your project's root directory, add your images there, and reference them like this: `!Login Screen`)*

| Login | Home Feed | Create Post |
| :---: | :---: | :---: |
| *Screenshot Placeholder* | *Screenshot Placeholder* | *Screenshot Placeholder* |
| **Chatbot** | **Profile** | **Onboarding** |
| *Screenshot Placeholder* | *Screenshot Placeholder* | *Screenshot Placeholder* |

---

## Problem Statement

Amrita University operates across multiple campuses and serves thousands of students, yet there is no unified platform to manage lost and found items efficiently. Students who misplace personal belongings face significant challenges in reporting, searching for, and recovering their items. The absence of a coordinated solution leads to many lost items remaining unclaimed, increased administrative workload, and unnecessary inconvenience for students and staff.

---

## Key Features

-   **Real-time Item Listings:** Powered by Firebase Firestore for instant updates on lost and found items.
-   **AI-Powered Matching & Chatbot:** Utilizes the Google Gemini API to automatically find potential matches for lost items and to power a 24/7 support chatbot.
-   **Secure User Authentication:** Managed through Firebase Auth for safe and secure student access.
-   **Image-Supported Posts:** Uses Cloudinary for reliable and fast image uploads to accurately document items.
-   **Advanced Filtering & Search:** Filter items by status, location, and date, with full-text search capabilities.
-   **Direct Messaging:** Built-in real-time chat allows students to connect quickly and securely to arrange returns.
-   **Comprehensive User Profiles:** Profiles include verified academic details like department, year, and roll number.

---

## Architecture

```
AmritaFind/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   │
│   ├── pages/
│   │   ├── onboarding_screen.dart
│   │   ├── login_page.dart
│   │   ├── home_page.dart
│   │   ├── post_item_form_page.dart
│   │   ├── profile_page.dart
│   │   ├── edit_profile_page.dart
│   │   ├── chat_list_page.dart
│   │   ├── chat_page.dart
│   │   └── chat_bot_page.dart
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
| :--- | :--- |
| Frontend | Flutter 3.9+ |
| Backend | Firebase (Auth, Firestore) |
| AI/ML | Google Gemini API |
| Image Upload | **Cloudinary** |
| Real-time DB | Cloud Firestore |

---

## Installation

### Prerequisites

-   **Flutter SDK** 3.9 or higher (Download)
-   **Dart** 3.0+ (included with Flutter)
-   **Firebase Account** (Create Free Account)
-   **Cloudinary Account** (Create Free Account)
-   **Google Gemini API Key** (Get API Key)

### Step 1: Clone the Repository

```bash
git clone https://github.com/SarvanthiSivaraj/AmritaFind.git
cd AmritaFind
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Configure Firebase

1.  Create a Firebase project at Firebase Console.
2.  Add an Android app to your Firebase project.
3.  Download the `google-services.json` file and place it in the `android/app/` directory.
4.  Enable the following Firebase services:
    -   **Authentication** (Email/Password method)
    -   **Cloud Firestore** (Database)

### Step 4: Setup Environment Variables

1.  In the project root, create a file named `.env`.
2.  Add your credentials for Cloudinary and Google Gemini to the `.env` file:

    ```env
    # Google Gemini API Key
    GEMINI_API_KEY=your_gemini_api_key_here

    # Cloudinary Credentials
    CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
    CLOUDINARY_UPLOAD_PRESET=your_cloudinary_upload_preset
    ```

### Step 5: Run the Application

```bash
flutter run
```

---

## Usage

### Demo Credentials

For a quick demonstration, you can use the following mock student account:

-   **Email:** `cb.sc.u4cse23553@cb.students.amrita.edu`
-   **Password:** `Sanjjiiev`

### First-Time Users

1.  **Onboarding**: Review the welcome screens to understand app features.
2.  **Login**: Use your student email to log in. A profile is automatically created.
3.  **Complete Profile**: Navigate to the profile tab to add your contact number and a profile picture.

### Finding & Posting Items

1.  **Home Feed**: Browse all lost and found items. Use the filters to narrow your search.
2.  **Create Post**: Tap the "+" button on the navigation bar to report a lost or found item. Fill in the details and upload photos.
3.  **AI Matching**: If you post a "Lost" item, our AI will automatically search for matching "Found" items and send you a notification if a potential match is discovered.

### Communication

1.  **Chat**: On any item post, tap the "Chat" button to securely message the owner or finder.
2.  **AI Chatbot**: Go to the Chatbot tab to get instant answers to common questions about campus procedures and locations.

---

## Database Schema

### `users` Collection

```json
{
  "uid": "firebase_user_id",
  "name": "Sanjjiiev S",
  "department": "CSE",
  "year": "1",
  "rollNumber": "CB.SC.U4CSE23553",
  "contact": "+919876543210",
  "email": "cb.sc.u4cse23553@cb.students.amrita.edu",
  "photoUrl": "https://res.cloudinary.com/..."
}
```

### `lost_items` / `found_items` Collections

```json
{
  "uid": "firebase_user_id_of_poster",
  "item_name": "Blue Dell Laptop",
  "description": "Insulated blue water bottle with white cap, has a small dent.",
  "location": "AB1",
  "contact": "+919876543210",
  "status": "Lost",
  "imageUrls": ["https://res.cloudinary.com/..."],
  "timestamp": "2025-12-07T09:15:00Z"
}
```

---

## Team

-   Sarvanthikha SR
-   Sanjjiiev S
-   Eshanaa Ajith K
-   Sanjai P G
