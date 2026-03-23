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

  // Contributions
  String get addContribution;
  String get amount;
  String get date;
  String get status;
  String get paid;
  String get pending;

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
}
