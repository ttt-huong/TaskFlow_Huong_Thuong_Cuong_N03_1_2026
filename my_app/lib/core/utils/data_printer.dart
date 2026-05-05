// ============================================================
// Câu 2: Generics Class (Tổng quát hóa) – In ra dữ liệu đầu vào
// ============================================================

import 'package:flutter/material.dart';

/// `DataPrinter<T>` là một Generics Class cho phép nhận bất kỳ
/// kiểu dữ liệu nào (int, String, double, Object...) và in ra
/// thông tin chi tiết của dữ liệu đó.
class DataPrinter<T> {
  // Biến lưu trữ dữ liệu đầu vào (kiểu tổng quát T)
  T data;

  // Constructor
  DataPrinter(this.data);

  /// Phương thức in ra dữ liệu đầu vào
  void printData() {
    debugPrint('====================================');
    debugPrint('Kiểu dữ liệu : ${data.runtimeType}');
    debugPrint('Giá trị       : $data');
    debugPrint('====================================');
  }

  /// Phương thức trả về dữ liệu
  T getData() {
    return data;
  }

  /// Phương thức cập nhật dữ liệu
  void setData(T newData) {
    data = newData;
  }
}

/// `DataListPrinter<T>` – Generics Class cho danh sách
/// Cho phép in ra danh sách bất kỳ kiểu dữ liệu nào.
class DataListPrinter<T> {
  List<T> dataList;

  DataListPrinter(this.dataList);

  /// In ra toàn bộ danh sách
  void printAllData() {
    debugPrint('======== DANH SÁCH (${T.toString()}) ========');
    debugPrint('Số lượng phần tử: ${dataList.length}');
    for (int i = 0; i < dataList.length; i++) {
      debugPrint('  [$i] ${dataList[i]}');
    }
    debugPrint('============================================');
  }

  /// Thêm phần tử vào danh sách
  void addData(T item) {
    dataList.add(item);
  }

  /// Lấy danh sách
  List<T> getAllData() {
    return dataList;
  }
}
