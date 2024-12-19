import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchData() async {
  try {
    final response = await http.get(Uri.parse(
        "https://patrickjosephdev.github.io/Book_of_Saints/saints.json"
        
        ));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch saint data');
    }
  } catch (error) {
    rethrow; // Re-throw the error to be handled by the caller
  }
}