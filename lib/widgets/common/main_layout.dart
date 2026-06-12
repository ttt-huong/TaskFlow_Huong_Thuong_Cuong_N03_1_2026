import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../screens/notification_screen.dart';
import '../../providers/notification_provider.dart';
import '../../core/widgets/offline_banner.dart';

class MainLayout extends StatefulWidget {
  final String title;
  final Widget body;
  final bool showImage;
  final bool showSearchBar;
  final ValueChanged<String>? onSearchChanged;
  final String? searchHint;

  const MainLayout({
    super.key,
    required this.title,
    required this.body,
    this.showImage = false,
    this.showSearchBar = false,
    this.onSearchChanged,
    this.searchHint,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildBellIcon(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.secondaryText,
              size: 20,
            ),
          ),
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.unreadCount == 0) return const SizedBox.shrink();
              return Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    provider.unreadCount > 9 ? '9+' : '${provider.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: widget.showSearchBar
                      ? [
                          // ── Left Logo ──
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                              Icons.task_alt_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // ── Center Search Bar ──
                          Expanded(
                            child: Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200, width: 1),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search_rounded, color: AppColors.primary, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: (value) {
                                        widget.onSearchChanged?.call(value);
                                        setState(() {});
                                      },
                                      decoration: InputDecoration(
                                        hintText: widget.searchHint ?? 'Tìm kiếm...',
                                        hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      style: const TextStyle(fontSize: 13, color: AppColors.text),
                                    ),
                                  ),
                                  if (_searchController.text.isNotEmpty) ...[
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        widget.onSearchChanged?.call('');
                                        setState(() {});
                                      },
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: AppColors.secondaryText,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // ── Right Notification + Offline Status ──
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const OfflineBanner(),
                              if (widget.title != 'THÔNG BÁO') ...[
                                const SizedBox(width: 12),
                                _buildBellIcon(context),
                              ],
                            ],
                          ),
                        ]
                      : [
                          // ── Logo + Brand or Back Button ──
                          if (Navigator.canPop(context) && widget.title != 'TaskFlow')
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text, size: 20),
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            )
                          else
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: const Icon(
                                    Icons.task_alt_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'TaskFlow',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                    color: AppColors.text,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),

                          // ── Page Label (center) ──
                          if (widget.title != 'TaskFlow')
                            Text(
                              widget.title.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: AppColors.secondaryText,
                                letterSpacing: 1.0,
                              ),
                            ),

                          // ── Right Actions (Offline + Notification) ──
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const OfflineBanner(),
                              // ── Notification Bell ──
                              if (widget.title != 'THÔNG BÁO') ...[
                                const SizedBox(width: 12),
                                _buildBellIcon(context),
                              ],
                            ],
                          ),
                        ],
                ),
              ),
            ),
          ),
        ),
        body: widget.body,
      ),
    );
  }
}
