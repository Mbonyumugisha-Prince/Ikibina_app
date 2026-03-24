// ─────────────────────────────────────────
//  BASE — abstract string contract
// ─────────────────────────────────────────
abstract class AppStrings {
  // Onboarding
  String get appTagline;
  String get onboardingTitle2;
  String get onboardingSubtitle2;
  String get onboardingTitle3;
  String get onboardingSubtitle3;
  String get getStarted;
  String get alreadyHaveAccount;
  String get skip;
  String get secure;

  // Language screen
  String get chooseLanguage;
  String get chooseLanguageSubtitle;
  String get savePreference;
  String get language;

  // Auth
  String get signIn;
  String get signUp;
  String get email;
  String get password;
  String get fullName;
  String get forgotPassword;
  String get noAccount;
  String get haveAccount;
  String get loginFailed;
  // Login screen
  String get welcomeBack;
  String get loginSubtitle;
  String get phoneNumber;
  String get enterPassword;
  String get logIn;
  String get orDivider;
  // Register screen
  String get createYourAccount;
  String get registerSubtitle;
  String get enterFullName;
  String get enterEmail;
  String get createPassword;
  String get confirmPassword;
  String get repeatPassword;
  String get createAccount;
  String get iAgreeTo;
  String get termsOfService;
  String get and;
  String get privacyPolicy;
  String get fillAllFields;
  String get passwordsNoMatch;
  String get acceptTerms;
  String get noAccountPrefix;
  String get haveAccountPrefix;
  // Forgot password screen
  String get forgotPasswordTitle;
  String get forgotPasswordSubtitle;
  String get emailLabel;
  String get emailHint;
  String get sendResetLink;
  String get backToLogin;
  String get checkInbox;
  String get checkInboxSubtitle;
  String get didntReceive;
  String get enterEmailFirst;
  String get failedToSend;

  // OTP verification
  String get otpTitle;
  String get otpSubtitle;
  String get otpExpiry;
  String get otpVerify;
  String get otpResend;
  String get otpResendIn;
  String get otpSeconds;
  String get otpInvalid;
  String get otpEnterAll;
  String get otpSending;

  // Email verification
  String get verifyEmailTitle;
  String get verifyEmailSubtitle;
  String get verifyEmailSentTo;
  String get openEmailApp;
  String get resendEmail;
  String get iHaveVerified;
  String get emailNotVerifiedYet;
  String get verificationEmailResent;
  String get emailVerifiedSuccess;

  // Home / navigation
  String get home;
  String get groups;
  String get contributions;
  String get transactions;
  String get profile;

  // Groups
  String get createGroup;
  String get joinGroup;
  String get myGroups;
  String get groupName;
  String get members;
  String get totalSaved;
  
  // Group Creation
  String get createGroupTitle;
  String get createGroupSubtitle;
  String get groupInviteCode;
  String get shareCodeWithMembers;
  String get groupNameLabel;
  String get groupNameHint;
  String get descriptionLabel;
  String get descriptionHint;
  String get contributionAmountLabel;
  String get frequencyLabel;
  String get createGroupButton;
  String get fillAllRequiredFields;
  String get invalidContributionAmount;
  String get failedToCreateGroup;
  String get codeCopiedMessage;
  
  // Group Join
  String get joinGroupTitle;
  String get joinGroupSubtitle;
  String get inviteCodeLabel;
  String get inviteCodeHint;
  String get joinGroupButton;
  String get invalidInviteCode;
  String get groupNotFound;
  
  // Group Setup
  String get setupGroupOrJoin;
  String get createNewGroup;
  String get createNewGroupDesc;
  String get joinExistingGroup;
  String get joinExistingGroupDesc;
  
  // Group Invite
  String get inviteMemberTitle;
  String get memberEmailLabel;
  String get memberEmailHint;
  String get sendInviteText;
  String get inviteSentMessage;
  String get failedToSendInvite;
  String get validEmailRequired;

  // Contributions
  String get addContribution;
  String get amount;
  String get date;
  String get status;
  String get paid;
  String get pending;

  // Profile/Settings
  String get phone;
  String get signOut;
  
