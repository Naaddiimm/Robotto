# ROBOTTO - Technical Audit for Forum Implementation

**Role:** Senior Flutter/Dart Software Architect
**Date:** Current
**Status:** Audit Complete (Read-Only)

---

## A. Project Overview
*   **Project Root:** `C:\Users\Nadim\Desktop\Robotto`
*   **Flutter/Dart Constraints:** Dart SDK `^3.13.3`, Flutter SDK (unspecified bound, using `uses-material-design`).
*   **Main Architecture:** The project has undergone a significant refactoring from flat `lib/screens` to a structured feature-based architecture (`lib/core`, `lib/features`). 
*   **State Management:** Primarily uses native `StatefulWidget` and `setState` combined with `AnimationController` for UI interactions. Navigation state is managed locally in `HomeScreen` via `_selectedIndex` and `IndexedStack`.
*   **Navigation Approach:** Standard `MaterialPageRoute` pushing and `Navigator.pushAndRemoveUntil`.
*   **Existing Changes/Limitations:** `sqflite_common_ffi` was recently added in `main.dart` to support Windows/Desktop local database testing alongside mobile. The app employs a dark-mode-first `AppTheme`.

---

## B. File and Folder Map

**Relevant Existing Files:**
```text
lib/
├── main.dart                                   (Entry point, Theme initialization, sqflite_ffi init)
├── core/
│   ├── theme/app_theme.dart                    (Centralized Cybernetic Orbit colors and fonts)
│   ├── data/
│   │   ├── database_helper.dart                (SQLite DB Singleton & Schema)
│   │   ├── models/user.dart                    (User entity)
│   │   └── repositories/user_repository.dart   (CRUD operations for users)
│   └── services/auth_service.dart              (Registration, PBKDF2 hashing, SharedPreferences session)
├── features/
│   ├── home/
│   │   ├── screens/home_screen.dart            (Main Hub, Bottom Nav Bar, IndexedStack)
│   │   └── widgets/drawer_screen.dart          (Navigation drawer, logout logic)
│   └── user/
│       ├── screens/profile_screen.dart         (Shows current user details)
│       └── screens/signin_screen.dart          (Auth entry)
```

**Planned Forum Files (DO NOT EXIST YET):**
*   `lib/core/data/models/forum_post.dart`
*   `lib/core/data/models/forum_reply.dart`
*   `lib/core/data/repositories/forum_post_repository.dart`
*   `lib/core/data/repositories/forum_reply_repository.dart`
*   `lib/core/data/repositories/forum_like_repository.dart`
*   `lib/core/services/forum_service.dart`
*   `lib/features/forum/screens/forum_screen.dart`
*   `lib/features/forum/screens/create_post_screen.dart`
*   `lib/features/forum/screens/post_detail_screen.dart`

---

## C. Database Audit
*   **Helper Path:** `lib/core/data/database_helper.dart`
*   **Filename & Path Construction:** `'robotto.db'`, constructed using `join(await getDatabasesPath(), 'robotto.db')`.
*   **Current Schema Version:** `version: 1`
*   **Initialization Method:** Singleton pattern `DatabaseHelper.instance.database`.
*   **Migration Mechanism:** Currently relies only on `onCreate`. `onUpgrade` is **NOT YET IMPLEMENTED**.
*   **Foreign-Key Configuration:** Explicitly enabled via `db.execute('PRAGMA foreign_keys = ON');` inside `_configureDB`.
*   **Existing Tables Inventory:**
    *   `users`: `id` (PK AUTOINCREMENT), `first_name` (TEXT NOT NULL), `last_name` (TEXT NOT NULL), `email` (TEXT NOT NULL UNIQUE), `phone_number` (TEXT), `profile_image_path` (TEXT), `education_level` (TEXT NOT NULL), `experience_level` (TEXT), `created_at` (TEXT NOT NULL), `updated_at` (TEXT NOT NULL).
    *   `user_credentials`: `id` (PK), `user_id` (FK CASCADE), `password_hash`, `salt`, `algorithm`.
    *   `user_interests`: `id` (PK), `user_id` (FK CASCADE), `interest_name`, `created_at`, `UNIQUE(user_id, interest_name)`.
    *   `user_learning_goals`: `id` (PK), `user_id` (FK CASCADE), `goal_name`, `created_at`, `UNIQUE(user_id, goal_name)`.
*   **Safe Future Migration Recommendation:** To add Forum tables safely, the `version` in `openDatabase` must be bumped to `2`. An `onUpgrade` callback must be introduced in `DatabaseHelper` containing a `switch (oldVersion)` statement that executes `CREATE TABLE` for `forum_posts`, `forum_replies`, and `forum_likes` without touching V1 tables.

---

