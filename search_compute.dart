import 'dart:math';
import 'package:compute/compute.dart';

import 'package:flutter/material.dart';

List<Map<String, dynamic>> list = []; // computedData
List<Map<String, dynamic>> filteredList = [];
TextEditingController inputController = TextEditingController();
bool searching = false;

void main() async {
  inputController.addListener(searchFromCompute);
  await emulateTextInput();
  inputController.removeListener(searchFromCompute);
}

Future<void> searchFromCompute() async {
  searching = true;
  final input = inputController.text;
  if (input.isNotEmpty && list.isNotEmpty) {
    await compute(() {
      filteredList.clear();
      filteredList.addAll(list.where((Map<String, dynamic> map) {
        return map.values.where((e) => e.value.contains(input)).isNotEmpty;
      }).toList());
    } as ComputeCallback<void, dynamic>, null);
  }
  searching = false;
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