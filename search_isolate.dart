import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';

List<Map<String, dynamic>> list = []; // computedData
List<Map<String, dynamic>> filteredList = [];
TextEditingController inputController = TextEditingController();
bool searching = false;

void main() async {
  inputController.addListener(searchFromIsolate);
  await emulateTextInput();
  inputController.removeListener(searchFromIsolate);
}

Future<void> searchFromIsolate() async {
  searching = true;
  final ReceivePort receivePort = ReceivePort();
  final isolate = await Isolate.spawn(filterDataIsolate, receivePort.sendPort);
  await for (var response in receivePort) {
    if (response == null) {
      break;
    }
    if (response is List<Map<String, dynamic>>) {
      filteredList = response;
    }
  }
  searching = false;
}

void filterDataIsolate(SendPort sendPort) {
  final input = inputController.text;
  final filteredData = list.where((Map<String, dynamic> map) {
    return map.values.any((e) => e.toString().contains(input));
  }).toList();
  sendPort.send(filteredData);
  sendPort.send(null);
}

Future<void> emulateTextInput() async {
  List<String> words = [];
  for (int i = 0; i < list.length; i++) {
    words.addAll(list[i].values.map((e) => e.value as String).toSet().toList());
  }
  words = words.map((String word) => word.substring(0, min(word.length, 3))).toSet().take(3).toList();

  for (var word in words) {
    final List<String> letters = word.split('');
    String search = '';
    for (String letter in letters) {
      search += letter;
      await inputText(search);
    }
    while (search.isNotEmpty) {
      search = search.substring(0, search.length - 1);
      await inputText(search);
    }
  }
}

Future<void> inputText(String word) async {
  if (!searching) {
    await Future.delayed(const Duration(milliseconds: 500));
    await inputText(word);
  } else {
    inputController.value = TextEditingValue(text: word);
    await Future.delayed(const Duration(milliseconds: 500));
  }
}