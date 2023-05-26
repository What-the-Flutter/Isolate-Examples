import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  await loadDataFromMainThread();
}

Future<void> loadDataFromMainThread() async {
  List<Map<String, dynamic>> result = [];
  for (int i = 0; i < 10; i++) {
    result.add(await fetchData(requestCount: 5));
  }
}

Future<Map<String, dynamic>> fetchData({int requestCount = 1}) async {
  final url = Uri.parse('https://api.example.com/data');
  List<Future<http.Response>> futures = [];
  for (int j = 0; j < requestCount; j++) {
    futures.add(http.get(url));
  }

  try {
    final responses = await Future.wait(futures);

    for (var response in responses) {
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData;
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('An error occurred: $e');
  }
  return {};
}