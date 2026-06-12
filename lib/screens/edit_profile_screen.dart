import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab 1 — Chỉnh sửa thông tin
  final _nameController = TextEditingController();
  final _nameFormKey = GlobalKey<FormState>();
  bool _isSavingName = false;

  // Tab 2 — Đổi mật khẩu
  final _currentPwController = TextEditingController();
  final _newPwController = TextEditingController();
  final _confirmPwController = TextEditingController();
  final _pwFormKey = GlobalKey<FormState>();
  bool _isSavingPw = false;
  bool _showCurrentPw = false;
  bool _showNewPw = false;
  bool _showConfirmPw = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final user = context.read<AuthProvider>().currentUser;
    _nameController.text = user?.name ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _currentPwController.dispose();
    _newPwController.dispose();
    _confirmPwController.dispose();
    super.dispose();
  }

  // ─── Lưu tên ──────────────────────────────────────────────
  Future<void> _saveName() async {
    if (!_nameFormKey.currentState!.validate()) return;
    setState(() => _isSavingName = true);

    final auth = context.read<AuthProvider>();
    final success = await auth.updateName(_nameController.text.trim());

    if (!mounted) return;
    setState(() => _isSavingName = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Cập nhật tên thành công!' : 'Cập nhật thất bại, vui lòng thử lại.'),
        backgroundColor: success ? AppColors.done : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    if (success) Navigator.pop(context, true);
  }

  // ─── Đổi mật khẩu ─────────────────────────────────────────
  Future<void> _changePassword() async {
    if (!_pwFormKey.currentState!.validate()) return;
    setState(() => _isSavingPw = true);

    final auth = context.read<AuthProvider>();
    final result = await auth.changePassword(
      currentPassword: _currentPwController.text,
      newPassword: _newPwController.text,
    );

    if (!mounted) return;
    setState(() => _isSavingPw = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? AppColors.done : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    if (result.success) {
      _currentPwController.clear();
      _newPwController.clear();
      _confirmPwController.clear();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final avatarChar = user?.name.isNotEmpty == true
        ? user!.name[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.text,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chỉnh sửa hồ sơ',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.secondaryText,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Thông tin'),
            Tab(text: 'Mật khẩu'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(avatarChar, user?.name ?? '', user?.email ?? '', user?.role ?? 'member'),
          _buildPasswordTab(),
        ],
      ),
    );
  }

  // ─── Tab thông tin ─────────────────────────────────────────
  Widget _buildInfoTab(String avatarChar, String name, String email, String role) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _nameFormKey,
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Avatar
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  avatarChar,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Role badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: role == 'manager'
                    ? const Color(0xFFFFF3E0)
                    : const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: role == 'manager'
                      ? Colors.orange.shade300
                      : Colors.blue.shade300,
                ),
              ),
              child: Text(
                role == 'manager' ? '👑 Quản lý' : '👤 Thành viên',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: role == 'manager'
                      ? Colors.orange.shade700
                      : Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Field: Họ tên
            _buildLabel('Họ và tên'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration(
                hint: 'Nhập họ và tên của bạn',
                icon: Icons.person_outline_rounded,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Vui lòng nhập họ tên';
                if (v.trim().length < 2) return 'Tên phải có ít nhất 2 ký tự';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Field: Email (read-only)
            _buildLabel('Email (không thể thay đổi)'),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: email,
              readOnly: true,
              decoration: _inputDecoration(
                hint: '',
                icon: Icons.email_outlined,
              ).copyWith(
                filled: true,
                fillColor: const Color(0xFFF1F3F9),
              ),
              style: const TextStyle(color: AppColors.secondaryText),
            ),
            const SizedBox(height: 36),

            // Nút lưu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: _isSavingName ? null : _saveName,
                child: _isSavingName
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Lưu thay đổi',
                        style: TextStyle(
                          fontSize: 16,
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

  // ─── Tab đổi mật khẩu ──────────────────────────────────────
  Widget _buildPasswordTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _pwFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Info card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF0FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Mật khẩu mới phải có ít nhất 6 ký tự.',
                      style: TextStyle(color: AppColors.primary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            _buildLabel('Mật khẩu hiện tại'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _currentPwController,
              obscureText: !_showCurrentPw,
              decoration: _inputDecoration(
                hint: 'Nhập mật khẩu hiện tại',
                icon: Icons.lock_outline_rounded,
              ).copyWith(
                suffixIcon: _toggleVisibilityIcon(
                  _showCurrentPw,
                  () => setState(() => _showCurrentPw = !_showCurrentPw),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu hiện tại';
                return null;
              },
            ),
            const SizedBox(height: 20),

            _buildLabel('Mật khẩu mới'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _newPwController,
              obscureText: !_showNewPw,
              decoration: _inputDecoration(
                hint: 'Nhập mật khẩu mới',
                icon: Icons.lock_reset_rounded,
              ).copyWith(
                suffixIcon: _toggleVisibilityIcon(
                  _showNewPw,
                  () => setState(() => _showNewPw = !_showNewPw),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu mới';
                if (v.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
                if (v == _currentPwController.text) return 'Mật khẩu mới phải khác mật khẩu cũ';
                return null;
              },
            ),
            const SizedBox(height: 20),

            _buildLabel('Xác nhận mật khẩu mới'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmPwController,
              obscureText: !_showConfirmPw,
              decoration: _inputDecoration(
                hint: 'Nhập lại mật khẩu mới',
                icon: Icons.check_circle_outline_rounded,
              ).copyWith(
                suffixIcon: _toggleVisibilityIcon(
                  _showConfirmPw,
                  () => setState(() => _showConfirmPw = !_showConfirmPw),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                if (v != _newPwController.text) return 'Mật khẩu xác nhận không khớp';
                return null;
              },
            ),
            const SizedBox(height: 36),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: _isSavingPw ? null : _changePassword,
                child: _isSavingPw
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Đổi mật khẩu',
                        style: TextStyle(
                          fontSize: 16,
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

  // ─── Helpers ───────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.secondaryText, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }

  Widget _toggleVisibilityIcon(bool isVisible, VoidCallback onToggle) {
    return IconButton(
      icon: Icon(
        isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.secondaryText,
        size: 20,
      ),
      onPressed: onToggle,
    );
  }
}
