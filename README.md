# DEVMOB Flutter Intra

A modern Flutter-based social intranet platform designed for employee collaboration, community building, and internal communication. Built with Firebase and Provider state management.

![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)
![License](https://img.shields.io/badge/license-MIT-green)

## 🎯 Features

- **Authentication**: Firebase Auth with email/password login
- **Social Feed**: Create, edit, delete, and interact with posts
- **User Profiles**: Customizable user profiles with bio and profile images
- **Groups**: Create and manage community groups
- **Direct Messaging**: Real-time chat functionality
- **File Sharing**: Upload and share documents within posts
- **Like & Comments**: Interactive engagement on posts
- **Dark/Light Theme**: Full theme support with persistent settings
- **Role-Based Access**: Admin and employee role management
- **Image Upload**: Integration with Cloudinary for image management
- **Remember Me**: Persistent login with local storage

## 🏗️ Architecture

This project follows a **4-Tier Architecture** pattern:

```
lib/
├── models/          # Data structures (UserModel, PostModel, GroupModel, etc.)
├── services/        # Business logic & Firebase integration (AuthService, PostService, etc.)
├── providers/       # State management using Provider package (AuthProvider, PostProvider, etc.)
├── views/           # UI presentation layer (login, home, profile, chat, groups, etc.)
└── widgets/         # Reusable UI components
```

### Architecture Benefits

- **Single Responsibility**: Each layer has one clear responsibility
- **Testability**: Services and providers can be unit tested independently
- **Maintainability**: Clear separation makes code easier to understand and modify
- **Change Isolation**: Updates to Firebase or business logic stay in the `services` layer
- **Reusability**: Models and services are shared across the app
- **Scalability**: Easy to add features or swap implementations

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.9.2+
- **State Management**: Provider 6.1.1+
- **Backend**: Firebase
  - Authentication: Firebase Auth
  - Database: Cloud Firestore
  - Image Storage: Cloudinary
- **Key Packages**:
  - File Picking: file_picker
  - URL Launcher: url_launcher
  - Local Storage: shared_preferences

## 📋 Prerequisites

- Flutter 3.9.2 or higher
- Dart 3.9.2 or higher
- Android SDK (for Android development)
- Xcode 14+ (for iOS development)
- Firebase project with Authentication and Firestore enabled
- Cloudinary account configured (for image uploads)

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/devmobi_flutter_intra.git
cd devmobi_flutter_intra
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Add Android and iOS apps to your Firebase project
3. Download `google-services.json` for Android and place it in `android/app/`
4. Download `GoogleService-Info.plist` for iOS and add it to Xcode
5. Update `lib/firebase_options.dart` with your Firebase configuration

### 4. Cloudinary Setup

1. Create a Cloudinary account at [Cloudinary](https://cloudinary.com)
2. Update image upload services with your Cloudinary credentials in `lib/services/post_service.dart`

### 5. Run the App

**On Android Emulator:**
```bash
flutter emulators --launch <emulator-id>
flutter run
```

**On iOS Simulator:**
```bash
open -a Simulator
flutter run
```

**On Physical Device:**
```bash
flutter run
```

**On Web:**
```bash
flutter run -d chrome
```

## 📁 Project Structure

```
lib/
├── models/
│   ├── user_model.dart          # User data structure
│   ├── post_model.dart          # Post data structure
│   ├── group_model.dart         # Group data structure
│   └── ...
├── services/
│   ├── auth_service.dart        # Firebase Auth operations
│   ├── post_service.dart        # Post CRUD & Firestore queries
│   ├── group_service.dart       # Group management
│   └── ...
├── providers/
│   ├── auth_provider.dart       # Auth state management
│   ├── post_provider.dart       # Posts state
│   ├── theme_provider.dart      # Theme switching
│   └── ...
├── views/
│   ├── auth/                    # Login & Registration
│   ├── home/                    # Feed screen
│   ├── profile/                 # User profiles
│   ├── chat/                    # Messaging
│   ├── group/                   # Groups management
│   └── splash/                  # Splash screen
├── widgets/                      # Reusable UI components
├── firebase_options.dart        # Firebase config
└── main.dart                    # App entry point
```

## 🔑 Key Files

- **`pubspec.yaml`**: Project dependencies and configuration
- **`lib/main.dart`**: App initialization and Provider setup
- **`lib/firebase_options.dart`**: Firebase platform-specific configuration
- **`analysis_options.yaml`**: Lint rules for code quality
- **`firestore.rules`**: Cloud Firestore security rules
- **`storage.rules`**: Cloud Storage security rules

## 🔐 Configuration

Firebase and Cloudinary credentials are configured in:
- `lib/firebase_options.dart` - Firebase platform-specific configuration
- `lib/services/` - Service files contain Cloudinary integration

## 🧪 Testing

Run tests with:

```bash
flutter test
```

## 📱 Building for Release

**Android:**
```bash
flutter build apk --split-per-abi
# or for App Bundle
flutter build appbundle
```

**iOS:**
```bash
flutter build ipa
```

**Web:**
```bash
flutter build web
```

## 🤝 Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Commit changes: `git commit -m 'Add your feature'`
3. Push to branch: `git push origin feature/your-feature`
4. Submit a pull request

## 📝 Code Style

- Follow Flutter best practices and effective Dart guidelines
- Use meaningful variable and function names
- Keep functions small and focused
- Write comments for complex logic
- Run lint checks: `flutter analyze`

## 🐛 Known Issues

- Network images may fail to load without proper connectivity
- Ensure Firebase security rules allow proper data access
- Admin role creation requires authentication with admin account

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Authors

- **DevMob Team** - Initial development

## 📞 Support

For issues and questions:
- Open an issue on GitHub
- Contact: [support@devmob.com](mailto:support@devmob.com)

## 🙏 Acknowledgments

- Flutter team for the excellent framework
- Firebase for backend services
- Provider package for state management
- All contributors and testers

---

**Last Updated**: May 2026