  // Common UI
  String get noGroupsYet;
  String get createOrJoinGroup;
  String get myGroupsTitle;
  String get failedToLoadContributions;
  String get noContributionsYet;
  String get failedToLoadTransactions;
  String get noTransactionsYet;
  String get totalSavings;
  String get loadingGroup;
  String get appTitle;
  String get groupDetail;
  String get failedToAddContribution;
  String get ikibina;
  
  // Dashboard/Home
  String get hello;
  String get groupAdmin;
  String get groupMember;
  String get groupOverview;
  String get yourGroup;
  String get quickActions;
  String get inviteMember;
  String get myContributions;
  String get groupMembers;
  String get myProfile;
  String get nextContribution;
  String get groupTotal;
  String get perCycle;
  
  // Form Validation Messages
  String get emailRequired;
  String get emailInvalid;
  String get passwordRequired;
  String get passwordTooShort;
  String get phoneRequired;
  String get phoneInvalid;
  String get amountRequired;
  String get amountInvalid;
  String get amountMustBeGreater;
  String get fieldRequired;
  
  // Common
  String get save;
  String get cancel;
  String get confirm;
  String get loading;
  String get error;
  String get success;
  String get back;
}

// ─────────────────────────────────────────
//  ENGLISH
// ─────────────────────────────────────────
class EnStrings extends AppStrings {
  @override String get appTagline         => 'Smart Group Savings, Made Simple';
  @override String get onboardingTitle2   => 'Save Together,\nGrow Together';
  @override String get onboardingSubtitle2 =>
      'Create or join a savings group with\nfriends, family or colleagues.\nEveryone contributes, everyone benefits.';
  @override String get onboardingTitle3   => 'Track Savings &\nWithdraw Anytime';
  @override String get onboardingSubtitle3 =>
      'Monitor your group\'s progress in\nreal time. Request withdrawals\nwhenever you\'re ready.';
  @override String get getStarted         => 'Get Started';
  @override String get alreadyHaveAccount => 'I already have an account';
  @override String get skip               => 'Skip';
  @override String get secure             => 'SECURE';

  @override String get chooseLanguage        => 'Choose your language';
  @override String get chooseLanguageSubtitle =>
      'Select your preferred language to continue\nusing the app.';
  @override String get savePreference => 'Save Preference';
  @override String get language       => 'Language';

  @override String get signIn          => 'Sign In';
  @override String get signUp          => 'Sign Up';
  @override String get email           => 'Email';
  @override String get password        => 'Password';
  @override String get fullName        => 'Full Name';
  @override String get forgotPassword  => 'Forgot Password?';
  @override String get noAccount       => 'Don\'t have an account? Sign Up';
  @override String get haveAccount     => 'Already have an account? Sign In';
  @override String get loginFailed     => 'Login failed. Please try again.';
  @override String get welcomeBack     => 'Welcome back';
  @override String get loginSubtitle   => 'Log in to your Ikimina account';
  @override String get phoneNumber     => 'Phone Number';
  @override String get enterPassword   => 'Enter your password';
  @override String get logIn           => 'Log In';
  @override String get orDivider       => 'OR';
  @override String get createYourAccount => 'Create your account';
  @override String get registerSubtitle  => 'Join Ikimina and start saving together';
  @override String get enterFullName   => 'Enter your full name';
  @override String get enterEmail      => 'Enter your email';
  @override String get createPassword  => 'Create a password';
  @override String get confirmPassword => 'Confirm Password';
  @override String get repeatPassword  => 'Repeat your password';
  @override String get createAccount   => 'Create Account';
  @override String get iAgreeTo        => 'I agree to the ';
  @override String get termsOfService  => 'Terms of Service';
  @override String get and             => ' and ';
  @override String get privacyPolicy   => 'Privacy Policy';
  @override String get fillAllFields    => 'Please fill in all fields';
  @override String get passwordsNoMatch => 'Passwords do not match';
  @override String get acceptTerms      => 'Please accept the terms to continue';
  @override String get noAccountPrefix       => "Don't have an account?  ";
  @override String get haveAccountPrefix     => 'Already have an account?  ';
  @override String get forgotPasswordTitle   => 'Forgot Password?';
  @override String get forgotPasswordSubtitle => 'No worries! Enter your email and we\'ll send you a reset link.';
  @override String get emailLabel            => 'Email';
  @override String get emailHint             => 'Enter your email address';
  @override String get sendResetLink         => 'Send Reset Link';
  @override String get backToLogin           => 'Back to Log In';
  @override String get checkInbox            => 'Check your inbox';
  @override String get checkInboxSubtitle    => 'We\'ve sent a password reset link to';
  @override String get didntReceive          => 'Didn\'t receive it? Check your spam folder.';
  @override String get enterEmailFirst       => 'Please enter your email address';
  @override String get failedToSend          => 'Failed to send reset link';

