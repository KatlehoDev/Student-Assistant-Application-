import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {

  // Supabase client
  final SupabaseClient supabase =
      Supabase.instance.client;

  // LOGIN
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {

    final response =
        await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return response;
  }

  // REGISTER
  Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {

    final response =
        await supabase.auth.signUp(
      email: email,
      password: password,
    );

    return response;
  }

  // LOGOUT
  Future<void> logout() async {

    await supabase.auth.signOut();
  }

  // CURRENT USER
  User? getCurrentUser() {

    return supabase.auth.currentUser;
  }

  // CHECK IF USER IS LOGGED IN
  bool isLoggedIn() {

    return supabase.auth.currentUser != null;
  }
}