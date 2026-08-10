import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.1.14:5000";

  static Future<List<dynamic>> getMoves(int n) async {
    final res = await http.get(
      Uri.parse("$baseUrl/hanoi/$n"),
    );

    final data = jsonDecode(res.body);

    return data["moves"]; // MUST be List of Map
  }
}