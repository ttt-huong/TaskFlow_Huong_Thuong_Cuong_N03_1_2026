import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class GroupMember {
  const GroupMember({required this.fullName, required this.studentId});

  final String fullName;
  final String studentId;
}

const appTitle = 'Ứng dụng sinh tồn trong Rừng';

const groupMembers = <GroupMember>[
  GroupMember(fullName: 'Tran Thi Thu Huong', studentId: '23010344'),
  GroupMember(fullName: 'Nguyen Thi Thuong', studentId: '23010308'),
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thành viên nhóm',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: groupMembers.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final member = groupMembers[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(member.fullName),
                      subtitle: Text('MSSV: ${member.studentId}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
