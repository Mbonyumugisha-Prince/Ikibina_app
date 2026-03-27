class AppConstants {
  // App info
  static const String appName = 'Ikibina';
  static const String appVersion = '1.0.0';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String groupsCollection = 'groups';
  static const String membersCollection = 'members';
  static const String contributionsCollection = 'contributions';
  static const String transactionsCollection = 'transactions';
  static const String loansCollection = 'loans';
  static const String penaltyRecordsCollection = 'penaltyRecords';
  static const String penaltyChecksCollection = 'penaltyChecks';
  static const String notificationsCollection = 'notifications';

  // Firebase Storage paths
  static const String profileImagesPath = 'profile_images';
  static const String groupImagesPath = 'group_images';

  // SharedPreferences keys
  static const String prefOnboarded = 'onboarded';
  static const String prefThemeMode = 'theme_mode';

  // Group types
  static const String groupTypeIkimina = 'ikimina';
  static const String groupTypeGoal = 'goal';

  // Contribution frequency options
  static const List<String> contributionFrequencies = [
    'Weekly',
    'Bi-weekly',
    'Monthly',
  ];

  // Ikimina duration options
  static const List<String> groupDurations = [
    '3 months',
    '6 months',
    '1 year',
  ];

  // Transaction types
  static const String transactionContribution = 'contribution';
  static const String transactionLoan = 'loan';
  static const String transactionWithdrawal = 'withdrawal';
  static const String transactionFine = 'fine';

  // Penalty types
  static const String penaltyGentleReminder = 'gentle_reminder';
  static const String penaltyLateFee = 'late_fee';
  static const String penaltyAccountFreeze = 'account_freeze';
  static const String penaltyExpulsion = 'expulsion';
}
