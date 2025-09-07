import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final authProvider = StateNotifierProvider<AuthNotifier, User?>(
      (ref) => AuthNotifier(ref),
);

class AuthNotifier extends StateNotifier<User?> {
  final Ref _ref;
  AuthNotifier(this._ref) : super(null);

  Future<void> login(String username) async {
    try {
      final user = await _ref.read(apiServiceProvider).login(username);
      state = user;
    } catch (e) {
      rethrow;
    }
  }

  void logout() {
    state = null;
  }
}

final requestsProvider = StateNotifierProvider<RequestsNotifier, AsyncValue<List<Request>>>(
      (ref) {
    // Watch for the user's authentication state
    final user = ref.watch(authProvider);
    return RequestsNotifier(ref, user);
  },
);

class RequestsNotifier extends StateNotifier<AsyncValue<List<Request>>> {
  final Ref _ref;
  final User? _user;
  Timer? _timer;

  RequestsNotifier(this._ref, this._user) : super(const AsyncValue.loading()) {
    if (_user != null) {
      _startPolling();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  void _startPolling() {
    _fetchRequests();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchRequests();
    });
  }

  Future<void> _fetchRequests() async {
    if (_user == null) {
      state = const AsyncValue.data([]);
      return;
    }
    try {
      final requests = await _ref.read(apiServiceProvider).getRequests(
        role: _user.role,
        userId: _user.id,
      );
      state = AsyncValue.data(requests);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
