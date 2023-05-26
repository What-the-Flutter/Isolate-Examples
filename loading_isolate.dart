import 'dart:convert';
import 'dart:isolate';
import 'package:http/http.dart' as http;

void main() async {
  await loadDataFromIsolate();
}

Future<void> loadDataFromIsolate() async {
  List<Map<String, dynamic>> result = [];
  final receivePort = ReceivePort();
  final isolate = await Isolate.spawn(fetchDataIsolate, receivePort.sendPort);
  await for (var response in receivePort) {
    if (response == null) {
      break; // Exit the loop on completion signal
    }
    if (response is Map<String, dynamic>) {
      result.add(response);
    }
  }
  print('Isolate execution completed');
}

void fetchDataIsolate(SendPort sendPort) async {
  for (int i = 0; i < 10; i++) {
    sendPort.send(await fetchData(requestCount: 5));
  }
  sendPort.send(null); // Signal completion
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
