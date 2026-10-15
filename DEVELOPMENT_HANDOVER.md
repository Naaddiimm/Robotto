# ROBOTTO - Development Handover Report

**Date/Time of Generation:** End of current development session.
**Project Name:** ROBOTTO (Mobile Robotics Community Platform)

---

## 1. Project Overview
ROBOTTO is a mobile application built in Flutter dedicated to robotics enthusiasts. It features a marketplace, forums, educational formations, events, projects, and user profiles. The application follows a strict "Cybernetic Orbit" design system. 

In this session, a local SQLite database infrastructure was fully integrated to support registration, secure credential management, and the multi-step onboarding flow.

---

## 2. Technology Stack and Dependencies
*   **Framework:** Flutter / Dart
*   **Database:** `sqflite`
*   **Pathing:** `path`
*   **Security:** `crypto` (used for iterative SHA-256 key stretching / password hashing)
*   **Other New Dependencies:** `cryptography` (available for future PBKDF2/Argon2 scaling if needed).
*   **Fonts/Assets:** *Plus Jakarta Sans*, local images.

---

## 3. Project Architecture and File Structure
The project now includes a robust Data and Service layer separating the database logic from UI components:

```text
lib/
├── data/
│   ├── database_helper.dart            # Singleton SQLite connection & migrations
│   ├── models/
│   │   ├── user.dart                   # Core User entity
│   │   ├── user_interest.dart          # Step 1 Onboarding mappings
│   │   └── user_learning_goal.dart     # Step 2 Onboarding mappings
│   └── repositories/
│       └── user_repository.dart        # Database abstraction/CRUD for Users
├── services/
│   └── auth_service.dart               # Handles registration, email checking, hashing
└── screens/
    ├── welcome_screen.dart             
    ├── signup_screen.dart              # Wired to AuthService
    ├── signin_screen.dart              
    ├── interests_screen.dart           # Step 1: Saves to DB
    ├── profile_setup_screen.dart       # Step 2: Saves to DB
    └── home_screen.dart                
```

---

## 4. Implemented Features and Verified Status

*   **SQLite Database Setup:** `COMPLETED`. Configured `robotto.db` with non-destructive migrations, foreign keys enabled, and parameterized transactions.
*   **User Registration Data Model:** `COMPLETED`. Secure `users` table tracks core details. Passwords are intentionally omitted from `users` and placed securely in `user_credentials`.
*   **Secure Password Hashing:** `COMPLETED`. Passwords are mathematically hashed 10,000 times (PBKDF2 simulation) combined with a cryptographically secure Base64 salt. Raw passwords are never stored.
*   **Email Uniqueness Validation:** `COMPLETED`. Strict DB-level `UNIQUE` constraints combined with application-level lowercase trimming + regex validation prevent duplicate registrations.
*   **Onboarding Step 1 (Interests):** `COMPLETED`. `UserInterestRepository` seamlessly replaces and stores selected UI options in `user_interests` via SQLite transactions.
*   **Onboarding Step 2 (Experience & Goals):** `COMPLETED`. The `users` table is `UPDATED` with `experience_level`, and `user_learning_goals` table is populated natively.
*   **UI/DB Integration:** `COMPLETED`. Replaced static prototyping in the Sign-Up and Onboarding flows with actual `async` database calls.

---

## 5. Important Design and Architectural Decisions
1.  **Isolated Credentials:** Following strict security best practices, the database schema strictly separates `users` from `user_credentials`. 
2.  **Referential Integrity:** `ON DELETE CASCADE` is set up on all related tables (`user_credentials`, `user_interests`, `user_learning_goals`) ensuring zero orphaned data if a user is wiped.
3.  **Nullable Step 2 Fields:** `experience_level` is carefully managed as a nullable text field in the database during Step 1 (Sign Up), and gracefully upgraded via an `UPDATE` in Step 2.
4.  **No UI Blocking on Background Ops:** Database requests dynamically trigger the pre-existing loading spinners on all screens, keeping the UX fluid.

---

## 6. Current Errors, Limitations, and Unresolved Issues
*   **Local Backend Limitation:** While users are successfully created and stored natively inside `robotto.db`, Sign-In hasn't been completely wired up to reverse-hash and check passwords against the new database yet.
*   **AI Recommendations:** The data model structure (`experience_level`, goals, interests) is in place, but the query-engine to serve recommendations in the Marketplace/Events is pending.

---

## 7. Relevant Commands
*   **Dependencies Check:** `flutter pub get`
*   **Static Analysis:** `flutter analyze` (Verified: 0 issues).
*   **Clean build:** `flutter clean && flutter pub get`

---

## 8. Prioritized Plan for the Next Session
1.  **FEATURE (Critical):** Implement `AuthService.loginUser()` and wire it directly into `lib/screens/signin_screen.dart` so returning users can log in using their securely hashed credentials.
2.  **FEATURE:** Integrate a globally accessible session state (using Provider, Riverpod, or InheritedWidget) so the Application knows *who* is logged in and can fetch their customized data.
3.  **UI/UX:** Hydrate the `HomeScreen` empty tabs with dynamic queries based on the newly saved User Interests (e.g., querying the DB for "Combat Robotics" events).

---

## 9. Exact Resume Point
Begin tomorrow's session by opening `lib/screens/signin_screen.dart` and `lib/services/auth_service.dart`. Implement a login function that takes the user's email, looks up the associated `salt` and `password_hash` in `user_credentials`, reconstructs the hash with the provided password attempt, and compares them.

---

## 10. Instructions for the Next AI Coding Session
**To the Next AI Agent:**
1.  **READ THIS FILE FIRST** to understand the DB schema layout and security constraints.
2.  **INSPECT** `auth_service.dart` to observe how `_hashPassword` handles salting and stretching before writing the login equivalent.
3.  **RESUME** from Section 9 (Exact Resume Point).
4.  **DO NOT MODIFY** the existing SQLite Table structures unless explicitly requested.
5.  **ANALYZE:** Run `flutter analyze` after every code modification.