  @override String get otpTitle       => 'Verify your email';
  @override String get otpSubtitle    => 'We sent a 6-digit code to';
  @override String get otpExpiry      => 'Code expires in 15 minutes';
  @override String get otpVerify      => 'Verify Email';
  @override String get otpResend      => 'Resend Code';
  @override String get otpResendIn    => 'Resend in';
  @override String get otpSeconds     => 'seconds';
  @override String get otpInvalid     => 'Invalid or expired code. Try again.';
  @override String get otpEnterAll    => 'Please enter all 6 digits';
  @override String get otpSending     => 'Sending code...';

  @override String get verifyEmailTitle       => 'Verify your email';
  @override String get verifyEmailSubtitle    => 'We sent a verification link to your email. Please check your inbox and tap the link to activate your account.';
  @override String get verifyEmailSentTo      => 'Sent to';
  @override String get openEmailApp           => 'Open Email App';
  @override String get resendEmail            => 'Resend Email';
  @override String get iHaveVerified          => 'I\'ve verified my email';
  @override String get emailNotVerifiedYet    => 'Email not verified yet. Please check your inbox.';
  @override String get verificationEmailResent => 'Verification email resent!';
  @override String get emailVerifiedSuccess   => 'Email verified! Welcome to Ikimina.';

  @override String get home          => 'Home';
  @override String get groups        => 'Groups';
  @override String get contributions => 'Contributions';
  @override String get transactions  => 'Transactions';
  @override String get profile       => 'Profile';

  @override String get createGroup  => 'Create Group';
  @override String get joinGroup    => 'Join Group';
  @override String get myGroups     => 'My Groups';
  @override String get groupName    => 'Group Name';
  @override String get members      => 'Members';
  @override String get totalSaved   => 'Total Saved';
  
  // Group Creation
  @override String get createGroupTitle    => 'Create a Group';
  @override String get createGroupSubtitle => 'Set up your savings group details.';
  @override String get groupInviteCode     => 'Group Invite Code';
  @override String get shareCodeWithMembers => 'Share this code with members so they can join.';
  @override String get groupNameLabel  => 'Group Name *';
  @override String get groupNameHint   => 'e.g. Ubumwe Savings';
  @override String get descriptionLabel => 'Description';
  @override String get descriptionHint  => 'What is this group for?';
  @override String get contributionAmountLabel => 'Contribution Amount (RWF) *';
  @override String get frequencyLabel => 'Frequency';
  @override String get createGroupButton => 'Create Group';
  @override String get fillAllRequiredFields => 'Please fill in all required fields.';
  @override String get invalidContributionAmount => 'Please enter a valid contribution amount.';
  @override String get failedToCreateGroup => 'Failed to create group. Please try again.';
  @override String get codeCopiedMessage => 'Invite code copied!';
  
  // Group Join
  @override String get joinGroupTitle => 'Join a Group';
  @override String get joinGroupSubtitle => 'Enter the 6-character invite code\nshared by your group admin.';
  @override String get inviteCodeLabel => 'Invite Code';
  @override String get inviteCodeHint => 'ABC123';
  @override String get joinGroupButton => 'Join Group';
  @override String get invalidInviteCode => 'Please enter a valid 6-character invite code.';
  @override String get groupNotFound => 'Group not found. Check the code and try again.';
  
  // Group Setup
  @override String get setupGroupOrJoin => 'Create a new savings group or\njoin an existing one with an invite code.';
  @override String get createNewGroup => 'Create a Group';
  @override String get createNewGroupDesc => 'Start a new Ikimina savings group.\nYou will be the group admin.';
  @override String get joinExistingGroup => 'Join a Group';
  @override String get joinExistingGroupDesc => 'Enter an invite code shared\nby your group admin.';
  
