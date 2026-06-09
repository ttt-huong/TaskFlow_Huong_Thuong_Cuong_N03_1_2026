# TaskFlow - Screen Architecture & Navigation Specification 📱

## 1. Overview

Tài liệu này mô tả kiến trúc màn hình (Screen Architecture), điều hướng (Navigation Flow), phân quyền (Role-Based Access), cấu trúc Tabs và logic điều hướng của hệ thống TaskFlow.

Mục tiêu:
- Chuẩn hóa kiến trúc UI/UX phù hợp với bài tập lớn (đơn giản, demo đẹp, tránh over-engineering).
- Đồng bộ navigation giữa Manager và Member.
- Làm tài liệu tham chiếu trước khi implement các tính năng nâng cao.
- Hạn chế conflict cấu trúc thư mục và file trong quá trình phát triển.

---

# 2. Calendar Strategy (Locked)

## Recommended Flow: **Flow B (Embedded View Layer)** ✅

### Quyết định
**KHÔNG tạo Calendar như một tab riêng ở Bottom Navigation.** 

Thay vào đó:
**Calendar sẽ là một Tab con (View Layer) nằm ngay trong `ProjectTaskScreen`** để giữ ứng dụng gọn gàng, tập trung vào luồng dự án.

### Cấu trúc Project Task Screen
```text
ProjectTaskScreen (Chứa TabBar chuyển đổi)
├── [Tasks Tab]      ← Danh sách nhiệm vụ (List View - Mặc định)
└── [Calendar Tab]   ← Lịch biểu nhiệm vụ (Calendar View - Lọc trực tiếp từ TaskProvider)
```

### Luồng Điều hướng
```text
ProjectListScreen (Danh sách dự án)
    ↓
ProjectTaskScreen (Chi tiết công việc dự án)
    ├── Tasks Tab (Mặc định)
    └── Calendar Tab
            ↓
       TaskDetail (Xem chi tiết)
            ↓
       EditTask (Modal/Bottom Sheet - Manager chỉ định)
```

---

# 3. Authentication Screens (Shared)

TaskFlow có 3 màn hình xác thực dùng chung cho cả hai vai trò:

| Screen | File | Access | Description |
|--------|------|---------|-------------|
| Splash | splash_screen.dart | All | Hiển thị logo + hiệu ứng tải (2–3s) |
| Login | login_screen.dart | All | Đăng nhập bằng Email/Password |
| Register | register_screen.dart | Guest | Đăng ký tài khoản mới + lựa chọn vai trò |

---

# 4. Manager Mode Screens

Manager có quyền quản lý dự án, phân công và kiểm duyệt công việc của toàn bộ thành viên.

## Tổng số màn hình: 13 (gồm 10 màn hình tác vụ + 3 màn hình Auth dùng chung)

| # | Screen | File | Access | Navigation Trigger | Description |
|---|---------|------|----------|--------------------|-------------|
| 1 | ManagerHome | home_screen.dart | Manager | Bottom Tab 0 | Dashboard tổng quan dự án |
| 2 | ProjectList | project_list_screen.dart | Manager | Bottom Tab 1 | Danh sách tất cả dự án |
| 3 | AddProject | add_project_screen.dart | Manager | Bottom Sheet Modal | Thêm dự án mới |
| 4 | ProjectTaskScreen | project_task_screen.dart | Manager | Nhấn vào Project | Chi tiết công việc dự án |
| 5 | CreateTask | main_screen.dart (sheet) | Manager | Nút FAB (+) | Tạo nhanh công việc mới |
| 6 | EditTask | project_task_screen.dart (sheet) | Manager | Nhấn icon Sửa | Sửa thông tin công việc |
| 7 | TaskDetail | task_detail_screen.dart | Manager | Nhấn vào Task Card | Xem chi tiết công việc |
| 8 | AddMember | project_task_screen.dart (sheet) | Manager | Nhấn nút Thêm TV | Thêm thành viên vào dự án |
| 9 | UserList | user_list_screen.dart | Manager | Bottom Tab 2 | Quản lý danh sách thành viên |
| 10 | Profile | profile_screen.dart | Manager | Bottom Tab 3 | Xem hồ sơ cá nhân & Đăng xuất |

---

# 5. Member Mode Screens

Member chỉ có quyền thao tác, theo dõi và cập nhật trạng thái trên các công việc được giao cho chính họ.

## Tổng số màn hình: 8 (gồm 5 màn hình tác vụ + 3 màn hình Auth dùng chung)

