/// Holds JWT + user payload after login for routes that require auth (e.g. admin APIs).
class AuthSession {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  String? token;
  Map<String, dynamic>? user;

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  bool get isAdmin {
    final r = user?['role']?.toString().toLowerCase();
    return r == 'admin';
  }

  void setSession(String? t, Map<String, dynamic>? u) {
    token = t;
    user = u != null ? Map<String, dynamic>.from(u) : null;
  }

  void clear() {
    token = null;
    user = null;
  }
}