  // Group Invite
  @override String get inviteMemberTitle => 'Invite Member';
  @override String get memberEmailLabel => 'Member\'s Email';
  @override String get memberEmailHint => 'member@example.com';
  @override String get sendInviteText => 'The member will receive an email with the invite code and instructions to join the group.';
  @override String get inviteSentMessage => 'Invite sent to';
  @override String get failedToSendInvite => 'Failed to send invite. Please try again.';
  @override String get validEmailRequired => 'Please enter a valid email address.';

  @override String get addContribution => 'Add Contribution';
  @override String get amount          => 'Amount';
  @override String get date            => 'Date';
  @override String get status          => 'Status';
  @override String get paid            => 'Paid';
  @override String get pending         => 'Pending';

  @override String get save    => 'Save';
  @override String get cancel  => 'Cancel';
  @override String get confirm => 'Confirm';
  @override String get loading => 'Loading...';
  @override String get error   => 'Error';
  @override String get success => 'Success';
  @override String get back    => 'Back';
  
  // Profile/Settings
  @override String get phone      => 'Phone';
  @override String get signOut    => 'Sign Out';
  
  // Common UI
  @override String get noGroupsYet              => 'No groups yet';
  @override String get createOrJoinGroup       => 'Create or join a savings group';
  @override String get myGroupsTitle           => 'My Groups';
  @override String get failedToLoadContributions => 'Failed to load contributions.';
  @override String get noContributionsYet      => 'No contributions yet.';
  @override String get failedToLoadTransactions => 'Failed to load transactions.';
  @override String get noTransactionsYet       => 'No transactions yet.';
  @override String get totalSavings            => 'Total savings';
  @override String get loadingGroup            => 'Loading group...';
  @override String get appTitle                => 'Ikibina';
  @override String get groupDetail             => 'Group Details';
  @override String get failedToAddContribution => 'Failed to add contribution';
  @override String get ikibina                 => 'Ikibina';
  
  // Dashboard/Home
  @override String get hello                => 'Hello';
  @override String get groupAdmin           => 'Group Admin';
  @override String get groupMember          => 'Group Member';
  @override String get groupOverview        => 'GROUP OVERVIEW';
  @override String get yourGroup            => 'YOUR GROUP';
  @override String get quickActions         => 'Quick Actions';
  @override String get inviteMember         => 'Invite Member';
  @override String get myContributions      => 'My Contributions';
  @override String get groupMembers         => 'Group Members';
  @override String get myProfile            => 'My Profile';
  @override String get nextContribution     => 'Next Contribution';
  @override String get groupTotal           => 'Group Total';
  @override String get perCycle             => 'per cycle';
  
  // Form Validation Messages
  @override String get emailRequired       => 'Email is required';
  @override String get emailInvalid       => 'Enter a valid email address';
  @override String get passwordRequired   => 'Password is required';
  @override String get passwordTooShort   => 'Password must be at least 6 characters';
  @override String get phoneRequired      => 'Phone number is required';
  @override String get phoneInvalid       => 'Enter a valid phone number';
  @override String get amountRequired     => 'Amount is required';
  @override String get amountInvalid      => 'Enter a valid amount';
  @override String get amountMustBeGreater => 'Amount must be greater than 0';
  @override String get fieldRequired      => 'This field is required';
}

// ─────────────────────────────────────────
//  IKINYARWANDA
// ─────────────────────────────────────────
class RwStrings extends AppStrings {
  @override String get appTagline         => 'Gurtanga Hamwe, Byoroshye';
  @override String get onboardingTitle2   => 'Bika Hamwe,\nGanuka Hamwe';
  @override String get onboardingSubtitle2 =>
      'Fungura cyangwa winjire mu itsinda\nry\'inshuti, umuryango cyangwa inshuti z\'akazi.\nBuri wese atanga, buri wese yunguka.';
  @override String get onboardingTitle3   => 'Kurikira Amafaranga &\nKuvanaho Igihe Cyo';
  @override String get onboardingSubtitle3 =>
      'Kurikira itsinda ryawe mu gihe nyacyo.\nSaba guvanaho amafaranga\nigihe cyose witeguye.';
  @override String get getStarted         => 'Tangira';
  @override String get alreadyHaveAccount => 'Nsanzwe mfite konti';
  @override String get skip               => 'Simbuka';
  @override String get secure             => 'UMUTEKANO';