| # | Screen | File | Access | Navigation Trigger | Description |
|---|---------|------|----------|--------------------|-------------|
| 1 | MemberHome | home_screen.dart | Member | Bottom Tab 0 | Dashboard cá nhân & Thống kê |
| 2 | ProjectList | project_list_screen.dart | Member | Bottom Tab 1 | Danh sách các dự án tham gia |
| 3 | ProjectTaskScreen | project_task_screen.dart | Member | Nhấn vào Project | Chi tiết công việc được giao |
| 4 | TaskDetail | task_detail_screen.dart | Member | Nhấn vào Task Card | Chi tiết công việc & Nộp bài |
| 5 | Profile | profile_screen.dart | Member | Bottom Tab 2 | Xem hồ sơ cá nhân & Đăng xuất |

---

# 6. Bottom Navigation & Navigation Bar Structure

## Manager Navigation (4 Tabs + FAB)
Manager có thanh Bottom Navigation 4 nút kèm nút FAB nổi ở giữa để tạo nhanh công việc.

### Cấu trúc Giao diện
```text
[Trang chủ]   [Dự án]   ( + FAB )   [Nhóm]   [Hồ sơ]
```

### Tab Mapping
| Index | Tab | Screen File | Nút FAB (+) |
|-------|-----|-------------|-------------|
| 0 | Trang chủ | home_screen.dart | ✅ Hiển thị |
| 1 | Dự án | project_list_screen.dart | ✅ Hiển thị |
| 2 | Nhóm | user_list_screen.dart | ✅ Hiển thị |
| 3 | Hồ sơ | profile_screen.dart | ✅ Hiển thị |

### Floating Action Button (FAB)
- **Vị trí**: Nằm chính giữa thanh điều hướng của Manager.
- **Hành động**: Gọi hàm hiển thị `_showCreateTaskSheet(context)` mở Bottom Sheet nhập thông tin nhanh thay vì mở màn hình mới (Tối ưu trải nghiệm liền mạch).

---

## Member Navigation (3 Tabs - Không có FAB)
Thành viên thường chỉ hiển thị 3 tab điều hướng cơ bản và hoàn toàn ẩn nút FAB để tránh lạm quyền.

### Cấu trúc Giao diện
```text
[Trang chủ]      [Dự án]      [Hồ sơ]
```

### Tab Mapping
| Index | Tab | Screen File | Nút FAB (+) |
|-------|-----|-------------|-------------|
| 0 | Trang chủ | home_screen.dart | ❌ Ẩn |
| 1 | Dự án | project_list_screen.dart | ❌ Ẩn |
| 2 | Hồ sơ | profile_screen.dart | ❌ Ẩn |

---

# 7. Navigation & Role Decision Flow

## Luồng Xác thực (Authentication Flow)
```text
Splash Màn hình
   ↓ (Kiểm tra token session)
Login Màn hình 
   ↓ (Đăng ký nếu chưa có tài khoản)
Register Màn hình
   ↓ (Tự động đăng nhập sau đăng ký)
MainScreen (Khung điều hướng tổng)
```

## Luồng Phân quyền & Tải Tab (Role Decision Flow)
```text
MainScreen (Tải thông tin người dùng từ AuthProvider)
      ↓
Đọc thông tin vai trò (currentUser.role)
      ↓
 ┌──────────────────────────────────────┐
 │                                      │
Vai trò: manager                      Vai trò: member
 ├── Tải 4 Tabs chính                   ├── Tải 3 Tabs chính
 └── Hiển thị nút FAB (+)               └── Ẩn hoàn toàn nút FAB
```

---

# 8. Cấu trúc Quản lý Trạng thái Công việc (Task State Machine)

Trạng thái công việc tuân thủ nghiêm ngặt theo luồng vòng đời khép kín để đảm bảo kiểm soát chất lượng:

```text
[todo] ──(Member nhận việc)──> [doing] ──(Member nộp bài)──> [reviewing] ──(Manager duyệt)──> [done]
  │                              │                              │
  │                              │                              └──(Manager từ chối)─> [doing]
  └────────(Manager hủy)─────────┴────────(Manager hủy)──────────> [cancelled]
                                                                     ↓
                                                                  [archived] (Khi Manager lưu trữ)
```

### Quy tắc chuyển đổi trạng thái (Transitions Rules):
1. **Quyền của Member**: Chỉ có quyền cập nhật trạng thái các task được giao cho mình theo lộ trình: `todo` ➔ `doing` ➔ `reviewing`. **Không** được phép tự chuyển về `todo` từ `doing` và **không** được duyệt lên `done`.
2. **Quyền của Manager**: Phê duyệt hoặc từ chối công việc ở trạng thái `reviewing`. Nếu phê duyệt ➔ chuyển sang `done`. Nếu từ chối (reject) ➔ chuyển ngược về `doing`. Có quyền hủy công việc (`cancelled`) bất cứ lúc nào.

