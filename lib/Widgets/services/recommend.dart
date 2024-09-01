import 'package:http/http.dart' as http;
import 'dart:convert';



Future<List<dynamic>> fetchRecommendations(String userId) async {
  final url = Uri.parse('http://localhost:8000/recommendations/$userId');
  try {
    final response = await http.post(url);
    
    if (response.statusCode == 200) {
      return json.decode(response.body)['recommendations'];
    } else {
      throw Exception('Failed to load recommendations');
    }
  } catch (e) {
    print(e.toString());
    rethrow;
  }
}
