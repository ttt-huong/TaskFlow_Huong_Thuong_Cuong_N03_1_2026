# TaskFlow - Ứng dụng quản lý công việc nhóm

**TaskFlow** là ứng dụng Flutter hỗ trợ quản lý dự án và phân công nhiệm vụ trong nhóm. Ứng dụng cho phép người quản lý tạo dự án, thêm thành viên, giao việc, theo dõi tiến độ và duyệt kết quả; thành viên có thể xem nhiệm vụ được giao, cập nhật trạng thái công việc, gửi việc để duyệt và theo dõi thông báo liên quan.

Dự án được xây dựng theo hướng **offline-first**: dữ liệu được lưu cục bộ bằng SQLite để người dùng vẫn có thể thao tác khi mất mạng, sau đó đồng bộ lại với Firebase Firestore khi kết nối trở lại. Luồng xử lý chính của ứng dụng tuân theo kiến trúc phân lớp:

```text
UI -> Provider -> Repository -> Service
```

---

## Thành viên nhóm

| Thành viên | Vai trò chính | Phần việc nổi bật |
| :--- | :--- | :--- |
| **Trần Thị Thu Hường - 23010344** | Trưởng nhóm / phát triển kiến trúc lõi | Thiết kế kiến trúc phân lớp, Firebase, SQLite, cơ chế offline-first sync, các màn hình chính như `MainScreen`, `HomeScreen`, `ProjectTaskScreen`, `TaskDetailScreen`, `LoginScreen`, `RegisterScreen`, `UserListScreen`, `MemberTasksScreen`. |
| **Nguyễn Việt Cường - 23010551** | Frontend Developer / UML Designer | Thiết kế sơ đồ UML, hỗ trợ giao diện danh sách dự án `ProjectListScreen`, hiển thị tiến độ hoàn thành công việc bằng `LinearProgressIndicator`. |
| **Nguyễn Thị Thương - 23010308** | UI/UX Designer / Document Specialist | Phụ trách `ProfileScreen`, `EditProfileScreen`, `NotificationScreen`, `NotificationProvider`, `ConnectivityProvider`, tài liệu hệ thống và báo cáo. |

---

## Công nghệ sử dụng

### Nền tảng & ngôn ngữ

- **Flutter**: framework chính để xây dựng giao diện ứng dụng đa nền tảng.
- **Dart**: ngôn ngữ lập trình dùng để phát triển toàn bộ logic, model, provider và màn hình.

### Backend & xác thực

- **Firebase Auth**: xử lý đăng ký, đăng nhập và xác thực tài khoản người dùng.
- **Cloud Firestore**: lưu trữ dữ liệu người dùng, dự án, công việc và thông báo trên cloud.
- **Firebase Seed Data**: tạo dữ liệu mẫu để phục vụ demo và kiểm thử nhanh.

### Lưu trữ cục bộ & đồng bộ dữ liệu

- **SQLite / sqflite**: lưu dữ liệu cục bộ để ứng dụng vẫn hoạt động khi mất mạng.
- **Offline-First Sync Engine**: đồng bộ dữ liệu giữa SQLite local và Firestore khi có mạng trở lại.
- **connectivity_plus**: theo dõi trạng thái online/offline của thiết bị.

### Quản lý trạng thái & tiện ích

- **Provider**: quản lý trạng thái ứng dụng theo các lớp `AuthProvider`, `TaskProvider`, `ProjectProvider`, `NotificationProvider`, `ConnectivityProvider`.
- **Repository Pattern**: tách tầng truy xuất dữ liệu khỏi UI, giúp code dễ mở rộng và kiểm thử.
- **Material Design 3**: định hướng giao diện hiện đại, rõ ràng và phù hợp ứng dụng quản lý công việc.
- **intl**: định dạng ngày giờ, deadline và thông tin hiển thị.
- **uuid**: tạo định danh duy nhất cho các đối tượng dữ liệu.

---

## Chức năng chính của ứng dụng

