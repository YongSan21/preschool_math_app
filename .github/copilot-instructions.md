# Project Context
This project is a gamified, interactive mathematics learning application ("Math Farm") designed for preschool children aged 4 to 6.
The learning progression is heavily scaffolded, moving from concrete concepts to abstract symbols using the Triple-Code Model (Analogue Magnitude -> Auditory Verbal -> Visual Arabic).
The application must maintain a low-pressure environment: no competitive leaderboards, no countdown timers, and no harsh failure states.

# Tech Stack & Backend
- Frontend: Flutter (Dart)
- Backend: Firebase (Authentication and Cloud Firestore)
- Auth Logic: Uses a "dummy email" workaround for Firebase Auth to generate secure UIDs without collecting children's personal data.

# Architecture: Strict Feature-First
The project strictly follows a Feature-First Architecture inside the `lib/` directory. Global folders for models or services are NOT allowed.

- `lib/core/`: Contains ONLY app-wide shared resources used across two or more features. This includes `constants/` (global colors, typography, audio paths) and `widgets/` (globally reusable UI components like a standard back button).
- `lib/features/`: Contains highly encapsulated, self-contained feature modules (e.g., `auth`, `map`, `counting`, `addition`, `subtraction`, `badge_room`). 

**Feature Isolation Rule:**
Every feature folder MUST contain its own specific data, logic, and UI. A standard feature directory should look like this:
- `models/`: Data blueprints and Firebase DTOs strictly for this feature (e.g., `user_profile.dart` inside `auth/`).
- `services/`: Backend communication and API logic for this feature (e.g., `auth_service.dart` inside `auth/`).
- `controllers/`: State management and business logic.
- `screens/`: The Flutter UI pages.
- `widgets/`: Reusable UI components that are used multiple times, but ONLY within this specific feature.

# UI/UX & Coding Constraints
- UI Strategy: Use a "Configuration-Driven UI" approach. Build one reusable screen per feature (e.g., `counting_level_screen.dart`) that dynamically updates its layout and logic based on a configuration model.
- Gestures: Limit interactions to simple tapping and dragging. Ensure tap targets are large enough for developing fine motor skills.
- Typography: Always use single-story typography for numbers and letters to maximize readability.
- Navigation: Avoid nested menus and traditional bottom navigation bars. Use flat, map-based navigation.
- Performance: Learning activities must load within 3 seconds.
- Responsiveness: Ensure all layouts scale cleanly for Android smartphone aspect ratios (9:16), utilizing widgets like `Stack` and `Positioned` for map layouts.

# Code Generation Rules
- Prioritize clean, readable Dart code. Use `StatelessWidget` where possible and keep state management simple.
- Do not generate text-heavy alert dialogs for errors; default to visual scaffolding and positive reinforcement animations.