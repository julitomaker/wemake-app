import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/demo_mode.dart';

/// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Auth state stream provider
final authStateProvider = StreamProvider<User?>((ref) {
  if (demoMode.isActive) {
    return Stream.value(null);
  }
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange.map((event) => event.session?.user);
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value;
});

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthService(client);
});

/// Auth Service class handling all authentication logic
class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  /// Current session
  Session? get currentSession => _client.auth.currentSession;

  /// Current user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.wemake.app://callback',
    );

    // This will return immediately as OAuth opens a browser
    // The actual auth state change will be captured by the stream
    return AuthResponse(session: currentSession, user: currentUser);
  }

  /// Sign in with Apple
  Future<AuthResponse> signInWithApple() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'com.wemake.app://callback',
    );

    return AuthResponse(session: currentSession, user: currentUser);
  }

  /// Sign in with email and password (for testing)
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email and password (for testing)
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Update user metadata (for onboarding completion)
  Future<UserResponse> updateUserMetadata(Map<String, dynamic> metadata) async {
    return await _client.auth.updateUser(
      UserAttributes(data: metadata),
    );
  }

  /// Mark onboarding as complete
  Future<void> completeOnboarding() async {
    await updateUserMetadata({'onboarding_done': true});
  }

  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    final user = currentUser;
    if (user == null) return false;

    // Check user metadata first
    final metadata = user.userMetadata;
    if (metadata != null && metadata['onboarding_done'] == true) {
      return true;
    }

    // Also check bio_profile table
    final profile = await getUserProfile();
    return profile?['onboarding_completed_at'] != null;
  }

  /// Get user profile data from bio_profile table
  Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('bio_profile')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    return response;
  }

  /// Create or update user profile
  Future<void> upsertUserProfile(Map<String, dynamic> profile) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await _client.from('bio_profile').upsert({
      ...profile,
      'user_id': userId,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}

/// Auth state notifier for more complex state management
class AuthStateNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    state = AsyncValue.data(_authService.currentUser);
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signInWithGoogle();
      state = AsyncValue.data(_authService.currentUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signInWithApple();
      state = AsyncValue.data(_authService.currentUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authStateNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, AsyncValue<User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(authService);
});