## D. Authentication Audit
*   **Login & Registration Flow:** Implemented in `auth_service.dart`. Passwords are mathematically hashed 10,000 times via `crypto`. Raw passwords are never stored.
*   **User Model & PK:** `User` model, primary key is `int? id`.
*   **Current-User/Session Retrieval:** `AuthService` handles sessions via `shared_preferences`. `_saveSession(userId)` writes to `session_user_id`. `getCurrentUserId()` reads this integer.
*   **Session Persistence:** Yes, standard key-value persistence across app restarts.
*   **Logout Behavior:** Clears `session_user_id` from SharedPreferences and routes the user back to `SignInScreen`, wiping the navigation stack.
*   **Recommended Retrieval for Forum Services:** 
    *   The `ForumService` should instantiate `AuthService` (or receive it via dependency injection) and call `await _authService.getCurrentUserId()`.
    *   If the ID is null, throw an `UnauthorizedException`.
    *   The retrieved integer ID should be securely mapped to the `user_id` foreign key when inserting new `forum_posts`.

---

## E. Architecture and Coding Conventions
*   **Model Patterns:** Standard Dart classes with `toMap()` and `factory .fromMap()`.
*   **Repository Patterns:** Classes wrapping SQLite queries. They accept and return typed Models (e.g., `Future<List<UserInterest>>`). Parameterized SQL queries (`whereArgs`) are strictly used.
*   **Service Patterns:** Business logic (e.g., password salting/hashing) lives here, sitting between the UI and Repositories.
*   **Error Handling:** Services throw standard `Exception(String)`. The UI catches these and displays them via `SnackBar` or `another_flushbar`.
*   **State Management:** Native `setState`.
*   **Database Access:** Wrapped in asynchronous transactions (`db.transaction((txn) async { ... })`) for bulk operations.
*   **Existing Tests:** Minimal to none configured in the current scope.

---

## F. Navigation and UI Audit
*   **Exact Forum Navbar Implementation:** `HomeScreen` uses an `IndexedStack` at `lib/features/home/screens/home_screen.dart`. Index `1` is currently occupied by a placeholder method `_buildPlaceholderScreen("Forum")`.
*   **Future Integration Point:** The `_buildPlaceholderScreen("Forum")` on Line 139 of `home_screen.dart` must be replaced with the actual `ForumScreen()`.
*   **Existing Theme/Color Locations:** Centralized in `AppTheme` (`lib/core/theme/app_theme.dart`). Colors used are `AppTheme.bg`, `AppTheme.accent`, `AppTheme.surface`, `AppTheme.textSoft`.
*   **Reusable Components:** `DrawerScreen` acts as the global menu. Floating navigation bar is completely custom math (Bezier curves).

---

## G. Proposed Forum File Map
*   **`lib/core/data/models/forum_post.dart`**: (Create) Represents a thread/post. Dependencies: None.
*   **`lib/core/data/models/forum_reply.dart`**: (Create) Represents a comment on a post. Dependencies: None.
*   **`lib/core/data/repositories/forum_repository.dart`**: (Create) It's cleaner to consolidate Post, Reply, and Like CRUD operations into one Repository to manage transactions efficiently, rather than 3 separate ones. Dependencies: `DatabaseHelper`.
*   **`lib/core/services/forum_service.dart`**: (Create) Business logic. Validates post length, links authenticated `userId` to the post, calls repository. Dependencies: `AuthService`, `ForumRepository`.
*   **`lib/features/forum/screens/forum_screen.dart`**: (Create) The main feed. Dependencies: `ForumService`. Replaces placeholder in `home_screen.dart`.
*   **`lib/features/forum/screens/create_post_screen.dart`**: (Create) Form to publish.
*   **`lib/features/forum/screens/post_detail_screen.dart`**: (Create) View full post and its replies.

---

## H. Risks and Unverified Items
*   [Unverified] **Database Upgrade Method:** The `onUpgrade` logic in `DatabaseHelper` currently does not exist. Implementing this incorrectly could wipe `users` table. This is the highest risk task.
*   [Inferred] **State Management for Feed:** Given the app relies purely on `setState`, maintaining scroll position and refreshing the Forum Feed when returning from `CreatePostScreen` will require careful `Navigator.push().then((_) => refreshFeed())` logic.

---

## I. Implementation Readiness Checklist
*   [x] Project root and architecture verified.
*   [x] Existing SQLite helper identified.
*   [x] Database filename and version verified.
*   [x] Existing schema inventoried.
*   [x] `users` primary key and schema verified.
*   [x] Authentication flow traced.
*   [x] Current authenticated user ID retrieval verified.
*   [x] Session and logout behavior understood.
*   [x] Repository and service conventions identified.
*   [x] Forum navbar integration points identified.
*   [x] Existing theme and reusable widgets identified.
*   [x] Migration risks documented.
*   [x] Planned file map prepared.

---

**Audit Complete. Do not modify application files until the implementation phase is authorized.**
