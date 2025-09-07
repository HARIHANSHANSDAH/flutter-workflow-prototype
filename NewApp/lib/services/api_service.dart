import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  final String baseUrl = 'http://localhost:3000';

  Future<User> login(String username) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username}),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return User(
        id: json['id'],
        username: json['username'],
        role: json['role'] == 'End User' ? UserRole.EndUser : UserRole.Receiver,
      );
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<List<Request>> getRequests({required UserRole role, required int userId}) async {
    final response = await http.get(Uri.parse('$baseUrl/requests?role=${role.name}&userId=$userId'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Request.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch requests');
    }
  }

  Future<Request> createRequest(int userId, List<String> itemNames) async {
    final response = await http.post(
      Uri.parse('$baseUrl/requests'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'items': itemNames}),
    );
    if (response.statusCode == 201) {
      return Request.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create request');
    }
  }

  Future<Request> updateRequest(int requestId, List<Map<String, dynamic>> confirmations) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/requests/$requestId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'confirmations': confirmations}),
    );
    if (response.statusCode == 200) {
      return Request.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update request');
    }
  }
}