---

# 9. Chi tiết Logic Hạng mục Calendar Tab & Lọc Phân quyền (Locked)

Nhằm đảm bảo sự đơn giản, tránh thiết kế thừa (over-engineering), tính năng lịch biểu (Calendar) được triển khai thuần túy dưới dạng một **lớp hiển thị (View Layer)** sử dụng tài nguyên có sẵn của `TaskProvider`:

### 1. Phân quyền lọc dữ liệu trên Lịch (Role Filtering)
Calendar Tab luôn áp dụng bộ lọc dữ liệu đồng bộ với danh sách List View để bảo vệ quyền riêng tư:
*   **Với Manager**: Xem được tất cả công việc có thuộc dự án hiện tại:
    ```dart
    final projectTasks = taskProvider.tasks.where((t) => t.projectId == widget.projectId).toList();
    ```
*   **Với Member**: Chỉ xem được các công việc thuộc dự án hiện tại mà **chính họ** được phân công:
    ```dart
    final memberProjectTasks = taskProvider.tasks.where(
      (t) => t.projectId == widget.projectId && t.assignedTo == currentUser.id
    ).toList();
    ```

### 2. Quy tắc Hiển thị và Mã màu trên Lịch
*   **Điều kiện hiển thị**: Các công việc có `deadline == null` sẽ tự động bị ẩn khỏi lịch biểu.
*   **Quy tắc mã màu (Color Coding)** đại diện trạng thái:
    - Trạng thái `done` ➔ Màu Xanh lá (`Colors.green`).
    - Bị quá hạn (`isOverdue() == true`) và chưa hoàn thành ➔ Màu Đỏ (`Colors.red`).
    - Trạng thái `todo` ➔ Màu Cam (`Colors.orange`).
    - Trạng thái `doing` ➔ Màu Vàng (`Colors.amber`).
    - Trạng thái `reviewing` ➔ Màu Xanh dương (`Colors.blue`).
*   **Hiển thị dồn ngày**: Nếu một ngày có nhiều hơn 3 công việc, hiển thị tối đa 2 thẻ nhiệm vụ và dòng chữ ghi chú `+N` (với N là số lượng công việc còn lại trong ngày).

### 3. Reset Trạng thái Tab (Tab Reset Mechanism)
*   **Mô tả**: Khi người dùng nhấn quay lại `ProjectListScreen` và mở một dự án khác, màn hình `ProjectTaskScreen` phải tự động đặt lại trạng thái tab mặc định là **Tasks Tab (Index 0)**, tránh giữ nguyên tab "Calendar" gây khó hiểu cho người dùng.
*   **Giải pháp**: Sử dụng `DefaultTabController` hoặc khởi tạo lại `TabController` trong `initState` của `ProjectTaskScreen` để reset chỉ mục về `0` mỗi lần mở màn hình mới.

---

# 10. Kế hoạch Triển khai theo Thứ tự Ưu tiên (Locked)

### 📌 PHA 1: Trải nghiệm Core & Lịch biểu (Priority 1)
1. **Triển khai Tab Calendar**: Nhúng trực tiếp Grid Lịch (sử dụng thư viện `table_calendar` hoặc Custom Grid tinh gọn) vào `ProjectTaskScreen` làm tab thứ 2.
2. **Lọc phân quyền dữ liệu**: Áp dụng nghiêm ngặt bộ lọc dữ liệu cho Calendar theo đúng vai trò người dùng (Manager xem hết, Member chỉ thấy việc của mình).
3. **Reset Tab điều hướng**: Hoàn thiện logic tự động đưa tab về mặc định (Index 0 - Tasks List) khi đổi dự án.
4. **Xử lý trạng thái rỗng/tải/lỗi**: Hiển thị ảnh minh họa rỗng (Empty state), Shimmer tải mịn hoặc thông báo lỗi thân thiện khi không có mạng.

### 📌 PHA 2: Tối ưu & Đánh bóng UX (Priority 2)
1. **Cải tiến thông báo (Notifications)**: Thêm thông báo tại chỗ khi trạng thái công việc được cập nhật hoặc thay đổi vai trò.
2. **Chỉ báo đồng bộ (Sync Indicator)**: Hiển thị icon nhỏ trên thẻ hoặc thanh trạng thái báo dữ liệu chưa được đồng bộ (isSynced = 0) hoặc đã đồng bộ (isSynced = 1).
3. **UX Polish**: Thêm hiệu ứng co giãn lò xo (spring physics) và Glassmorphism cho các thẻ nhiệm vụ để tăng tính cao cấp cho bài tập lớn.