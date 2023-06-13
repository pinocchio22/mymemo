import 'dart:convert';

import 'package:flutter/material.dart';

import 'main.dart';

// Memo 데이터의 형식을 정해줍니다. 추후 isPinned, updatedAt 등의 정보도 저장할 수 있습니다.
class Memo {
  Memo({required this.content, this.isChecked = false});

  String content;
  bool isChecked;

  Map toJson() {
    return {'content': content, 'isChecked': isChecked};
  }

  factory Memo.fromJson(json) {
    return Memo(content: json['content'], isChecked: json['isChecked']);
  }
}

// Memo 데이터는 모두 여기서 관리
class MemoService extends ChangeNotifier {
  MemoService() {
    loadMemoList();
  }

  List<Memo> memoList = [
    Memo(content: '장보기 목록: 사과, 양파', isChecked: false), // 더미(dummy) 데이터
    Memo(content: '새 메모', isChecked: false), // 더미(dummy) 데이터
  ];

  createMemo({required String content}) {
    Memo memo = Memo(content: content);
    memoList.add(memo);
    notifyListeners(); // Consumer<MemoService>의 builder 부분을 호출해서 화면 새로고침
    saveMemoList();
  }

  updateMemo({required int index, required String content}) {
    Memo memo = memoList[index];
    memo.content = content;
    notifyListeners();
    saveMemoList();
  }

  deleteMemo({required int index}) {
    memoList.removeAt(index);
    notifyListeners();
    saveMemoList();
  }

  saveMemoList() {
    List memoJsonList = memoList.map((memo) => memo.toJson()).toList();
    // [{"content": "1"}, {"content": "2"}]

    String jsonString = jsonEncode(memoJsonList);
    // '[{"content": "1"}, {"content": "2"}]'

    prefs.setString('memoList', jsonString);
  }

  loadMemoList() {
    String? jsonString = prefs.getString('memoList');
    // '[{"content": "1"}, {"content": "2"}]'

    if (jsonString == null) return; // null 이면 로드하지 않음

    List memoJsonList = jsonDecode(jsonString);
    // [{"content": "1"}, {"content": "2"}]

    memoList = memoJsonList.map((json) => Memo.fromJson(json)).toList();
  }

  checkedMemo({required int index, required bool isChecked}) {
    Memo memo = memoList[index];
    if (memo.isChecked) {
      memo.isChecked = false;
    } else {
      memo.isChecked = true;
    }
    memoList.sort((a, b) {
      if (b.isChecked) {
        return 1;
      }
      return -1;
    });
    notifyListeners();
    saveMemoList();
  }
}