  @override String get chooseLanguage        => 'Hitamo ururimi rwawe';
  @override String get chooseLanguageSubtitle =>
      'Hitamo ururimi ukunda gukomeza\ngukoresha porogaramu.';
  @override String get savePreference => 'Bika Amahitamo';
  @override String get language       => 'Ururimi';

  @override String get signIn          => 'Injira';
  @override String get signUp          => 'Iyandikishe';
  @override String get email           => 'Imeyili';
  @override String get password        => 'Ijambobanga';
  @override String get fullName        => 'Amazina Yuzuye';
  @override String get forgotPassword  => 'Wibagiwe Ijambobanga?';
  @override String get noAccount       => 'Nta konti ufite? Iyandikishe';
  @override String get haveAccount     => 'Usanzwe ufite konti? Injira';
  @override String get loginFailed     => 'Kwinjira ntibyakunze. Ongera ugerageze.';
  @override String get welcomeBack     => 'Murakaza neza';
  @override String get loginSubtitle   => 'Injira mu konti yawe ya Ikimina';
  @override String get phoneNumber     => 'Nimero ya Telefoni';
  @override String get enterPassword   => 'Injiza ijambobanga ryawe';
  @override String get logIn           => 'Injira';
  @override String get orDivider       => 'CYANGWA';
  @override String get createYourAccount => 'Fungura konti yawe';
  @override String get registerSubtitle  => 'Injira muri Ikimina utangire gurbika';
  @override String get enterFullName   => 'Injiza amazina yawe yuzuye';
  @override String get enterEmail      => 'Injiza imeyili yawe';
  @override String get createPassword  => 'Hanga ijambobanga';
  @override String get confirmPassword => 'Emeza Ijambobanga';
  @override String get repeatPassword  => 'Subiramo ijambobanga';
  @override String get createAccount   => 'Fungura Konti';
  @override String get iAgreeTo        => 'Nemera ';
  @override String get termsOfService  => 'Amategeko y\'Imikorere';
  @override String get and             => ' na ';
  @override String get privacyPolicy   => 'Politiki y\'Ibanga';
  @override String get fillAllFields    => 'Uzuza ibibanza byose';
  @override String get passwordsNoMatch => 'Amajambobanga ntahura';
  @override String get acceptTerms      => 'Emera amategeko gukomeza';
  @override String get noAccountPrefix       => 'Nta konti ufite?  ';
  @override String get haveAccountPrefix     => 'Usanzwe ufite konti?  ';
  @override String get forgotPasswordTitle   => 'Wibagiwe Ijambobanga?';
  @override String get forgotPasswordSubtitle => 'Nta kibazo! Injiza imeyili yawe tukohereze link yo guhindura.';
  @override String get emailLabel            => 'Imeyili';
  @override String get emailHint             => 'Injiza aderesi ya imeyili yawe';
  @override String get sendResetLink         => 'Ohereza Link yo Guhindura';
  @override String get backToLogin           => 'Garuka Kwinjira';
  @override String get checkInbox            => 'Reba imeyili zawe';
  @override String get checkInboxSubtitle    => 'Twohereje link yo guhindura ijambobanga kuri';
  @override String get didntReceive          => 'Ntibyakugezeho? Reba muri spam yawe.';
  @override String get enterEmailFirst       => 'Injiza aderesi ya imeyili yawe';
  @override String get failedToSend          => 'Ntibishoboye kohereza link';

  @override String get otpTitle       => 'Emeza imeyili yawe';
  @override String get otpSubtitle    => 'Twohereje kode y\'imibare 6 kuri';
  @override String get otpExpiry      => 'Kode irangira mu minota 15';
  @override String get otpVerify      => 'Emeza Imeyili';
  @override String get otpResend      => 'Ohereza Kode Nanone';
  @override String get otpResendIn    => 'Ohereza nanone mu';
  @override String get otpSeconds     => 'amasegonda';
  @override String get otpInvalid     => 'Kode si yo cyangwa yarangiye. Ongera ugerageze.';
  @override String get otpEnterAll    => 'Injiza imibare yose 6';
  @override String get otpSending     => 'Kohereza kode...';

