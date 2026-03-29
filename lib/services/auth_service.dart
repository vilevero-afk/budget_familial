import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Utilisateur actuel
  User? get currentUser => _auth.currentUser;

  /// Stream pour écouter les changements (login/logout)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Wrapper sécurisé pour toutes les opérations Firebase
  Future<T> _execute<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    } catch (e) {
      throw 'Une erreur inattendue est survenue.';
    }
  }

  /// Inscription
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    return _execute(() {
      return _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    });
  }

  /// Connexion
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _execute(() {
      return _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    });
  }

  /// Reset password
  Future<void> sendPasswordResetEmail({
    required String email,
  }) {
    return _execute(() {
      return _auth.sendPasswordResetEmail(email: email.trim());
    });
  }

  /// Email verification
  Future<void> sendEmailVerification() {
    final user = _auth.currentUser;
    if (user == null) {
      throw 'Aucun utilisateur connecté.';
    }

    return _execute(() => user.sendEmailVerification());
  }

  /// Reload user
  Future<void> reloadCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return Future.value();

    return _execute(() => user.reload());
  }

  /// Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {
      // volontairement silencieux
    }
  }

  /// Mapping des erreurs Firebase → UX propre
  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'invalid-email':
        return 'Email invalide.';
      case 'weak-password':
        return 'Mot de passe trop faible (min 6 caractères).';
      case 'user-not-found':
        return 'Utilisateur introuvable.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'operation-not-allowed':
        return 'Opération non autorisée.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessaie plus tard.';
      case 'network-request-failed':
        return 'Problème réseau. Vérifie ta connexion internet.';
      case 'requires-recent-login':
        return 'Veuillez vous reconnecter pour continuer.';
      default:
        return 'Erreur : ${e.message ?? 'inconnue'}';
    }
  }
}