- Đăng ký, đăng nhập và phân quyền người dùng theo vai trò **Manager** / **Member**.
- Manager tạo dự án, thêm thành viên và phân công nhiệm vụ.
- Hiển thị dashboard tổng quan tiến độ công việc.
- Quản lý task theo quy trình: `todo -> doing -> reviewing -> done`.
- Duyệt hoặc từ chối nhiệm vụ đang chờ review.
- Xem chi tiết nhiệm vụ, deadline, trạng thái quá hạn và lịch sử xử lý.
- Theo dõi danh sách dự án và tiến độ hoàn thành.
- Quản lý hồ sơ cá nhân, chỉnh sửa thông tin người dùng.
- Hiển thị thông báo khi có thay đổi liên quan đến task.
- Hỗ trợ lưu dữ liệu cục bộ và đồng bộ khi có mạng trở lại.

---

## Cấu trúc thư mục chính

```text
lib/
├── app.dart                         # Cấu hình MaterialApp, theme, route và màn hình khởi đầu
├── main.dart                        # Khởi tạo Firebase, Provider và ConnectivityService
├── firebase_options.dart            # Cấu hình Firebase theo từng nền tảng
├── core/                            # Màu sắc, kiểu chữ, tiện ích và widget dùng chung
├── models/                          # Model dữ liệu: User, Project, Task, Notification
├── providers/                       # State management: Auth, Task, Project, Notification, Connectivity
├── repositories/                    # Interface và implementation truy xuất dữ liệu
├── screens/                         # Các màn hình giao diện chính của ứng dụng
├── services/                        # Firebase, SQLite, Auth, Connectivity và seed data
├── theme/                           # Cấu hình giao diện ứng dụng
└── widgets/                         # Widget dùng lại như layout, footer, task card, skeleton loader
```

---

## Hướng dẫn cài đặt và chạy dự án

### Yêu cầu môi trường

- Cài đặt **Flutter SDK** phiên bản hỗ trợ Dart `>=3.4.0 <4.0.0`.
- Cài đặt **Android Studio** hoặc **Visual Studio Code** kèm Flutter/Dart extension.
- Có thiết bị Android thật, máy ảo Android Emulator hoặc trình duyệt Chrome để chạy thử.
- Đã cấu hình Firebase nếu muốn chạy đầy đủ chức năng đăng nhập và đồng bộ dữ liệu cloud.

Kiểm tra môi trường Flutter:

```bash
flutter doctor
```

### Các bước cài đặt

1. Clone source code từ GitHub:

```bash
git clone git@github.com:ttt-huong/TaskFlow_Huong_Thuong_Cuong_N03_1_2026.git
cd TaskFlow_Huong_Thuong_Cuong_N03_1_2026
```

2. Tải các thư viện phụ thuộc:

```bash
flutter pub get
```

3. Kiểm tra thiết bị có thể chạy:

```bash
flutter devices
```

4. Chạy ứng dụng:

```bash
flutter run
```

Nếu muốn chạy trên Chrome:

```bash
flutter run -d chrome
```

Nếu muốn chạy trên Android Emulator hoặc thiết bị Android:

```bash
flutter run -d android
```

### Kiểm tra và phân tích code

Chạy kiểm thử:

```bash
flutter test
```

Phân tích lỗi code theo cấu hình lint:

```bash
flutter analyze
```

### Ghi chú khi chạy dự án

- File khởi chạy chính là `lib/main.dart`.
- Ứng dụng có thể chạy ở chế độ offline nếu Firebase chưa sẵn sàng, vì `main.dart` đã bắt lỗi khi khởi tạo Firebase.
- Dữ liệu cục bộ được lưu bằng SQLite, dữ liệu cloud được đồng bộ qua Firebase Firestore.
- Nếu gặp lỗi dependency, chạy lại:

```bash
flutter clean
flutter pub get
```

---

## Dữ liệu demo

Dữ liệu mẫu được khai báo trong `lib/services/firebase_seed_data.dart`.

| Vai trò | Email | Mật khẩu |
| :--- | :--- | :--- |
| Manager | `huong@gmail.com` | `123456` |
| Member | `huong1@gmail.com` | `123456` |
| Member | `huong2@gmail.com` | `123456` |
| Member | `huong3@gmail.com` | `123456` |

---

## Thông tin nộp bài

