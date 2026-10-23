# assignment_6

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
"# Evently-app" 

## Firebase setup

Firebase configuration files are kept locally and excluded from Git.
Existing local configuration remains available on the development machine.

For a fresh checkout, run `flutterfire configure --project=evently-38212`
with access to the Firebase project, and obtain `android/app/google-services.json`
from Firebase Console > Project settings > Your apps > Android.
Alternatively, copy `lib/firebase_options.example.dart` to
`lib/firebase_options.dart` and fill in your own Firebase app configuration.
Do not commit the local configuration files.

Removing these files from the latest revision does not remove keys from older
commits or copies of the repository. Firebase client API keys also remain
extractable from distributed apps; backend access must be protected by Firebase
Security Rules and appropriate API restrictions.