  @override String get verifyEmailTitle       => 'Emeza imeyili yawe';
  @override String get verifyEmailSubtitle    => 'Twohereje link yo kwemeza kuri imeyili yawe. Reba inbox yawe ukanagira kuri link yo gufungura konti.';
  @override String get verifyEmailSentTo      => 'Yoherejwe kuri';
  @override String get openEmailApp           => 'Fungura Porogaramu ya Imeyili';
  @override String get resendEmail            => 'Ohereza Imeyili Nanone';
  @override String get iHaveVerified          => 'Nasenze imeyili yanjye';
  @override String get emailNotVerifiedYet    => 'Imeyili ntiyemejwe. Reba inbox yawe.';
  @override String get verificationEmailResent => 'Imeyili y\'kwemeza yoherejwe nanone!';
  @override String get emailVerifiedSuccess   => 'Imeyili yemejwe! Murakaza neza muri Ikimina.';

  @override String get home          => 'Ahabanza';
  @override String get groups        => 'Amatsinda';
  @override String get contributions => 'Inkunga';
  @override String get transactions  => 'Ibikorwa';
  @override String get profile       => 'Umwirondoro';

  @override String get createGroup  => 'Fungura Itsinda';
  @override String get joinGroup    => 'Injira mu Itsinda';
  @override String get myGroups     => 'Amatsinda Yanjye';
  @override String get groupName    => 'Izina ry\'Itsinda';
  @override String get members      => 'Abanyamuryango';
  @override String get totalSaved   => 'Yose Yabitswe';
  
  // Group Creation
  @override String get createGroupTitle    => 'Fungura Itsinda';
  @override String get createGroupSubtitle => 'Shyiramo amakuru n\'itsinda ryawe.';
  @override String get groupInviteCode     => 'Kode yo Gutabara Itsinda';
  @override String get shareCodeWithMembers => 'Gabana kode iyi hamwe n\'abanyamuryango kugirango binjire mu itsinda.';
  @override String get groupNameLabel  => 'Izina ry\'Itsinda *';
  @override String get groupNameHint   => 'Urugero: Ubumwe Bika';
  @override String get descriptionLabel => 'Incamake';
  @override String get descriptionHint  => 'Itsinda ryino ni ibihe?';
  @override String get contributionAmountLabel => 'Igiciro cy\'Inkunga (RWF) *';
  @override String get frequencyLabel => 'Inzira';
  @override String get createGroupButton => 'Fungura Itsinda';
  @override String get fillAllRequiredFields => 'Uzuza ibibanza byaku byose.';
  @override String get invalidContributionAmount => 'Injiza igiciro kigize.';
  @override String get failedToCreateGroup => 'Ntibishoboye kufungura itsinda. Ongera ugerageze.';
  @override String get codeCopiedMessage => 'Kode yo gutabara yonekoswe!';
  
  // Group Join
  @override String get joinGroupTitle => 'Injira mu Itsinda';
  @override String get joinGroupSubtitle => 'Injiza kode y\'imibare 6\nygabaniwe n\'umugerereza w\'itsinda.';
  @override String get inviteCodeLabel => 'Kode yo Gutabara';
  @override String get inviteCodeHint => 'ABC123';
  @override String get joinGroupButton => 'Injira mu Itsinda';
  @override String get invalidInviteCode => 'Injiza kode gijuje mibare 6.';
  @override String get groupNotFound => 'Itsinda ntashoboye gushaka. Reba kode ukanagera ugerageze.';
  
  // Group Setup
  @override String get setupGroupOrJoin => 'Fungura itsinda rishya cyangwa\ninjira mu itsinda rishaje hamwe n\'kode.';
  @override String get createNewGroup => 'Fungura Itsinda';
  @override String get createNewGroupDesc => 'Tangira itsinda rishya ry\'inkunga.\nUzaba umugerereza w\'itsinda.';
  @override String get joinExistingGroup => 'Injira mu Itsinda';
  @override String get joinExistingGroupDesc => 'Injiza kode yakuweho\nna mugerereza w\'itsinda.';
  
