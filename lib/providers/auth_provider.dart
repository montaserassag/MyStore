import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, unauthenticated, user, admin }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  User?      _user;

  AuthStatus get status      => _status;
  User?      get user        => _user;
  bool       get isAdmin     => _status == AuthStatus.admin;
  bool       get isUser      => _status == AuthStatus.user;
  bool       get isLoggedIn  => _status == AuthStatus.user || _status == AuthStatus.admin;

  AuthProvider() {
    AuthService.authStateChanges.listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    _user = user;
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    final role = await AuthService.getUserRole(user.uid);
    _status = role == 'admin' ? AuthStatus.admin : AuthStatus.user;
    notifyListeners();
  }
}
