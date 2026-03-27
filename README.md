# Ikibina — Community Savings Group Management

Ikibina is a full-stack Flutter application for managing community savings groups (known as *Ikimina* in Rwandan culture). Members can create or join savings groups, make regular contributions, request peer-voted loans, and track their full financial history — all enforced by an automated 4-tier penalty system and delivered in English or Kinyarwanda.

---

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Screens & UI](#screens--ui)
4. [Architecture](#architecture)
5. [Project Structure](#project-structure)
6. [Data Models](#data-models)
7. [Services](#services)
8. [State Management](#state-management)
9. [Navigation](#navigation)
10. [Penalty System](#penalty-system)
11. [Loan System](#loan-system)
12. [Contribution System](#contribution-system)
13. [Authentication & KYC](#authentication--kyc)
14. [Multi-Language Support](#multi-language-support)
15. [Design System](#design-system)
16. [Firebase & Backend](#firebase--backend)
17. [Environment Variables](#environment-variables)
18. [Dependencies](#dependencies)
19. [Platform Support](#platform-support)
20. [Getting Started](#getting-started)
21. [Key Business Rules](#key-business-rules)
22. [Contributing](#contributing)

---

## Overview

| Property | Value |
| --- | --- |
| Framework | Flutter 3.x (Dart 3.5+) |
| State management | Provider |
| Backend | Firebase (Auth + Firestore + Storage) |
| Navigation | GoRouter |
| Email | Resend API |
| Image CDN | Cloudinary |
| Currency | RWF (Rwandan Franc) |
| Languages | English, Kinyarwanda |

---

## Features

### Group Types

Ikibina supports two fundamentally different group models.

#### Ikimina Groups (Rotating Savings & Loans)

- Fixed contribution amount per cycle (Weekly / Bi-weekly / Monthly)
- One contribution per member per cycle — automatically enforced
- Democratic loan system: members vote to approve or reject requests
- Loan pool capped at 50% of total group savings
- 4-tier automatic penalty escalation for missed contributions
- Admin-configurable penalty rules set at group creation or anytime in settings
- Member suspension and expulsion automation

#### Goal Groups (Milestone-Based Savings)

- 3 to 5 ordered milestones, each with a name and target amount
- Total goal = sum of milestone amounts
- Flexible contributions — no fixed amount or cycle restriction
- Progress tracking toward each milestone
- Leaderboard showing top contributors
- No penalty or loan system

### Core Capabilities

- **Authentication** — Email/password sign-up and sign-in via Firebase Auth
- **OTP Verification** — 6-digit email OTP (15-minute expiry, 5-attempt limit) via Resend API
- **Group Management** — Create, join (by invite code), edit, and delete groups
- **Contributions** — Record and track contributions with real-time Firestore sync
- **Loans** — Request, vote on, approve, reject, and repay loans with interest
- **Transactions** — Full ledger of contributions, loans, withdrawals, and fines
- **Penalty Automation** — Email + in-app notification reminders; automatic late fees, account freezes, and expulsions
- **KYC Verification** — Document uploads (ID front/back + selfie) with age verification
- **Profile Management** — Edit name, phone, and avatar (Cloudinary-hosted)
- **Multi-language** — Full English and Kinyarwanda UI with runtime switching
- **Dark/Light Theme** — Material 3 design with Google Fonts (Poppins + Sora)
- **Cross-platform** — Runs on Android, iOS, Web, macOS, and Windows

---

## Screens & UI

### Authentication & Onboarding

| Screen | Description |
| --- | --- |
| Splash | Animated splash with auth state detection |
| Onboarding | Feature showcase shown once on first launch |
| Language Selection | Choose English or Kinyarwanda before signing in |
| Register | Name, email, phone (with country picker), password |
| Email Verification | OTP entry screen; 6-digit code, resend support |
| Login | Email + password |
| Forgot Password | Firebase email reset link |

### Home & Dashboard

| Screen | Description |
| --- | --- |
| Home | Main hub: shows active group, quick actions, financial summary |
| Admin Home | Admin-specific view with member management shortcuts |
| Member Home | Member view: contribution status, loans, notifications |

### Group Management

| Screen | Description |
| --- | --- |
| Groups | List of all groups the user belongs to |
| Group Setup | Entry point: create new group or join with invite code |
| Create Group | Multi-step form for Ikimina or Goal groups, includes penalty configuration |
| Join Group | Enter 6-character invite code |
| Group Detail | Group summary and contribution history |
| Group Info | Tabbed hub: Members / Late Payments / Loan Request / Info / Penalties / Contributions |
| Edit Group | Modify name, description, image, contribution settings, milestones |
| Members | Full member list with search |
| Member Detail | Individual profile: contributions, loans, admin actions |
| Invite Member | Share invite code; send email invitations |

### Contributions & Finance

| Screen | Description |
| --- | --- |
| Add Contribution | Record a contribution (amount, note) |
| Contributions | History filtered by date, member, cycle |
| Transactions | Full ledger: contributions, loans, fines, withdrawals |

### Loans

| Screen | Description |
| --- | --- |
| Request Loan | Choose amount (≤ available pool) and duration (1–4 weeks) |
| Pay Loan | Repayment entry with live total-to-repay calculation |

### Profile & Settings

| Screen | Description |
| --- | --- |
| Profile | Menu: account info, KYC, security, payment, language, notifications, penalties |
| Profile Information | Edit name, phone, upload avatar |
| KYC Verification | ID type, ID number, DOB, country, address, document uploads |
| Penalties Info | Informational overview of all 4 penalty levels + user's active penalties |

### Group Penalties Tab

| Role | View |
| --- | --- |
| Admin | Toggle each rule on/off, edit thresholds, save policy, run manual checks, view full history |
| Member | Read-only rule display, personal penalty record |

---

## Architecture

```text
┌──────────────────────────────────────────────────────┐
│                  Flutter UI Layer                     │
│  Screens → Widgets → Providers (ChangeNotifier)      │
└───────────────────┬──────────────────────────────────┘
                    │
┌───────────────────▼──────────────────────────────────┐
│              Services Layer                          │
│  AuthService │ FirestoreService │ PenaltyService     │
│  OtpService  │ CloudinaryService │ LanguageService   │
└───────────────────┬──────────────────────────────────┘
                    │
┌───────────────────▼──────────────────────────────────┐
│                Backend Layer                         │
│  Firebase Auth │ Cloud Firestore │ Firebase Storage  │
│  Resend API (email) │ Cloudinary (images)            │
└──────────────────────────────────────────────────────┘
```

**Pattern**: The app uses the **Provider** pattern. Each provider wraps a service and exposes observable state to the widget tree. Screens call provider methods; providers call services; services talk to Firebase or external APIs.

---

## Project Structure

```text
lib/
├── app.dart                                # Root MaterialApp.router
├── main.dart                               # Bootstrap (Firebase init, dotenv, providers)
├── firebase_options.dart                   # Auto-generated Firebase config
│
├── config/
│   ├── routes.dart                         # GoRouter definitions + auth guard
│   └── theme.dart                          # Light & dark MaterialTheme
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart              # Collection names, transaction types, penalty types
│   │   └── countries.dart                  # Country list for registration picker
│   └── utils/
│       ├── formatters.dart                 # RWF currency, date, relative time formatting
│       └── validators.dart                 # Email, phone, amount, password validators
│
├── l10n/
│   └── app_strings.dart                    # Abstract AppStrings + EnStrings + RwStrings (1100+ lines)
│
├── models/
│   ├── user_model.dart
│   ├── group_model.dart                    # GroupModel + MilestoneModel
│   ├── penalty_model.dart                  # GroupPenaltyRules + PenaltyRecordModel
│   ├── loan_model.dart                     # LoanModel with interest/fee calculations
│   ├── contribution_model.dart
│   ├── transaction_model.dart
│   └── language_option.dart
│
├── providers/
│   ├── auth_provider.dart                  # AuthProvider — user auth state
│   ├── group_provider.dart                 # GroupProvider — groups stream + actions
│   └── locale_provider.dart               # LocaleProvider — language switching
│
├── services/
│   ├── auth_service.dart                   # Firebase Auth operations
│   ├── firestore_service.dart              # Firestore CRUD for all collections
│   ├── penalty_service.dart                # Automated penalty enforcement engine
│   ├── otp_service.dart                    # OTP generation, verification, invite emails
│   ├── cloudinary_service.dart             # Image CDN upload
│   └── language_service.dart              # SharedPreferences language persistence
│
├── screens/
│   ├── splash/splash_screen.dart
│   ├── Unsplash/on_boarding_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   └── email_verification_screen.dart
│   ├── language/language_selection_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── admin_home_screen.dart
│   │   └── member_home_screen.dart
│   ├── groups/
│   │   ├── groups_screen.dart
│   │   ├── group_setup_screen.dart
│   │   ├── create_group_screen.dart
│   │   ├── join_group_screen.dart
│   │   ├── group_detail_screen.dart
│   │   ├── group_info_screen.dart
│   │   ├── edit_group_screen.dart
│   │   ├── members_screen.dart
│   │   ├── member_detail_screen.dart
│   │   ├── invite_member_screen.dart
│   │   └── group_penalties_screen.dart
│   ├── contributions/
│   │   ├── add_contribution_screen.dart
│   │   └── contributions_screen.dart
│   ├── loans/
│   │   ├── request_loan_screen.dart
│   │   └── pay_loan_screen.dart
│   ├── transactions/transactions_screen.dart
│   └── profile/
│       ├── profile_screen.dart
│       ├── profile_information_screen.dart
│       ├── kyc_verification_screen.dart
│       └── penalties_info_screen.dart
│
└── widgets/
    ├── auth/country_picker_field.dart
    ├── cards/
    │   ├── group_card.dart
    │   └── contribution_card.dart
    ├── common/
    │   ├── custom_button.dart
    │   ├── custom_text_field.dart
    │   ├── error_banner.dart
    │   └── loading_indicator.dart
    └── user_avatar.dart
```

---

## Data Models

### UserModel

```text
id              String    Firebase UID
name            String
email           String
phone           String?
photoUrl        String?   Cloudinary URL
emailVerified   bool
createdAt       DateTime
activeGroupId   String?   Currently active group
activeGroupRole String?   'admin' | 'member'
```

### GroupModel

```text
id                    String
name                  String
description           String
createdBy             String    userId
adminId               String    defaults to createdBy
inviteCode            String    6-character alphanumeric
groupType             String    'ikimina' | 'goal'
contributionAmount    double    Ikimina only
contributionFrequency String    'Weekly' | 'Bi-weekly' | 'Monthly'
duration              String    '3 months' | '6 months' | '1 year'
milestones            List<MilestoneModel>   Goal only (3–5 items)
totalSavings          double
memberCount           int
members               List<String>   userIds
suspendedMembers      List<String>   userIds
imageUrl              String?
createdAt             DateTime
penaltyRules          GroupPenaltyRules?   Ikimina only
```

### MilestoneModel

```text
name          String
targetAmount  double
```

### LoanModel

```text
id              String
groupId         String
userId          String
userName        String
amount          double    Principal
durationWeeks   int       1–4 weeks
requestedAt     DateTime
dueDate         DateTime
status          String    'pending' | 'approved' | 'rejected' | 'completed'
approvedBy      List<String>
rejectedBy      List<String>
amountPaid      double

Constants
  processingFee   1,000 RWF (fixed)
  normalRate      7%
  overdueRate     15%

Computed
  interest        amount × rate
  totalToRepay    amount + interest + processingFee
  remaining       totalToRepay - amountPaid
  progress        amountPaid / totalToRepay  (0.0–1.0)
  isOverdue       DateTime.now().isAfter(dueDate)
```

### ContributionModel

```text
id        String
groupId   String
userId    String
userName  String
amount    double
date      DateTime
note      String?
```

### TransactionModel

```text
id          String
groupId     String
userId      String
userName    String
type        String    'contribution' | 'loan' | 'withdrawal' | 'fine'
amount      double
date        DateTime
description String?
```

### GroupPenaltyRules

```text
gentleReminderEnabled              bool    default: true
gentleReminderHoursAfterDeadline   int     default: 24
lateFeeEnabled                     bool    default: true
lateFeeDaysLate                    int     default: 3
lateFeePercent                     double  default: 5.0
accountFreezeEnabled               bool    default: false
accountFreezeCyclesMissed          int     default: 1
expulsionEnabled                   bool    default: false
expulsionCyclesMissed              int     default: 3
```

### PenaltyRecordModel

```text
id          String
groupId     String
groupName   String
userId      String
userName    String
type        String    'gentle_reminder' | 'late_fee' | 'account_freeze' | 'expulsion'
description String
amount      double    Non-zero for late_fee only
appliedAt   DateTime
resolved    bool
```

---

## Services

### AuthService

Wraps Firebase Auth.

| Method | Description |
| --- | --- |
| `signUp` | Create Firebase user + Firestore profile |
| `signIn` | Email/password authentication |
| `signOut` | Clears session |
| `sendOtp` | Generates OTP, saves to Firestore, sends email via Resend |
| `verifyOtp` | Validates entered OTP (expiry + attempt limit) |
| `resetPassword` | Firebase email reset |
| `updateProfile` | Edit name/phone in Firestore |
| `updatePhotoUrl` | Update Cloudinary avatar URL |

### FirestoreService

All Firestore CRUD operations.

| Domain | Methods |
| --- | --- |
| Groups | `createGroup`, `getGroup`, `getGroupByInviteCode`, `joinGroup`, `updateGroup`, `deleteGroup`, `getUserGroups` (stream) |
| Members | `removeMember`, `suspendMember`, `unsuspendMember` |
| Contributions | `addContribution` (with cycle enforcement), `getGroupContributions` (stream) |
| Loans | `requestLoan`, `voteOnLoan`, `payLoan`, `cancelLoan`, `getGroupLoans` (stream), `getAvailableLoanLimit` |
| Transactions | `getGroupTransactions` (stream) |

**Cycle enforcement** in `addContribution`: For Ikimina groups, queries all contributions for the group and filters client-side to check whether the member has already contributed within the current cycle window (7 / 14 / 30 days). Throws a descriptive error on duplicate.

### PenaltyService

Automated enforcement engine for Ikimina groups.

Main entry point:

```dart
Future<List<String>> runChecks(GroupModel group)
```

Triggered by the admin from the Penalties tab. Steps:

1. Fetches all contributions for the group
2. Fetches all member emails and names
3. For each non-admin member, calculates current cycle start and deadline, counts total missed cycles since group creation
4. Checks each enabled penalty tier
5. Writes a `penaltyChecks` document with key `{groupId}_{userId}_{cycleKey}_{type}` to prevent double-applying
6. Returns a human-readable log of all actions taken

Penalty actions:

- **Gentle Reminder** → `notifications` doc + `penaltyRecords` doc + Resend email
- **Late Fee** → `transactions` doc (type: `fine`) + `notifications` + `penaltyRecords`
- **Account Freeze** → adds member to `suspendedMembers` + `notifications` + `penaltyRecords`
- **Expulsion** → removes from `members`, decrements `memberCount`, clears `activeGroupId` + `penaltyRecords` for history

### OtpService

- Generates 6-digit random OTP
- Stores in `otps/{email}` with expiry timestamp and attempt counter
- Sends HTML email via Resend API
- `verifyOtp` returns: `success | invalid | expired | notFound | alreadyUsed`

### CloudinaryService

- Accepts `Uint8List` bytes + a public ID string
- POSTs to Cloudinary upload endpoint
- Returns the CDN URL stored in Firestore

---

## State Management

Three `ChangeNotifier` providers registered at app root.

### AuthProvider

```text
Properties   user (UserModel?), loading, error, isAuthenticated
Methods      signUp, signIn, signOut, sendOtp, verifyOtp,
             resetPassword, changePassword, updateProfile, updatePhotoUrl
```

Listens to `FirebaseAuth.authStateChanges`. On login, loads `UserModel` from Firestore. On logout, nullifies state.

### GroupProvider

```text
Properties   groups (List<GroupModel>), currentGroup, loading, error, hasAttemptedLoad
Methods      loadUserGroups, createGroup, joinGroup, deleteGroup,
             updateGroup, addContribution, reset
```

Streams user's groups from Firestore in real-time. `reset()` cancels the subscription and clears state — called on logout.

### LocaleProvider

```text
Properties   locale (Locale), strings (AppStrings), languageName
Methods      setLanguage(String code)
```

Persists the selected language code to `SharedPreferences` via `LanguageService`. Rebuilds the entire app on language change.

---

## Navigation

GoRouter with a global auth redirect guard.

```text
/                    HomeScreen             (auth required)
/login               LoginScreen
/register            RegisterScreen
/forgot-password     ForgotPasswordScreen
/groups              GroupsScreen           (auth required)
/groups/create       CreateGroupScreen      (auth required)
/groups/:id          GroupDetailScreen      (auth required)
/contributions/add   AddContributionScreen  (auth required)
/profile             ProfileScreen          (auth required)
/kyc                 KycVerificationScreen  (auth required)
```

Unauthenticated users accessing protected routes are redirected to `/login`. Authenticated users accessing auth routes are redirected to `/`.

Sub-screens (GroupInfoScreen, EditGroupScreen, MemberDetailScreen, etc.) use `Navigator.push` / `MaterialPageRoute` rather than named GoRouter routes.

---

## Penalty System

Only applies to **Ikimina groups**. Configured by the group admin.

### 4 Escalation Levels

| Level | Name | Default Trigger | Action | On by Default |
| --- | --- | --- | --- | --- |
| 1 | Gentle Reminder | 24 h after deadline | Push notification + email | Yes |
| 2 | Late Fee | 3 days late | Fine = 5% of contribution | Yes |
| 3 | Account Freeze | 1 cycle missed | Suspend — no loans or payouts | No |
| 4 | Expulsion | 3 cycles missed | Permanent removal from group | No |

All thresholds are fully configurable per group by the admin.

### Where Rules Are Set

1. **Group creation** (`create_group_screen.dart`) — `_PenaltySetupCard` lets the admin toggle each level on/off. Rules saved with the group document.
2. **Group → Penalties tab** (`group_penalties_screen.dart`) — Full edit UI for admins. Members see read-only.

### Cycle Calculation

```text
cycleDays    = 7 (Weekly) | 14 (Bi-weekly) | 30 (Monthly)
elapsedDays  = now − groupCreatedAt
cycleIndex   = floor(elapsedDays / cycleDays)
cycleStart   = groupCreatedAt + cycleIndex × cycleDays
cycleDeadline = cycleStart + cycleDays
```

### Idempotency

Each penalty application writes a document to:

```text
penaltyChecks/{groupId}_{userId}_{cycleKey}_{penaltyType}
```

Before applying any penalty, the service checks whether that document exists. This guarantees each penalty fires at most once per member per cycle.

### Notifications

- **Email** — Resend API, HTML template, best-effort (failure does not block other penalties)
- **In-app** — Document written to `notifications/{id}`; read on the user's next session

---

## Loan System

Available in **Ikimina groups only**.

### Flow

```text
Member requests loan
        ↓
Available pool check (50% of totalSavings − active loans)
        ↓
Loan status: 'pending' — all other members can vote
        ↓
>50% approve  →  status = 'approved'
≥50% reject   →  status = 'rejected'
        ↓
Member repays in installments via Pay Loan screen
        ↓
amountPaid ≥ totalToRepay  →  status = 'completed'
```

### Interest & Fees

```text
Processing fee   1,000 RWF (fixed, always applied)
Normal rate      7%  of principal
Overdue rate     15% of principal (if repaid past dueDate)
Total to repay   principal + interest + processingFee
```

### Loan Pool

```text
pool      = totalSavings × 0.5
used      = sum of amounts for loans with status 'approved' or 'pending'
available = max(0, pool − used)
```

---

## Contribution System

### Ikimina Groups

- Fixed amount set at group creation (editable by admin)
- One contribution per cycle per member — enforced server-side in `FirestoreService.addContribution`
- Cycle boundaries calculated from `group.createdAt`
- Suspended members are blocked from contributing
- Each contribution increments `group.totalSavings`

### Goal Groups

- Flexible amount — no minimum or fixed requirement
- No cycle restriction — contribute any time
- Contributions tracked for milestone progress

### Cycle Enforcement (Ikimina)

```dart
cutoff     = DateTime.now() - Duration(days: cycleDays)
alreadyPaid = contributions
  .where((c) => c.userId == userId && c.date.isAfter(cutoff))
  .isNotEmpty
if (alreadyPaid) throw Exception('Already contributed this cycle')
```

---

## Authentication & KYC

### Sign-Up Flow

```text
1. User fills: name, email, phone (+ country code), password
2. Firebase Auth creates user (email/password)
3. Firestore: users/{uid} document created
4. OtpService generates 6-digit code → saved to otps/{email}
5. Resend API sends OTP email
6. User navigates to EmailVerificationScreen
7. Enters OTP → OtpService.verifyOtp()
8. On success: emailVerified = true in Firestore + Firebase Auth
9. Routes to GroupSetupScreen
```

### Sign-In Flow

```text
1. Firebase Auth signInWithEmailAndPassword
2. AuthProvider loads UserModel from Firestore
3. Routes to HomeScreen
```

### KYC Verification

Collects:

- ID Type (National ID / Passport / Driver's License)
- ID Number
- Date of Birth (must be 18+)
- Country
- Address
- ID Front photo (ImagePicker, 75% quality, max 1200 px)
- ID Back photo
- Selfie photo

> Note: Document upload backend is ready for connection to an external verification API (e.g. Onfido, Jumio).

---

## Multi-Language Support

The app supports **English** and **Kinyarwanda** with 200+ translated strings.

### Implementation

```dart
abstract class AppStrings {
  String get appName;
  String get login;
  // 200+ properties
}

class EnStrings implements AppStrings { /* English */ }
class RwStrings implements AppStrings { /* Kinyarwanda */ }
```

`LocaleProvider` holds the current `AppStrings` instance. Every widget accesses strings via:

```dart
final s = context.watch<LocaleProvider>().strings;
Text(s.someKey)
```

Language selection is persisted to `SharedPreferences` via `LanguageService` and restored on next launch.

### Adding a New Language

1. Create a new class implementing `AppStrings`
2. Add the language code to `LocaleProvider.setLanguage`
3. Add the option to `language_selection_screen.dart`

---

## Design System

### Colors

| Role | Hex | Usage |
| --- | --- | --- |
| Primary | `#1B5E20` | App bar, primary actions, theme seed |
| Secondary | `#4CAF50` | Secondary buttons, highlights |
| Accent | `#FFC107` | Amber highlights |
| Error | `#D32F2F` | Destructive actions, error states |
| Ink | `#1A1A1A` | Primary text, dark card backgrounds |
| Background | `#F5F5F5` | Screen backgrounds |
| Surface | `#FFFFFF` | Cards, containers |
| Grey | `#888888` | Secondary text, hints |
| Border | `#E0E0E0` | Dividers, input borders |

### Typography

| Font | Usage |
| --- | --- |
| **Sora** | Large headings, group names, titles |
| **Poppins** | Section headers, buttons, medium-weight text |
| **Inter** | Body text, descriptions, list items |

All loaded via the `google_fonts` package.

### Component Patterns

- Cards: white background, `BorderRadius.circular(12)`, `Border.all(color: Colors.grey.shade200)`
- Buttons: `BorderRadius.circular(12–14)`, black fill for primary, outlined for secondary
- Input fields: white fill, grey border, black focus border, Sora font
- Tabs: pill-shaped, `#1A1A1A` selected / grey unselected
- Avatars: `CircleAvatar` with initials fallback when no photo URL is set

### Material 3

The app uses `useMaterial3: true` with a custom color scheme seeded from the primary green. Rounded corners are applied globally via `CardTheme`, `InputDecorationTheme`, and `ElevatedButtonTheme`.

---

## Firebase & Backend

### Firebase Project

| Property | Value |
| --- | --- |
| Project ID | `ikibina-f5729` |
| Auth Domain | `ikibina-f5729.firebaseapp.com` |
| Storage Bucket | `ikibina-f5729.firebasestorage.app` |

### Firestore Collections

| Collection | Purpose | Key Fields |
| --- | --- | --- |
| `users` | User profiles | id, name, email, phone, photoUrl, emailVerified, activeGroupId, activeGroupRole |
| `groups` | Savings groups | id, name, groupType, members[], adminId, penaltyRules, totalSavings |
| `contributions` | Contribution records | groupId, userId, amount, date |
| `loans` | Loan requests & repayments | groupId, userId, amount, status, approvedBy[], rejectedBy[], amountPaid |
| `transactions` | Full financial ledger | groupId, userId, type, amount, date |
| `penaltyRecords` | Penalty application history | groupId, userId, type, description, amount, appliedAt |
| `penaltyChecks` | Idempotency markers | Document ID = `{groupId}_{userId}_{cycleKey}_{penaltyType}` |
| `notifications` | In-app notifications | userId, groupId, type, title, body, read, createdAt |
| `otps` | OTP verification records | email, otp, uid, expiresAt, verified, attempts |

### Query Strategy

Composite Firestore indexes are avoided where possible. Complex filtering (e.g., contributions for a specific user within a cycle) is done client-side after a single-field query, keeping the Firestore index configuration minimal.

### Firebase Storage

Used for profile images. Group images are hosted on Cloudinary to avoid Firebase Storage egress costs.

Storage path: `profile_images/{userId}`

### Recommended Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    match /groups/{groupId} {
      allow read: if request.auth != null &&
                     request.auth.uid in resource.data.members;
      allow write: if request.auth != null &&
                      request.auth.uid == resource.data.adminId;
    }
    match /{collection}/{docId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## Environment Variables

Create a `.env` file in the project root (already listed in `pubspec.yaml` assets and in `.gitignore`):

```sh
# Email service — https://resend.com
RESEND_API_KEY=re_xxxxxxxxxxxxxxxxxxxx

# Image CDN — https://cloudinary.com
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_UPLOAD_PRESET=your_upload_preset
```

> **Never commit `.env` to version control.**

---

## Dependencies

```yaml
# Firebase
firebase_core: ^3.13.0
firebase_auth: ^5.5.2
cloud_firestore: ^5.6.5
firebase_storage: ^12.4.5

# Navigation
go_router: ^14.6.2

# State Management
provider: ^6.1.2

# UI & Fonts
google_fonts: ^6.2.1
cached_network_image: ^3.4.1
flutter_svg: ^2.0.10+1
cupertino_icons: ^1.0.8

# HTTP & APIs
http: ^1.2.2

# Utilities
intl: ^0.20.2
shared_preferences: ^2.3.3
image_picker: ^1.1.2
uuid: ^4.5.1
flutter_dotenv: ^5.2.1

# Localisation (Flutter SDK)
flutter_localizations:
```

---

## Platform Support

| Platform | Status | Notes |
| --- | --- | --- |
| Android | Supported | `google-services.json` configured |
| iOS | Supported | `GoogleService-Info.plist` configured |
| Web | Supported | Firebase JS SDK configured |
| macOS | Supported | Configured with FlutterFire |
| Windows | Supported | Configured with FlutterFire |
| Linux | Not configured | Requires FlutterFire setup |

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.5.0`
- Dart SDK `>=3.5.0`
- A Firebase project (free Spark plan is sufficient)
- A [Resend](https://resend.com) account (free tier: 3,000 emails/month)
- A [Cloudinary](https://cloudinary.com) account (free tier: 25 GB storage)

### 1. Clone the repository

```bash
git clone <repository-url>
cd Ikibina_app
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=your-firebase-project-id
```

This regenerates `lib/firebase_options.dart` for your project.

### 4. Set up environment variables

```bash
cp .env.example .env
# Edit .env with your API keys
```

### 5. Run the app

```bash
# Android / iOS
flutter run

# Web
flutter run -d chrome

# Windows
flutter run -d windows

# macOS
flutter run -d macos
```

### 6. Build for production

```bash
# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release
```

---

## Key Business Rules

| Rule | Detail |
| --- | --- |
| One contribution per cycle | Ikimina members can only contribute once per cycle window |
| Loan pool cap | Maximum loanable = 50% of total savings |
| Loan interest — normal | 7% of principal |
| Loan interest — overdue | 15% of principal (past due date) |
| Processing fee | Fixed 1,000 RWF on every approved loan |
| Voting | Simple majority of non-requester members; >50% approve to activate |
| Penalty idempotency | Each penalty applied at most once per (member, cycle, type) |
| Member suspension | Suspended members cannot contribute or request loans |
| Cycle boundaries | Calculated from group creation date, not calendar month |
| Ikimina only | Penalties and loans are exclusive to Ikimina-type groups |
| Admin role | One admin per group (the creator by default) |

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add your feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a pull request against `main`

Code style conventions:

- `GoogleFonts.sora` for headings, `GoogleFonts.inter` for body text
- `const _ink = Color(0xFF1A1A1A)` for the primary dark colour token
- Services are thin — business logic lives in services, not widgets
- Avoid composite Firestore indexes; filter client-side where practical

---

## License

This project is proprietary. All rights reserved.

---

*Built with Flutter · Powered by Firebase · Ikibina — Saving together.*
