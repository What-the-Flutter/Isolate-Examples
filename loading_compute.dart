import 'dart:async';
import 'dart:convert';
import 'package:compute/compute.dart';
import 'package:http/http.dart' as http;

void main() async {
  await loadDataFromCompute();
}

Future<void> loadDataFromCompute() async {
  List<Map<String, dynamic>> result = [];
  for (int i = 0; i < 10; i++) {
    result.add(await compute(fetchData, 5));
  }

  // alternative way
  result = await compute((int count) async {
    List<Map<String, dynamic>> list = [];
    for (int i = 0; i < 10; i++) {
      list.add(await fetchData(count));
    }
    return list;
  }, 5,);
}

Future<Map<String, dynamic>> fetchData(int requestCount) async {
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