1. **Video Demo**

   [https://youtu.be/-YJebXdFYiM?si=P8CwD9KPAqYhHquf](https://youtu.be/-YJebXdFYiM?si=P8CwD9KPAqYhHquf)

2. **GitHub Repository**

   [git@github.com:ttt-huong/TaskFlow_Huong_Thuong_Cuong_N03_1_2026.git](mailto:git@github.com:ttt-huong/TaskFlow_Huong_Thuong_Cuong_N03_1_2026.git)

3. **Link mockup**

   [https://docs.google.com/document/d/1F2iOZ5Tm4vuI78CxHKYoMT7dFktht-rrgf66Z5FSbkA/edit?usp=sharing](https://docs.google.com/document/d/1F2iOZ5Tm4vuI78CxHKYoMT7dFktht-rrgf66Z5FSbkA/edit?usp=sharing)

---

# NHẬT KÝ CÁC BUỔI THỰC HÀNH & GIỮA KỲ

Phần này ghi lại quá trình nhóm phát triển từ các bài thực hành ban đầu đến khi hoàn thiện ứng dụng TaskFlow. Nội dung được trình bày theo từng mốc để người đọc dễ theo dõi quá trình hình thành sản phẩm.

---

## Nội dung buổi thực hành 01

### Mục tiêu thực hiện

- Tạo repository nhóm và khởi tạo project Flutter.
- Làm quen cấu trúc thư mục cơ bản của Flutter.
- Chỉnh sửa màn hình đầu tiên theo thông tin nhóm.

### Nội dung đã thực hiện

- Khởi tạo project Flutter ban đầu.
- Cập nhật giao diện chính để hiển thị tên ứng dụng và thông tin thành viên.
- Thêm tài nguyên hình ảnh nhóm trong `assets/`.
- Cập nhật `pubspec.yaml` để khai báo asset.
- Viết README đầu tiên ghi lại cách chạy dự án.

### Kết quả

Ứng dụng có thể chạy được bằng `flutter run`, hiển thị màn hình giới thiệu nhóm và tạo nền tảng cho các buổi thực hành tiếp theo.

---

## Nội dung buổi thực hành 02

### Mục tiêu thực hiện

- Làm quen với class, object và collection trong Dart.
- Hiển thị dữ liệu danh sách lên giao diện Flutter.
- Bắt đầu định hướng ứng dụng theo chủ đề quản lý công việc.

### Nội dung đã thực hiện

- Tạo dữ liệu mẫu về nhân sự gồm tên, vai trò và thông tin cơ bản.
- Tạo dữ liệu mẫu về công việc gồm tên task, trạng thái và người được giao.
- Hiển thị danh sách nhân sự và danh sách công việc trên màn hình.
- Làm quen cách render dữ liệu động từ `List` sang widget.

### Kết quả

Nhóm chuyển hướng rõ hơn sang đề tài **TaskFlow - quản lý công việc nhóm**, thay vì chỉ dừng ở màn hình giới thiệu tĩnh.

---

## Nội dung buổi thực hành 03

### Mục tiêu thực hiện

- Áp dụng lập trình hướng đối tượng vào bài toán quản lý công việc.
- Xác định các thực thể chính trong hệ thống.
- Tách dữ liệu khỏi giao diện để chuẩn bị cho kiến trúc nhiều lớp.

### Nội dung đã thực hiện

- Xây dựng các model chính:
  - `User`: thông tin người dùng và vai trò.
  - `Project`: thông tin dự án và danh sách thành viên.
  - `Task`: nhiệm vụ, deadline, trạng thái, người được giao.
  - `NotificationModel`: thông báo liên quan đến task và dự án.
- Bổ sung các phương thức xử lý trong model `Task` như:
  - kiểm tra trạng thái hợp lệ;
  - kiểm tra task quá hạn;
  - định dạng deadline;
  - chuyển đổi dữ liệu từ Map và sang Map.
- Làm quen với việc tổ chức code theo thư mục `models/`, `screens/`, `providers/`.

### Kết quả

Ứng dụng bắt đầu có lớp dữ liệu rõ ràng, phục vụ cho việc lưu trữ, đồng bộ và hiển thị ở các màn hình sau.

---

## Bài kiểm tra giữa kỳ - Phần việc cá nhân

### Trần Thị Thu Hường

- Phụ trách định hướng kiến trúc tổng thể của ứng dụng.
- Xây dựng các màn hình cốt lõi phục vụ luồng quản lý công việc:
  - `MainScreen`
  - `HomeScreen`
  - `LoginScreen`
  - `RegisterScreen`
  - `ProjectTaskScreen`
  - `TaskDetailScreen`
- Thiết kế luồng phân quyền Manager / Member.
- Đặt nền cho mô hình dữ liệu và cách tổ chức project.

### Nguyễn Việt Cường

- Phụ trách thiết kế UML cho hệ thống.
- Hỗ trợ xây dựng giao diện danh sách dự án.
- Thể hiện tiến độ dự án bằng thanh phần trăm hoàn thành.
- Chuẩn bị các sơ đồ phục vụ phần phân tích và báo cáo.

### Nguyễn Thị Thương

- Phụ trách phần giao diện hồ sơ cá nhân và chỉnh sửa thông tin.
- Hỗ trợ thiết kế UI/UX và tài liệu.
- Tham gia xây dựng module thông báo và theo dõi trạng thái kết nối.
- Biên soạn, rà soát nội dung báo cáo và tài liệu demo.

---

## Nội dung bài thực hành 04 (OOP Nâng cao - Tổng quát hóa & Chuyên biệt hóa)

### Mục tiêu thực hiện

- Nhận diện các phần có thể tổng quát hóa trong Flutter và Dart.
- Xây dựng các logic chuyên biệt cho nghiệp vụ quản lý task.
- Hoàn thiện phân tích theo yêu cầu bài thực hành OOP nâng cao.

### Tổng quát hóa đã áp dụng

- Các màn hình kế thừa `StatefulWidget` / `State` để dùng chung cơ chế vòng đời widget của Flutter.
- Các provider kế thừa `ChangeNotifier` để giao diện có thể lắng nghe thay đổi trạng thái.
- Repository Pattern tách phần khai báo nghiệp vụ khỏi phần cài đặt cụ thể.
- Generic class trong `lib/core/utils/data_printer.dart` giúp xử lý dữ liệu linh hoạt theo kiểu `T`.

### Chuyên biệt hóa đã áp dụng

- `MainScreen` chuyên biệt điều hướng theo vai trò:
  - Manager có thêm tab quản lý thành viên và quyền tạo task.
  - Member chỉ thấy các màn hình phù hợp với nhiệm vụ cá nhân.
- `HomeScreen` tải dữ liệu khác nhau theo vai trò Manager / Member.
- `ProjectTaskScreen` có Kanban và Calendar Tab để quản lý task theo trạng thái và deadline.
- `Task` định nghĩa state-machine riêng cho luồng công việc:

```text
todo -> doing -> reviewing -> done -> archived
```

- `TaskDetailScreen` hiển thị deadline, trạng thái quá hạn và thông tin chi tiết của nhiệm vụ.

### Kết quả

Nhóm chứng minh được hai hướng xử lý quan trọng trong OOP: dùng các lớp/kiểu tổng quát để tái sử dụng, đồng thời viết logic chuyên biệt cho nghiệp vụ TaskFlow.

---

## Phân công công việc cuối kỳ

| Thành viên | Công việc |
| :--- | :--- |
| **Trần Thị Thu Hường** | Quản lý tiến độ, thiết kế kiến trúc `UI -> Provider -> Repository -> Service`, xây dựng SQLite/Firestore schema, Firebase Auth, Firestore, offline sync, các màn hình quản lý chính và ràng buộc nghiệp vụ. |
| **Nguyễn Việt Cường** | Thiết kế Use Case Diagram, Class Diagram, Sequence Diagram, Activity Diagram; hỗ trợ `ProjectListScreen`; hiển thị tiến độ dự án; đóng góp phần tài liệu UML. |
| **Nguyễn Thị Thương** | Thiết kế UI/UX, phát triển `ProfileScreen`, `EditProfileScreen`, `NotificationScreen`, `NotificationProvider`, `ConnectivityProvider`; biên soạn báo cáo và tài liệu hệ thống. |

---
