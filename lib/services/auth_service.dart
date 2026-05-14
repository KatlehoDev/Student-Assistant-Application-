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

  Future<void> logout() async {

    await supabase.auth.signOut();
  }

  User? getCurrentUser() {

    return supabase.auth.currentUser;
  }

  bool isLoggedIn() {

    return supabase.auth.currentUser != null;
  }
}