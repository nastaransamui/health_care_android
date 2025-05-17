
import 'package:flutter/material.dart';

class DataGridProvider with ChangeNotifier {
  int page = 0;
  int pageSize = 10;
  Map<String, int> paginationModel = {
    "page": 0,
    "pageSize": 10,
  };

  List<Map<String, dynamic>> sortModel = [
    {"field": "id", "sort": 'asc'}
  ];

  Map<String, Map<String, dynamic>> mongoFilterModel = {};

  void setPage(int newPage) {
    page = newPage;
    notifyListeners();
  }

  void setPageSize(int newSize) {
    pageSize = newSize;
    notifyListeners();
  }

  void setPaginationModel(int newPage, int newSize, {bool notify = true}) {
    
    paginationModel = {"page": newPage, "pageSize": newSize};
    if (notify) notifyListeners();
  }

  void setSortModel(List<Map<String, dynamic>> newSortModel) {
    sortModel = newSortModel;
    notifyListeners();
  }

  void setMongoFilterModel(Map<String, Map<String, dynamic>> newFilter) {
    mongoFilterModel = newFilter;
    notifyListeners();
  }
}
