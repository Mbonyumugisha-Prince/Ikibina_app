import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/groups/groups_screen.dart';
import '../screens/groups/group_detail_screen.dart';
import '../screens/groups/create_group_screen.dart';
import '../screens/contributions/add_contribution_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/kyc_verification_screen.dart';
import '../screens/profile/notification_settings_screen.dart';
import '../screens/profile/payment_methods_screen.dart';
import '../screens/profile/security_2fa_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/';
  static const String groups = '/groups';
  static const String groupDetail = '/groups/:id';
  static const String createGroup = '/groups/create';
  static const String contributions = '/contributions';
  static const String addContribution = '/contributions/add';
  static const String transactions = '/transactions';
  static const String profile = '/profile';
  static const String kyc = '/kyc';
  static const String security2fa = '/security-2fa';
  static const String paymentMethods = '/payment-methods';
  static const String notifications = '/notifications';

  static final router = GoRouter(
    initialLocation: home,
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isLoggedIn = authProvider.isAuthenticated;
      final isAuthRoute = state.matchedLocation == login ||
          state.matchedLocation == register ||
          state.matchedLocation == forgotPassword;

      if (!isLoggedIn && !isAuthRoute) return login;
      if (isLoggedIn && isAuthRoute) return home;
      return null;
    },
    routes: [
      GoRoute(path: login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: register, builder: (_, __) => const RegisterScreen()),
      GoRoute(
          path: forgotPassword,
          builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: home, builder: (_, __) => const HomeScreen()),
      GoRoute(path: groups, builder: (_, __) => const GroupsScreen()),
      GoRoute(path: createGroup, builder: (_, __) => const CreateGroupScreen()),
      GoRoute(
        path: groupDetail,
        builder: (_, state) =>
            GroupDetailScreen(groupId: state.pathParameters['id']!),
      ),
      GoRoute(
          path: addContribution,
          builder: (_, __) => const AddContributionScreen()),
      GoRoute(path: profile, builder: (_, __) => const ProfileScreen()),
      GoRoute(path: kyc, builder: (_, __) => const KycVerificationScreen()),
      GoRoute(path: security2fa, builder: (_, __) => const Security2FAScreen()),
      GoRoute(
        path: paymentMethods,
        builder: (_, __) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: notifications,
        builder: (_, __) => const NotificationSettingsScreen(),
      ),
    ],
  );
}
