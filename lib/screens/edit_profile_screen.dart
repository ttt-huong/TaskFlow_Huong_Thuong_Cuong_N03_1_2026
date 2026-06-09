import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/common/main_layout.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController(
    text: 'Tran Thi B',
  );

  final TextEditingController emailController = TextEditingController(
    text: 'b@gmail.com',
  );

  final TextEditingController phoneController = TextEditingController(
    text: '0123456789',
  );

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'CHỈNH SỬA',
      showImage: false,
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
                      color: AppColors.primary,
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
                  _buildInputField(
                    controller: nameController,
                    label: 'Họ và tên',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    controller: emailController,
                    label: 'Email',
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    controller: phoneController,
                    label: 'Số điện thoại',
                    icon: Icons.phone,
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
                  backgroundColor: AppColors.primary,

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