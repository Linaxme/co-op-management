# Firebase Setup Guide

এই প্রোজেক্টটি Firebase এর সাথে অনলাইন করার জন্য Firebase প্রোজেক্ট সেটআপ করতে হবে। নিচের ধাপগুলো অনুসরণ করুন:

## 1. Firebase Console এ প্রোজেক্ট তৈরি করুন

1. [Firebase Console](https://console.firebase.google.com/) এ যান
2. "Create a project" ক্লিক করুন
3. প্রোজেক্টের নাম দিন (যেমন: coop-app-firebase)
4. Google Analytics চালু রাখুন বা বন্ধ করুন (আপনার পছন্দমতো)
5. "Create project" ক্লিক করুন

## 2. Android অ্যাপ যোগ করুন

1. Firebase Console এ প্রোজেক্টে যান
2. Android আইকন ক্লিক করে Android অ্যাপ যোগ করুন
3. Package name: `com.linax.coop_ssf`
4. App nickname: Coop App (Android)
5. SHA-1 certificate fingerprint: (এখন পরে যোগ করবেন)
6. "Register app" ক্লিক করুন
7. `google-services.json` ফাইলটি ডাউনলোড করে `android/app/` ফোল্ডারে রাখুন

## 3. iOS অ্যাপ যোগ করুন

1. Firebase Console এ প্রোজেক্টে যান
2. iOS আইকন ক্লিক করে iOS অ্যাপ যোগ করুন
3. Bundle ID: `com.linax.coopSsf`
4. `GoogleService-Info.plist` ফাইলটি ডাউনলোড করে `ios/Runner/` ফোল্ডারে রাখুন

## 4. Firestore Database সেটআপ করুন

1. Firebase Console এ "Firestore Database" এ যান
2. "Create database" ক্লিক করুন
3. Production mode নির্বাচন করুন
4. Location: asia-south1 (বা nearest location)

## 5. Authentication সেটআপ (Admin + Member Login)

### Admin (Email + Password)

1. Firebase Console → **Authentication** → **Get started**
2. **Sign-in method** → **Email/Password** → Enable
3. **Users** ট্যাবে admin user তৈরি করুন (যেমন `admin@yourcoop.com`)
4. Firestore → `users` collection এ document তৈরি করুন:
   - Document ID = admin user এর Firebase UID
   - Fields: `{ "role": "admin", "email": "admin@yourcoop.com" }`
5. **Anonymous sign-in বন্ধ** রাখুন (security)

### Member (Phone + PIN)

Member login Cloud Functions দিয়ে কাজ করে। Deploy করতে:

```bash
cd functions
npm install
cd ..
firebase deploy --only functions,firestore:rules
```

## 6. Security Rules

প্রোজেক্টের `firestore.rules` ফাইল deploy করুন:

```bash
firebase deploy --only firestore:rules
```

Rules অনুযায়ী:
- **Admin** — সব data read/write
- **Member** — শুধু নিজের member record ও deposits read

## 7. Flutter অ্যাপে Firebase কনফিগারেশন

1. `flutter pub get` রান করুন
2. Android এ SHA-1 certificate fingerprint যোগ করুন Firebase Console এ
3. `flutter run` দিয়ে অ্যাপ টেস্ট করুন

## 8. প্রথম ব্যবহার

1. Admin হিসেবে Email + Password দিয়ে লগইন করুন
2. Member যোগ করুন — ফোন নম্বর ও প্রাথমিক PIN দিন
3. Member হিসেবে ফোন + PIN দিয়ে লগইন করে নিজের প্রোফাইল দেখুন
