import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;

  bool isLoading = false;
  String? errorMessage;

  // =========================
  // LOGIN
  // =========================
  Future<bool> login({required String email, required String password}) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await supabase.auth.signInWithPassword(email: email, password: password);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // =========================
  // REGISTER (MULTIPLE STUDENTS)
  // =========================
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await supabase.auth.signUp(email: email, password: password);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  // =========================
  // GET CURRENT USER
  // =========================
  User? get currentUser => supabase.auth.currentUser;
}
