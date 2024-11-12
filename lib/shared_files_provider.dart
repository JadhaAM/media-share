import 'package:flutter/material.dart';

class SharedFilesProvider with ChangeNotifier {
  List<String> _sharedFiles = [];

  List<String> get sharedFiles => _sharedFiles;

 void addSharedFile(String filePath) {
    if (!_sharedFiles.contains(filePath)) {  // Check for duplicates
      _sharedFiles.add(filePath);
      notifyListeners();
    }
  }

  void clearFiles() {
    _sharedFiles.clear();
    notifyListeners();
  }
}
