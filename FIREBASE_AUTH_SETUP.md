# 🔥 FIREBASE + AUTH COMPLETE SETUP GUIDE

## ✅ COMPLETED

### Milestone 1: Environment & Security ✅
- ✅ Backend .env configured with all credentials
- ✅ .gitignore updated to protect Firebase files
- ✅ Firebase credentials: delivery-bagour
- ✅ Resend API configured
- ✅ Google Cloud API key added

### Dependencies Installed ✅
```bash
npm install resend firebase-admin bcryptjs @types/bcryptjs
```

## 📋 REMAINING TASKS

### 1. Complete Email Service (backend/src/services/email.service.ts)

Create the email service using the template below. This service handles:
- OTP verification emails
- Welcome emails
- Order confirmations

### 2. Update User Model

Add these fields to `User` model:
```typescript
// Auth provider
authProvider: { type: String, enum: ['email', 'google'], default: 'email' },
googleId: String,

// OTP fields
emailOTP: String,
emailOTPExpires: Date,
resetOTP: String,
resetOTPExpires: Date,
```

### 3. Create Auth Service

Implement complete auth flows:
- Email + Password Registration with OTP
- Email Login
- Google Sign-In
- Forgot Password
- Reset Password
- Refresh Tokens

### 4. Remove Phone/SMS Auth

Delete these files:
```bash
rm -f src/services/sms.service.ts
rm -f src/services/twilio.service.ts
```

Update routes to remove phone auth endpoints.

### 5. Flutter Setup

For each app (customer-app, delivery-app, restaurant-app):

```bash
cd customer-app
dart pub global activate flutterfire_cli
flutterfire configure --project=delivery-bagour --platforms=android,ios
```

Add dependencies to pubspec.yaml:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  firebase_messaging: ^14.7.10
  google_sign_in: ^6.2.1
  flutter_local_notifications: ^16.3.0
```

### 6. Create Notification Service

Implement FCM notification service in backend for:
- New orders
- Order status updates
- Driver assignments
- Delivery notifications

## 🔑 CREDENTIALS REFERENCE

All credentials are already in `backend/.env`:

```
FIREBASE_PROJECT_ID=delivery-bagour
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-fbsvc@delivery-bagour.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="[Already set]"

GOOGLE_CLOUD_API_KEY=AIzaSyAHXnrtxnvC1VqN_SliHfZpCGp2TtTrNIY
GOOGLE_MAPS_API_KEY=AIzaSyAHXnrtxnvC1VqN_SliHfZpCGp2TtTrNIY

RESEND_API_KEY=re_bRAo8Dy1_6WrUG5s8zV8wTUpJ2avPE4A8
RESEND_FROM_EMAIL=onboarding@resend.dev
```

## 🎯 AUTH FLOWS TO IMPLEMENT

### Flow 1: Email Registration
```
1. POST /auth/register { email, password, name, role }
2. Generate 6-digit OTP
3. Send OTP via Resend
4. POST /auth/verify-email { email, otp }
5. Mark user as verified
6. Return JWT tokens
```

### Flow 2: Email Login
```
1. POST /auth/login { email, password }
2. If not verified → Send OTP, return requiresVerification: true
3. If verified → Return JWT tokens
```

### Flow 3: Google Sign-In
```
1. Frontend: Google OAuth → Get ID token
2. POST /auth/google { idToken, role }
3. Verify token with Firebase Admin
4. Create/Update user (auto-verified)
5. Return JWT tokens
```

### Flow 4: Forgot Password
```
1. POST /auth/forgot-password { email }
2. Generate OTP
3. Send reset OTP via Resend
4. POST /auth/reset-password { email, otp, newPassword }
5. Update password
```

## 📱 FLUTTER AUTHENTICATION

Implement in all 3 apps:

### Auth Service Structure
```dart
class AuthService {
  // Email Auth
  Future<Map> register({email, password, name});
  Future<Map> verifyEmailOTP({email, otp});
  Future<Map> login({email, password});
  Future<Map> resendOTP(email);
  
  // Google Auth
  Future<Map> signInWithGoogle();
  
  // Password Reset
  Future<Map> forgotPassword(email);
  Future<Map> resetPassword({email, otp, newPassword});
  
  // Token Management
  Future<void> refreshTokens();
  Future<void> logout();
}
```

### Notification Service
```dart
class NotificationService {
  Future<void> initialize();
  Future<String?> getToken();
  void _handleForeground(RemoteMessage);
  void _handleBackground(RemoteMessage);
  void _handleTap(RemoteMessage);
}
```

## 🧪 TESTING

Test accounts to create:
```
Admin: admin@bagour.delivery / admin123
Customer: customer@test.com / test123
Restaurant: restaurant@test.com / test123
Driver: driver@test.com / test123
```

## 📞 SUPPORT

Firebase Console: https://console.firebase.google.com/project/delivery-bagour
Google Cloud Console: https://console.cloud.google.com/apis/credentials?project=delivery-bagour

---

**NEXT STEPS:**
1. Implement email service (copy from task description)
2. Update User model
3. Create auth service
4. Setup Flutter apps
5. Test all auth flows
6. Deploy & monitor

🚀 **Ready for implementation!**
