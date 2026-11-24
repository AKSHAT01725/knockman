# KnockMan

KnockMan is a cross-platform home services booking application built with Flutter and Firebase. Customers can discover services, place bookings, track order status, and chat with vendors. Vendors can manage incoming jobs, while administrators can manage users and orders from a dedicated dashboard.

## Features

### Customers
- Email and password authentication
- Browse cleaning, plumbing, furniture, AC repair, pest control, and painting services
- View service details and estimated price ranges
- Create bookings with date, time, phone number, address, and job description
- Cash-on-delivery booking confirmation
- Track pending, accepted, and rejected orders
- Chat with a vendor after an order is accepted
- Edit profile information
- Submit messages through the contact form

### Vendors
- View all service bookings
- Filter orders by service category
- Accept or reject booking requests
- Track pending and accepted jobs
- Chat with customers for accepted orders

### Administrators
- View application, user, and order statistics
- Search and filter users by role
- Create user accounts and assign roles
- Promote users to vendor or administrator
- Ban or unban accounts
- Review all orders

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **Backend:** Firebase Authentication, Cloud Firestore
- **Local Storage:** SharedPreferences
- **UI and Animations:** Material Design, animate_do
- **Supported Assets:** Images and a splash video

## Firebase Data

The app uses these primary Firestore collections:

- `users` - profile, role, and account status
- `orders` - booking details and order status
- `orders/{orderId}/messages` - order chat messages
- `contact_messages` - contact form submissions

Example user document:

```json
{
  "name": "User",
  "email": "user@example.com",
  "mobile": "",
  "address": "",
  "role": "user",
  "isBanned": false
}
```

Supported roles are `user`, `vendor`, and `admin`. The login screen redirects users to the appropriate home, vendor, or admin interface.

## Demo Accounts

> Replace these credentials before publishing or deploying the app.

| Role | Email | Password |
|---|---|---|
| Admin | `admin@gmail.com` | `admin123` |
| Vendor | `plumber1@gmail.com` | `plumber123` |
| User | `neel1@gmail.com` | `neel123` |

## Getting Started

### Prerequisites

- Flutter SDK 3.32 or later
- Dart SDK 3.8 or later
- Android Studio or VS Code
- A Firebase project
- Firebase Authentication enabled with the Email/Password provider
- Cloud Firestore enabled

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd flutter_project
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

#### Android

The project already includes `android/app/google-services.json`. If you are using a different Firebase project:

1. Register an Android app in Firebase Console.
2. Use the application ID from `android/app/build.gradle.kts`.
3. Download `google-services.json`.
4. Replace `android/app/google-services.json`.

#### Web

The web initialization values are configured in `lib/main.dart`. Replace them with the Firebase web configuration for your project.

#### iOS and macOS

For native iOS or macOS builds:

1. Register the corresponding app in Firebase Console.
2. Download `GoogleService-Info.plist`.
3. Add it to `ios/Runner/` or `macos/Runner/` in Xcode.

### 4. Configure Firestore Rules

Use rules appropriate for your app and environment. For development, start with rules that restrict access to authenticated users and validate roles where required. Do not expose unrestricted write access in production.

### 5. Run the App

```bash
flutter run
```

To run on a specific platform:

```bash
flutter run -d chrome
flutter run -d windows
flutter run -d android
```

## Creating Roles

New accounts receive the `user` role by default. An existing administrator can assign vendor or administrator roles from the admin dashboard.

You can also create the initial role in Firestore:

```text
users/{firebase-user-uid}
```

Set `role` to `admin`, `vendor`, or `user`, and set `isBanned` to `false`.

## Project Structure

```text
lib/
├── main.dart              # App initialization and named routes
├── splash_screen.dart     # Initial splash screen
├── login_page.dart        # Login and account creation
├── home_screen.dart       # Customer dashboard
├── services.dart          # Service catalog
├── service_detail_page.dart
├── booking_page.dart      # Multi-step booking flow
├── orders_page.dart       # Customer order tracking
├── chat_screen.dart       # Order chat
├── vendor_page.dart       # Vendor dashboard
├── admin_page.dart        # Administrator dashboard
├── user_profile.dart      # Customer profile
├── contact_us.dart        # Contact form
├── about_us.dart
├── order_manager.dart     # Order Firestore operations
└── profile_manager.dart   # Local profile state

assets/
├── logo.png
├── intro.mp4
└── service images
```

## Testing

Run Flutter's test suite with:

```bash
flutter test
```

Run static analysis with:

```bash
flutter analyze
```

## Build

Android APK:

```bash
flutter build apk --release
```

Android App Bundle:

```bash
flutter build appbundle --release
```

Web:

```bash
flutter build web --release
```

## Contributing

1. Fork the repository.
2. Create a feature branch.
3. Make and test your changes.
4. Submit a pull request.