  // Group Invite
  @override String get inviteMemberTitle => 'Tabara Umwanyamuryango';
  @override String get memberEmailLabel => 'Imeyili y\'Umwanyamuryango';
  @override String get memberEmailHint => 'umwanyamuryango@example.com';
  @override String get sendInviteText => 'Umwanyamuryango azakirikira imeyili ifite kode n\'amakuru yo kwinjira mu itsinda.';
  @override String get inviteSentMessage => 'Gutabara kwacyaherejwe kuri';
  @override String get failedToSendInvite => 'Ntibishoboye kohereza gutabara. Ongera ugerageze.';
  @override String get validEmailRequired => 'Injiza aderesi ya imeyili igize.';

  @override String get addContribution => 'Ongeraho Inkunga';
  @override String get amount          => 'Amafaranga';
  @override String get date            => 'Itariki';
  @override String get status          => 'Imiterere';
  @override String get paid            => 'Yishyuwe';
  @override String get pending         => 'Bitegereje';

  @override String get save    => 'Bika';
  @override String get cancel  => 'Hagarika';
  @override String get confirm => 'Emeza';
  @override String get loading => 'Gutegereza...';
  @override String get error   => 'Ikosa';
  @override String get success => 'Byakunze';
  @override String get back    => 'Subira Inyuma';
  
  // Profile/Settings
  @override String get phone      => 'Terefoni';
  @override String get signOut    => 'Gusohoka';
  
  // Common UI
  @override String get noGroupsYet              => 'Nta matsinda kugeza ubu';
  @override String get createOrJoinGroup       => 'Fungura cyangwa injira mu itsinda';
  @override String get myGroupsTitle           => 'Amatsinda Yanjye';
  @override String get failedToLoadContributions => 'Ntibishoboye gutegura inkunga.';
  @override String get noContributionsYet      => 'Nta nkunga kugeza ubu.';
  @override String get failedToLoadTransactions => 'Ntibishoboye gutegura ibikorwa.';
  @override String get noTransactionsYet       => 'Nta bikorwa kugeza ubu.';
  @override String get totalSavings            => 'Yose Yabitswe';
  @override String get loadingGroup            => 'Gutegura itsinda...';
  @override String get appTitle                => 'Ikibina';
  @override String get groupDetail             => 'Itsinda Riburuni';
  @override String get failedToAddContribution => 'Ntibishoboye kongeraho inkunga';
  @override String get ikibina                 => 'Ikibina';
  
  // Dashboard/Home
  @override String get hello                => 'Habari';
  @override String get groupAdmin           => 'Umugerereza w\'Itsinda';
  @override String get groupMember          => 'Umwanyamuryango w\'Itsinda';
  @override String get groupOverview        => 'UMUSARURO W\'ITSINDA';
  @override String get yourGroup            => 'ITSINDA RYAWE';
  @override String get quickActions         => 'Ibikorwa Byihuse';
  @override String get inviteMember         => 'Tabara Umwanyamuryango';
  @override String get myContributions      => 'Inkunga Zanjye';
  @override String get groupMembers         => 'Abanyamuryango b\'Itsinda';
  @override String get myProfile            => 'Umwirondoro Wanjye';
  @override String get nextContribution     => 'Inkunga Iragezako';
  @override String get groupTotal           => 'Itsinda Ryose';
  @override String get perCycle             => 'buri sezerano';
  
  // Form Validation Messages
  @override String get emailRequired       => 'Imeyili irakenewe';
  @override String get emailInvalid       => 'Injiza aderesi ya imeyili igize';
  @override String get passwordRequired   => 'Ijambobanga rirakenewe';
  @override String get passwordTooShort   => 'Ijambobanga rigomba kuba ubunini bwa mibare 6';
  @override String get phoneRequired      => 'Terefoni irakenewe';
  @override String get phoneInvalid       => 'Injiza nombe ya terefoni igize';
  @override String get amountRequired     => 'Amafaranga arakenewe';
  @override String get amountInvalid      => 'Injiza amafaranga agize';
  @override String get amountMustBeGreater => 'Amafaranga agomba kuba menshi kuruta 0';
  @override String get fieldRequired      => 'Ibyo bipamba bikenewe';
}
