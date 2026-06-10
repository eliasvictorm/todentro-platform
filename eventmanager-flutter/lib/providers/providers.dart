import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';

// ── Auth Provider ─────────────────────────────────────────────────────────────

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';
  int _userId = 0;

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  int get userId => _userId;

  Future<void> checkLogin() async {
    final token = await _api.getToken();
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString('userName') ?? '';
      _userEmail = prefs.getString('userEmail') ?? '';
      _userId = prefs.getInt('userId') ?? 0;
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    final data = await _api.login(email, password);
    await _api.saveSession(
        data['token'], data['name'], data['email'], data['userId'] ?? 0);
    _userName = data['name'];
    _userEmail = data['email'];
    _userId = data['userId'] ?? 0;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    final data = await _api.register(name, email, password);
    await _api.saveSession(
        data['token'], data['name'], data['email'], data['userId'] ?? 0);
    _userName = data['name'];
    _userEmail = data['email'];
    _userId = data['userId'] ?? 0;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> updateProfile(String name) async {
    final user = await _api.updateProfile(name);
    _userName = user.name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', user.name);
    notifyListeners();
  }

  Future<void> logout() async {
    await _api.clearSession();
    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    _userId = 0;
    notifyListeners();
  }
}

// ── Event Provider ────────────────────────────────────────────────────────────

class EventProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Event> _events = [];
  bool _loading = false;
  String? _error;

  List<Event> get events => _events;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadEvents({String? query, String? category}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _events = await _api.getEvents(query: query, category: category);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Event> createEvent(Event event) async {
    final created = await _api.createEvent(event);
    await loadEvents();
    return created;
  }

  Future<void> updateEvent(int id, Event event) async {
    await _api.updateEvent(id, event);
    await loadEvents();
  }

  Future<void> deleteEvent(int id) async {
    await _api.deleteEvent(id);
    await loadEvents();
  }
}

// ── Invite Provider ───────────────────────────────────────────────────────────

class InviteProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Invite> _invites = [];
  bool _loading = false;

  List<Invite> get invites => _invites;
  List<Invite> get pending => _invites.where((i) => i.status == 'PENDING').toList();
  bool get loading => _loading;
  int get pendingCount => pending.length;

  Future<void> loadInvites() async {
    _loading = true;
    notifyListeners();
    try {
      _invites = await _api.getMyInvites();
    } catch (_) {
      _invites = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> respond(int inviteId, bool accept) async {
    await _api.respondInvite(inviteId, accept);
    await loadInvites();
  }

  Future<void> dismiss(int inviteId) async {
    await _api.deleteInvite(inviteId);
    await loadInvites();
  }
}
