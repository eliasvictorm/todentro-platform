import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api';
    return 'http://10.0.2.2:8080/api';
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> saveSession(String token, String name, String email, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
    await prefs.setInt('userId', userId);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<Map<String, String>> get _authHeaders async {
    final token = await getToken();
    return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  String _extractError(String body) {
    try {
      final j = jsonDecode(body);
      return j['error'] ?? j['message'] ?? body;
    } catch (_) {
      return body;
    }
  }

  Future<T> _get<T>(String path, T Function(dynamic) parse) async {
    final res = await http.get(Uri.parse('$baseUrl$path'), headers: await _authHeaders);
    if (res.statusCode == 200) return parse(jsonDecode(utf8.decode(res.bodyBytes)));
    throw Exception('Erro ao buscar dados ($path): ${res.statusCode}');
  }

  Future<T> _post<T>(String path, Map<String, dynamic> body, T Function(dynamic) parse,
      {bool auth = true}) async {
    final headers = auth ? await _authHeaders : {'Content-Type': 'application/json'};
    final res = await http.post(Uri.parse('$baseUrl$path'),
        headers: headers, body: jsonEncode(body));
    if (res.statusCode == 200) return parse(jsonDecode(utf8.decode(res.bodyBytes)));
    throw Exception(_extractError(utf8.decode(res.bodyBytes)));
  }

  Future<T> _put<T>(String path, Map<String, dynamic> body, T Function(dynamic) parse) async {
    final res = await http.put(Uri.parse('$baseUrl$path'),
        headers: await _authHeaders, body: jsonEncode(body));
    if (res.statusCode == 200) return parse(jsonDecode(utf8.decode(res.bodyBytes)));
    throw Exception(_extractError(utf8.decode(res.bodyBytes)));
  }

  Future<void> _delete(String path) async {
    final res = await http.delete(Uri.parse('$baseUrl$path'), headers: await _authHeaders);
    if (res.statusCode != 200) throw Exception('Erro ao deletar ($path)');
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) =>
      _post('/auth/login', {'email': email, 'password': password},
          (j) => j as Map<String, dynamic>, auth: false);

  Future<Map<String, dynamic>> register(String name, String email, String password) =>
      _post('/auth/register', {'name': name, 'email': email, 'password': password},
          (j) => j as Map<String, dynamic>, auth: false);

  // ── Users ─────────────────────────────────────────────────────────────────

  Future<AppUser> getMe() => _get('/users/me', (j) => AppUser.fromJson(j));

  Future<AppUser> updateProfile(String name, {String? avatarUrl}) =>
      _put('/users/me', {'name': name, 'avatarUrl': avatarUrl}, (j) => AppUser.fromJson(j));

  Future<List<AppUser>> searchUsers(String query) =>
      _get('/users/search?email=${Uri.encodeComponent(query)}',
          (j) => (j as List).map((u) => AppUser.fromJson(u)).toList());

  // ── Events ────────────────────────────────────────────────────────────────

  Future<List<Event>> getEvents({String? query, String? category}) async {
    final params = <String, String>{};
    if (query != null && query.isNotEmpty) params['query'] = query;
    if (category != null && category != 'Todas') params['category'] = category;
    final uri = Uri.parse('$baseUrl/events').replace(queryParameters: params);
    final res = await http.get(uri, headers: await _authHeaders);
    if (res.statusCode == 200) {
      return (jsonDecode(utf8.decode(res.bodyBytes)) as List)
          .map((e) => Event.fromJson(e))
          .toList();
    }
    throw Exception('Erro ao carregar eventos');
  }

  Future<Event> createEvent(Event event) =>
      _post('/events', event.toJson(), (j) => Event.fromJson(j));

  Future<Event> updateEvent(int id, Event event) =>
      _put('/events/$id', event.toJson(), (j) => Event.fromJson(j));

  Future<void> deleteEvent(int id) => _delete('/events/$id');

  Future<Map<String, dynamic>> generateInviteLink(int eventId) =>
      _post('/events/$eventId/generate-link', {}, (j) => j as Map<String, dynamic>);

  Future<Event> getEventByToken(String token) =>
      _get('/events/invite/$token', (j) => Event.fromJson(j));

  Future<Participant> joinViaLink(String token, String name, String email, {String? phone}) =>
      _post('/events/invite/$token/join', {'name': name, 'email': email, 'phone': phone},
          (j) => Participant.fromJson(j), auth: false);

  // ── Participants ──────────────────────────────────────────────────────────

  Future<List<Participant>> getParticipants(int eventId) =>
      _get('/events/$eventId/participants',
          (j) => (j as List).map((p) => Participant.fromJson(p)).toList());

  Future<Participant> addParticipant(int eventId, Participant p) =>
      _post('/events/$eventId/participants', p.toJson(), (j) => Participant.fromJson(j));

  Future<void> removeParticipant(int eventId, int participantId) =>
      _delete('/events/$eventId/participants/$participantId');

  Future<void> togglePaid(int eventId, int participantId, bool paid) =>
      _put('/events/$eventId/participants/$participantId/paid', {'paid': paid}, (_) {});

  // ── Invites ───────────────────────────────────────────────────────────────

  Future<List<Invite>> getMyInvites() =>
      _get('/invites/me', (j) => (j as List).map((i) => Invite.fromJson(i)).toList());

  Future<void> sendInviteByUserId(int eventId, int userId) =>
      _post('/invites/send', {'eventId': eventId, 'inviteeId': userId}, (_) {});

  Future<void> sendInviteByEmail(int eventId, String email) =>
      _post('/invites/send', {'eventId': eventId, 'email': email}, (_) {});

  Future<Invite> respondInvite(int inviteId, bool accept) =>
      _put('/invites/$inviteId/respond',
          {'response': accept ? 'ACCEPTED' : 'DECLINED'}, (j) => Invite.fromJson(j));

  Future<void> deleteInvite(int inviteId) => _delete('/invites/$inviteId');
}
