import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {

  final TextEditingController nameController =
      TextEditingController(
    text: "Tran Thi B",
  );

  final TextEditingController emailController =
      TextEditingController(
    text: "b@gmail.com",
  );

  final TextEditingController phoneController =
      TextEditingController(
    text: "0123456789",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,

        centerTitle: true,

        title: const Text(
          "Chỉnh sửa thông tin",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            // ===== AVATAR =====
            Stack(
              children: [

                const CircleAvatar(
                  radius: 55,

                  backgroundImage: NetworkImage(
                    'https://i.pinimg.com/736x/13/ff/77/13ff77bf458254385bc96c3fd18d3cc7.jpg',
                  ),
                ),

                Positioned(
                  bottom: 0,
                  right: 0,

                  child: Container(
                    padding: const EdgeInsets.all(8),

                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius:
                          BorderRadius.circular(30),
                    ),

                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ===== FORM =====
            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(20),

                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                  ),
                ],
              ),

              child: Column(
                children: [

                  // ===== NAME =====
                  TextField(
                    controller: nameController,

                    decoration: InputDecoration(
                      labelText: "Họ và tên",

                      prefixIcon: const Icon(
                        Icons.person,
                      ),

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== EMAIL =====
                  TextField(
                    controller: emailController,

                    decoration: InputDecoration(
                      labelText: "Email",

                      prefixIcon: const Icon(
                        Icons.email,
                      ),

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== PHONE =====
                  TextField(
                    controller: phoneController,

                    decoration: InputDecoration(
                      labelText: "Số điện thoại",

                      prefixIcon: const Icon(
                        Icons.phone,
                      ),

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ===== SAVE BUTTON =====
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.deepPurple,

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 16,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),

                onPressed: () {},

                child: const Text(
                  "Lưu thay đổi",

                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}