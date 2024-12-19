import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> massData( String URL) async {
  try {
    final response = await http.get(Uri.parse(
        URL
        ));
    print(response);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch saint data');
    }
  } catch (error) {
    rethrow; // Re-throw the error to be handled by the caller
  }
}
