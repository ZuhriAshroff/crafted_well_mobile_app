// lib/utils/user_manager.dart
import 'package:crafted_well_mobile_app/services/auth_service.dart';

class UserManager {
  // Keep original demo credentials for compatibility
  static const String defaultEmail = "user@craftedwell.com";
  static const String defaultPassword = "qaz!QAZ";

  static bool isLoggedIn = false;
  static String? currentUserName;
  static String? currentUserEmail;
  static Map<String, dynamic>? _currentUser;

  // Initialize user state on app start
  static Future<void> initialize() async {
    try {
      print('🚀 UserManager: Initializing...');

      final loggedIn = await AuthService.isLoggedIn();
      if (loggedIn) {
        _currentUser = await AuthService.getUser();
        if (_currentUser != null) {
          isLoggedIn = true;
          currentUserName = _currentUser!['name'] ?? 'User';
          currentUserEmail = _currentUser!['email'] ?? '';
          print('✅ UserManager: User restored - $currentUserEmail');
        }
      }
    } catch (e) {
      print('⚠️ UserManager: Initialization error - $e');
      await _resetUserState();
    }
  }

  // Login method using Auth Service (with demo fallback)
  static Future<bool> login(String email, String password) async {
    try {
      print('🔐 UserManager: Attempting login for $email');

      final result = await AuthService.login(email, password);

      if (result['success']) {
        // IMPORTANT: Update UserManager state immediately
        _currentUser = result['user'];
        isLoggedIn = true;
        currentUserName = _currentUser!['name'] ?? 'User';
        currentUserEmail = _currentUser!['email'] ?? email;

        print('✅ UserManager: Login successful - $currentUserEmail');
        print('✅ UserManager: State updated - isLoggedIn: $isLoggedIn');
        return true;
      } else {
        print('❌ UserManager: Login failed - ${result['message']}');
        // Ensure state is cleared on failed login
        await _resetUserState();
        return false;
      }
    } catch (e) {
      print('🚨 UserManager: Login error - $e');
      await _resetUserState();
      return false;
    }
  }

  // Original login method for backward compatibility (demo fallback)
  static bool loginLegacy(String email, String password) {
    if (email == defaultEmail && password == defaultPassword) {
      isLoggedIn = true;
      currentUserName = "Demo User";
      currentUserEmail = email;
      return true;
    }
    return false;
  }

  // Register method using Auth Service
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      print('📝 UserManager: Attempting registration for $email');

      final result = await AuthService.register(name, email, password);

      if (result['success']) {
        print('✅ UserManager: Registration successful');
      } else {
        print('❌ UserManager: Registration failed - ${result['message']}');
      }

      return result;
    } catch (e) {
      print('🚨 UserManager: Registration error - $e');
      return {
        'success': false,
        'message': 'Registration error occurred: $e',
      };
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      print('🚪 UserManager: Logging out user');
      await AuthService.logout();
      await _resetUserState();
      // Also reset survey state when logging out
      // (User might want to retake survey with different account)
      print('✅ UserManager: Logout successful');
    } catch (e) {
      print('⚠️ UserManager: Logout error - $e');
      await _resetUserState();
    }
  }

  // Reset user state
  static Future<void> _resetUserState() async {
    isLoggedIn = false;
    currentUserName = null;
    currentUserEmail = null;
    _currentUser = null;
  }

  // Getters
  static Map<String, dynamic>? get currentUser => _currentUser;
  static String get userName => currentUserName ?? 'User';
  static String get userEmail => currentUserEmail ?? '';

  // Verify session is still valid
  static Future<bool> verifySession() async {
    if (!isLoggedIn) return false;

    try {
      final isValid = await AuthService.verifyToken();
      if (!isValid) {
        print('⚠️ UserManager: Session expired, logging out');
        await logout();
        return false;
      }

      return true;
    } catch (e) {
      print('⚠️ UserManager: Session verification error - $e');
      await logout();
      return false;
    }
  }

  // Get auth token for API requests
  static Future<String?> getAuthToken() async {
    return await AuthService.getToken();
  }

  // For debugging and assignment demonstration
  static void printUserState() {
    print('👤 UserManager State:');
    print('   - Logged in: $isLoggedIn');
    print('   - Name: $currentUserName');
    print('   - Email: $currentUserEmail');
    print('   - User data: $_currentUser');
  }

  // Force refresh user state from storage
  static Future<void> forceRefresh() async {
    print('🔄 UserManager: Force refreshing state...');
    await initialize();
    printUserState();
  }

  // Show connection status for assignment demo
  static String getConnectionStatusMessage() {
    if (isLoggedIn) {
      return '🟢 Authenticated User: $currentUserName';
    } else {
      return '🔴 Not Authenticated';
    }
  }
}
