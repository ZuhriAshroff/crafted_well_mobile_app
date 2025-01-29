// user_manager.dart
class UserManager {
  static const String defaultEmail = "user@craftedwell.com";
  static const String defaultPassword = "qaz!QAZ";

  static bool isLoggedIn = false;
  static String? currentUserName;

  static bool login(String email, String password) {
    if (email == defaultEmail && password == defaultPassword) {
      isLoggedIn = true;
      currentUserName = "Demo User";
      return true;
    }
    return false;
  }

  static void logout() {
    isLoggedIn = false;
    currentUserName = null;
  }
}
