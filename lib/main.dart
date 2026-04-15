import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ================== BIẾN ==================
int idUser = 1;
String tenUser = 'Nguyen Van A';
String role = 'Manager';

int idTask = 1;
String tenTask = 'Thiet ke UI';
String trangThai = 'Doing';
String nguoiDuocGiao = 'Tran Thi B';

// ================== COLLECTIONS ==================
var user = {'idUser': 1, 'tenUser': 'Nguyen Van A', 'role': 'Manager'};

var listUser = [
  {'idUser': 1, 'tenUser': 'Nguyen Van A', 'role': 'Manager'},
  {'idUser': 2, 'tenUser': 'Tran Thi B', 'role': 'Member'},
  {'idUser': 3, 'tenUser': 'Le Van C', 'role': 'Member'},
];

var listTask = [
  {
    'idTask': 1,
    'tenTask': 'Thiet ke UI',
    'trangThai': 'Doing',
    'nguoiDuocGiao': 'Tran Thi B'
  },
  {
    'idTask': 2,
    'tenTask': 'Ket noi Firebase',
    'trangThai': 'Todo',
    'nguoiDuocGiao': 'Le Van C'
  },
  {
    'idTask': 3,
    'tenTask': 'Test app',
    'trangThai': 'Done',
    'nguoiDuocGiao': 'Tran Thi B'
  }
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý công việc'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danh sách nhân sự',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...listUser.map((u) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ID: ${u['idUser']}'),
                  Text('${u['tenUser']}'),
                  Text('${u['role']}'),
                ],
              );
            }).toList(),
            const Divider(),
            const Text(
              'Danh sách công việc',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...listTask.map((t) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${t['idTask']}'),
                  Text('Tên: ${t['tenTask']}'),
                  Text('Trạng thái: ${t['trangThai']}'),
                  Text('Người làm: ${t['nguoiDuocGiao']}'),
                  const Divider(),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
