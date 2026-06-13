# 📋 TaskFlow v1.0 – Hệ Thống Quản Lý Công Việc Nhóm Thông Minh

TaskFlow v1.0 là ứng dụng quản lý công việc và dự án nhóm được phát triển bằng Flutter, Firebase và SQLite. Hệ thống hỗ trợ tạo dự án, phân công nhiệm vụ, theo dõi tiến độ thực hiện và quản lý thành viên trong nhóm một cách hiệu quả. Dữ liệu được đồng bộ theo thời gian thực thông qua Firebase, đồng thời được lưu trữ cục bộ bằng SQLite để hỗ trợ làm việc ngoại tuyến. Dự án được xây dựng nhằm nâng cao khả năng cộng tác, quản lý công việc và tối ưu hóa quy trình làm việc nhóm trong môi trường học tập và thực tế.
---

# 👥 1. Thành Viên Nhóm & Phân Công Công Việc

| Thành viên | MSSV | Vai trò | Nhiệm vụ chính |
|------------|------------|------------|------------|
| Nguyễn Việt Cường | [MSSV] | Frontend Developer | Thiết kế giao diện người dùng, xây dựng các màn hình quản lý công việc, quản lý dự án và tích hợp Provider để quản lý trạng thái ứng dụng. |
| Nguyễn Thị Thu Hường | [MSSV] | Backend Developer | Phát triển các chức năng xử lý dữ liệu, tích hợp Firebase Authentication, Cloud Firestore và xây dựng các Repository phục vụ truy xuất dữ liệu. |
| Nguyễn Thị Thương | [MSSV] | UI/UX Designer & Tester | Thiết kế giao diện, xây dựng nguyên mẫu hệ thống, kiểm thử chức năng và đánh giá trải nghiệm người dùng trước khi triển khai hoàn thiện sản phẩm. |

# 🎯 2. Giới Thiệu Dự Án

## 2.1 Bối Cảnh

Trong quá trình học tập và làm việc nhóm, việc quản lý tiến độ công việc thường gặp nhiều khó khăn như phân công nhiệm vụ chưa rõ ràng, khó theo dõi trạng thái thực hiện, dễ bỏ sót deadline và thiếu sự phối hợp giữa các thành viên. Nhiều nhóm vẫn sử dụng các phương pháp thủ công như trao đổi qua tin nhắn hoặc ghi chú rời rạc, dẫn đến hiệu quả quản lý chưa cao và mất nhiều thời gian tổng hợp thông tin.

## 2.2 Bài Toán Đặt Ra

Xuất phát từ thực tế trên, nhóm xây dựng hệ thống **TaskFlow** nhằm hỗ trợ quản lý công việc và dự án theo hướng tập trung. Hệ thống cho phép người dùng tạo dự án, phân công nhiệm vụ cho từng thành viên, theo dõi tiến độ xử lý, quản lý thời hạn hoàn thành và nhận thông báo khi có thay đổi liên quan đến công việc. Qua đó giúp tăng khả năng phối hợp, giảm thiểu sai sót và nâng cao hiệu suất làm việc nhóm.

## 2.3 Mục Tiêu Dự Án

Mục tiêu của dự án là xây dựng một ứng dụng quản lý công việc nhóm hiện đại, thân thiện với người dùng và dễ sử dụng trên nhiều thiết bị. Hệ thống hỗ trợ quản lý dự án, quản lý nhiệm vụ, quản lý thành viên, theo dõi tiến độ công việc theo thời gian thực và hỗ trợ làm việc ngay cả khi mất kết nối mạng. Đồng thời dự án cũng là cơ hội để nhóm vận dụng các kiến thức về Flutter, Firebase, SQLite, Provider Pattern và Repository Pattern vào một bài toán thực tế.

## 2.4 Phạm Vi Hệ Thống

Hệ thống tập trung vào các chức năng cốt lõi của một ứng dụng quản lý công việc nhóm bao gồm: đăng ký và đăng nhập tài khoản, quản lý thông tin cá nhân, tạo và quản lý dự án, thêm thành viên vào dự án, tạo và phân công nhiệm vụ, cập nhật trạng thái công việc, theo dõi deadline, nhận thông báo và đồng bộ dữ liệu giữa thiết bị cục bộ với Firebase. Hệ thống được phát triển dưới dạng ứng dụng Flutter và hướng đến môi trường học tập, làm việc nhóm quy mô nhỏ và vừa.

# 🛠️ 3. Công Nghệ Sử Dụng

Để xây dựng hệ thống TaskFlow, nhóm đã lựa chọn các công nghệ hiện đại và phù hợp với yêu cầu của một ứng dụng quản lý công việc nhóm, đảm bảo khả năng mở rộng, đồng bộ dữ liệu và tối ưu trải nghiệm người dùng.

## 3.1 Flutter

Flutter là framework phát triển ứng dụng đa nền tảng do Google phát triển. Flutter cho phép xây dựng giao diện đẹp mắt, hiệu năng cao và có thể triển khai trên nhiều nền tảng khác nhau từ cùng một mã nguồn.

**Vai trò trong dự án:**
- Xây dựng giao diện người dùng.
- Phát triển các màn hình chức năng của hệ thống.
- Hỗ trợ triển khai trên Android, iOS và Web.
- Tạo trải nghiệm người dùng thống nhất trên nhiều thiết bị.

## 3.2 Dart

Dart là ngôn ngữ lập trình chính được sử dụng trong Flutter.

**Vai trò trong dự án:**
- Xây dựng toàn bộ logic nghiệp vụ của hệ thống.
- Quản lý dữ liệu, xử lý sự kiện và tương tác với cơ sở dữ liệu.
- Kết nối giữa giao diện người dùng và các tầng xử lý dữ liệu.

## 3.3 Firebase Authentication

Firebase Authentication được sử dụng để quản lý tài khoản người dùng và xác thực đăng nhập.

**Vai trò trong dự án:**
- Đăng ký tài khoản.
- Đăng nhập hệ thống.
- Quản lý phiên làm việc của người dùng.
- Bảo mật thông tin xác thực.

## 3.4 Cloud Firestore

Cloud Firestore là cơ sở dữ liệu NoSQL trên nền tảng đám mây của Firebase.

**Vai trò trong dự án:**
- Lưu trữ thông tin người dùng.
- Lưu trữ dự án và nhiệm vụ.
- Đồng bộ dữ liệu theo thời gian thực.
- Hỗ trợ nhiều người dùng làm việc đồng thời trên cùng dự án.

## 3.5 SQLite

SQLite là cơ sở dữ liệu cục bộ được tích hợp trực tiếp trên thiết bị.

**Vai trò trong dự án:**
- Lưu trữ dữ liệu ngoại tuyến.
- Hỗ trợ truy xuất dữ liệu nhanh.
- Giảm phụ thuộc vào kết nối Internet.
- Đồng bộ dữ liệu khi thiết bị kết nối mạng trở lại.

## 3.6 Provider Pattern

Provider là thư viện quản lý trạng thái được Flutter khuyến nghị sử dụng.

**Vai trò trong dự án:**
- Quản lý trạng thái tập trung.
- Cập nhật giao diện tự động khi dữ liệu thay đổi.
- Giảm sự phụ thuộc giữa các thành phần trong hệ thống.
- Tăng khả năng bảo trì và mở rộng ứng dụng.

## 3.7 Repository Pattern

Repository Pattern là mô hình thiết kế giúp tách biệt tầng xử lý dữ liệu với tầng giao diện.

**Vai trò trong dự án:**
- Chuẩn hóa việc truy xuất dữ liệu.
- Tách biệt logic nghiệp vụ và cơ sở dữ liệu.
- Dễ dàng thay đổi nguồn dữ liệu trong tương lai.
- Tăng khả năng kiểm thử và bảo trì mã nguồn.

## 3.8 GitHub

GitHub được sử dụng để quản lý mã nguồn và hỗ trợ làm việc nhóm.

**Vai trò trong dự án:**
- Lưu trữ mã nguồn tập trung.
- Quản lý phiên bản.
- Theo dõi lịch sử thay đổi.
- Hỗ trợ cộng tác giữa các thành viên trong nhóm.

## 3.9 GitHub Actions

GitHub Actions được sử dụng để tự động hóa quá trình kiểm tra và xây dựng dự án.

**Vai trò trong dự án:**
- Kiểm tra mã nguồn tự động.
- Hỗ trợ quy trình CI/CD.
- Phát hiện lỗi sớm trong quá trình phát triển.
- Nâng cao chất lượng phần mềm.

- # 📂 4. Cấu Trúc Thư Mục Hệ Thống

Dự án TaskFlow được xây dựng theo mô hình phân tầng (Layered Architecture), giúp tách biệt giao diện người dùng, xử lý nghiệp vụ và quản lý dữ liệu. Cấu trúc thư mục được tổ chức rõ ràng nhằm tăng khả năng bảo trì, mở rộng và hỗ trợ làm việc nhóm hiệu quả.

lib/                              # Thư mục chứa toàn bộ mã nguồn chính của dự án TaskFlow
├── core/                         # Các tài nguyên, cấu hình cấu trúc dùng chung toàn app
│   ├── app_colors.dart           # Định nghĩa bảng màu sắc chủ đạo của ứng dụng
│   ├── app_text_styles.dart      # Cấu hình các kiểu font chữ, kích thước chữ chuẩn
│   ├── seed_data.dart            # Dữ liệu mẫu ban đầu để thử nghiệm ứng dụng
│   └── utils/                    # Các tiện ích, công cụ bổ trợ
│       └── data_printer.dart     # Công cụ hỗ trợ in/format dữ liệu ra log để kiểm tra
├── models/                       # Định nghĩa các thực thể dữ liệu (Data Models)
│   ├── project_model.dart        # Model thông tin dự án (Tên dự án, hạn chót, danh sách task...)
│   ├── task_model.dart           # Model thông tin công việc (Tiêu đề, mô tả, trạng thái, ngày tạo...)
│   └── user_model.dart           # Model thông tin thành viên, người dùng hệ thống
├── providers/                    # Tầng quản lý trạng thái ứng dụng (State Management)
│   ├── auth_provider.dart        # Quản lý trạng thái Đăng nhập, Đăng ký và phân quyền
│   ├── project_provider.dart     # Quản lý trạng thái, logic danh sách các dự án
│   ├── task_provider.dart        # Quản lý logic xử lý công việc (thêm, sửa, xóa, chuyển trạng thái)
│   ├── theme_provider.dart       # Quản lý chuyển đổi giao diện Sáng / Tối (Light/Dark mode)
│   └── _readme.dart              # File hướng dẫn lưu ý riêng cho phân hệ Provider
├── repositories/                 # Tầng trung gian kết nối giữa Service dữ liệu và Provider
│   ├── auth_repository.dart      # Interface (khuôn mẫu) cho các tính năng xác thực
│   ├── project_repository.dart   # Interface quản lý vòng đời của dự án
│   ├── task_repository.dart      # Interface định nghĩa các thao tác với công việc
│   ├── user_repository.dart      # Interface xử lý thông tin tài khoản người dùng
│   └── impl/                     # Nơi hiện thực hóa chi tiết các Interface (Implementation)
│       ├── auth_repository_impl.dart    # Triển khai chi tiết logic xác thực người dùng
│       ├── project_repository_impl.dart # Triển khai chi tiết việc lưu/đọc dữ liệu dự án
│       ├── task_repository_impl.dart    # Triển khai chi tiết lưu/đọc và cập nhật công việc
│       └── user_repository_impl.dart    # Triển khai chi tiết việc quản lý danh sách user
├── screens/                      # Phân hệ giao diện các màn hình chính (Presentation Layer)
│   ├── home_screen.dart          # Màn hình chính/Trang chủ hiển thị tổng quan thông tin
│   ├── login_screen.dart         # Màn hình đăng nhập hệ thống
│   ├── main_screen.dart          # Màn hình khung điều hướng chính (chứa Bottom Navigation)
│   ├── profile_screen.dart       # Giao diện thông tin cá nhân và cài đặt tài khoản
│   ├── project_list_screen.dart  # Giao diện danh sách tất cả các dự án đang tham gia
│   ├── project_task_screen.dart  # Màn hình hiển thị danh sách công việc thuộc về một dự án cụ thể
│   ├── register_screen.dart      # Giao diện đăng ký tài khoản mới cho thành viên
│   ├── task_detail_screen.dart   # Màn hình xem và chỉnh sửa chi tiết một công việc
│   └── user_list_screen.dart     # Màn hình danh sách thành viên trong hệ thống/nhóm
├── services/                     # Tầng kết nối cơ sở dữ liệu và các dịch vụ nền
│   ├── auth_service.dart         # Xử lý logic nghiệp vụ đăng nhập, đăng ký và bảo mật
│   ├── firebase_seed_data.dart   # Tự động nạp dữ liệu mẫu lên cơ sở dữ liệu Firebase
│   ├── firebase_service.dart     # Cấu hình và xử lý kết nối dữ liệu đám mây Firebase
│   ├── sqlite_service.dart       # Quản lý và thao tác với cơ sở dữ liệu offline SQLite tại máy
│   └── _readme.dart              # Ghi chú hướng dẫn thiết lập hệ thống dịch vụ dữ liệu
├── theme/                        # Cấu hình giao diện tổng thể của ứng dụng
│   └── app_theme.dart            # Thiết lập chi tiết ThemeData (Màu sắc, nút bấm, appBar...)
├── widgets/                      # Các thành phần giao diện nhỏ, có thể tái sử dụng
│   ├── _readme.dart              # Ghi chú quy định khi tạo widget dùng chung
│   └── common/                   # Các widget dùng chung cho nhiều màn hình khác nhau
│       ├── app_footer.dart       # Phần chân trang (Footer) chuẩn hóa của ứng dụng
│       ├── main_layout.dart      # Layout nền/khung chuẩn cho các màn hình
│       └── task_card.dart        # Thẻ hiển thị nhanh thông tin của một công việc
├── app.dart                      # Cấu hình khai báo các Provider toàn cục và Router định tuyến app
├── firebase_options.dart         # File tự động sinh chứa cấu hình kết nối ứng dụng với Firebase
├── main.dart                     # Tệp chạy chính, khởi tạo các dịch vụ nền (Database) và chạy app
└── run_my_task.dart              # File script hoặc hàm phụ trợ chạy nhanh/test các task cụ thể

# 🛠️ 5. Phân Tích Chức Năng Chi Tiết Từng File Code

## 5.1 Nhóm File Khởi Chạy (Bootstrapping Files)

### 📝 `lib/main.dart`

**Chức năng:**
Đây là điểm khởi đầu (Entry Point) của toàn bộ ứng dụng TaskFlow. Mọi quá trình khởi tạo hệ thống đều được thực hiện từ file này trước khi giao diện được hiển thị tới người dùng.

**Nội dung thực hiện:**

* Khởi tạo môi trường Flutter thông qua `WidgetsFlutterBinding.ensureInitialized()`.
* Thiết lập kết nối với hệ thống Firebase trước khi ứng dụng hoạt động.
* Khởi tạo các dịch vụ dữ liệu cần thiết phục vụ cho việc đăng nhập, quản lý dự án và quản lý công việc.
* Thiết lập các Provider quản lý trạng thái của ứng dụng.
* Tải các cấu hình giao diện và dữ liệu cần thiết trong lần chạy đầu tiên.
* Gọi hàm `runApp()` để khởi chạy ứng dụng TaskFlow.

**Vai trò trong hệ thống:**

File này đóng vai trò như cổng khởi động trung tâm của ứng dụng, đảm bảo toàn bộ các thành phần như Firebase, cơ sở dữ liệu và State Management được thiết lập đầy đủ trước khi người dùng bắt đầu sử dụng hệ thống.

---

### 📝 `lib/app.dart`

**Chức năng:**
Đây là file quản lý cấu trúc tổng thể của ứng dụng, chịu trách nhiệm liên kết các tầng xử lý dữ liệu với giao diện người dùng.

**Nội dung thực hiện:**

* Khai báo và khởi tạo `MultiProvider`.
* Đăng ký các Provider toàn cục của hệ thống:

  * AuthProvider
  * ProjectProvider
  * TaskProvider
  * ThemeProvider
* Thiết lập hệ thống điều hướng (Navigation & Routing).
* Kiểm tra trạng thái đăng nhập của người dùng để xác định màn hình khởi đầu phù hợp.
* Kết nối giao diện với ThemeProvider để hỗ trợ chuyển đổi giữa Light Mode và Dark Mode.
* Khởi tạo MaterialApp và các cấu hình chung cho toàn bộ ứng dụng.

**Vai trò trong hệ thống:**

Có thể xem `app.dart` là "trái tim" của TaskFlow, nơi tập trung quản lý luồng hoạt động giữa giao diện, trạng thái ứng dụng và các chức năng nghiệp vụ.

---

### 📝 `lib/firebase_options.dart`

**Chức năng:**
Đây là file được Firebase CLI tự động sinh ra trong quá trình cấu hình Firebase cho dự án.

**Nội dung thực hiện:**

* Lưu trữ các thông số kết nối tới Firebase Project.
* Cung cấp Firebase App ID, Project ID và các khóa cấu hình cần thiết.
* Hỗ trợ Firebase Authentication và Cloud Firestore hoạt động chính xác trên từng nền tảng.

**Vai trò trong hệ thống:**

File này giúp ứng dụng xác định chính xác dự án Firebase đang sử dụng và thực hiện kết nối an toàn tới các dịch vụ đám mây của Firebase.

---

### 📝 `lib/run_my_task.dart`

**Chức năng:**
Đây là file hỗ trợ chạy thử hoặc kiểm tra nhanh một số chức năng trong quá trình phát triển ứng dụng.

**Nội dung thực hiện:**

* Thử nghiệm các thao tác xử lý dữ liệu.
* Kiểm tra kết quả hoạt động của Model hoặc Repository.
* Hỗ trợ Debug trong quá trình phát triển.
* Kiểm tra nhanh các luồng nghiệp vụ mà không cần khởi chạy toàn bộ ứng dụng.

**Vai trò trong hệ thống:**

File này giúp nhóm phát triển rút ngắn thời gian kiểm thử và đánh giá kết quả xử lý của từng chức năng riêng lẻ trước khi tích hợp vào hệ thống chính thức.

## 5.2 Nhóm Tiện Ích Dùng Chung (Core Constants & Utilities)

Đây là nhóm file nền tảng của hệ thống TaskFlow, chịu trách nhiệm cung cấp các cấu hình dùng chung, dữ liệu mẫu và các công cụ hỗ trợ trong quá trình phát triển ứng dụng. Việc tách riêng các thành phần này giúp hệ thống dễ bảo trì, dễ mở rộng và đảm bảo tính nhất quán trên toàn bộ giao diện.

---

### 📝 `lib/core/app_colors.dart`

**Chức năng:**
Quản lý tập trung toàn bộ hệ thống màu sắc được sử dụng trong ứng dụng TaskFlow.

**Nội dung thực hiện:**

* Định nghĩa màu chủ đạo của hệ thống.
* Khai báo màu cho các trạng thái công việc khác nhau.
* Thiết lập màu nền, màu chữ và màu nút bấm.
* Hỗ trợ đồng bộ màu sắc giữa các màn hình.

**Vai trò trong hệ thống:**

Việc tập trung toàn bộ màu sắc vào một file duy nhất giúp quá trình thay đổi giao diện trở nên dễ dàng hơn, đồng thời đảm bảo sự thống nhất về mặt thiết kế trong toàn bộ ứng dụng.

---

### 📝 `lib/core/app_text_styles.dart`

**Chức năng:**
Quản lý toàn bộ kiểu chữ và định dạng văn bản được sử dụng trong ứng dụng.

**Nội dung thực hiện:**

* Định nghĩa kích thước font chuẩn.
* Thiết lập các kiểu tiêu đề, tiêu đề phụ và nội dung.
* Quy định độ đậm, độ nghiêng và khoảng cách giữa các dòng chữ.
* Chuẩn hóa hiển thị văn bản trên toàn bộ giao diện.

**Vai trò trong hệ thống:**

Giúp giao diện trở nên đồng nhất và chuyên nghiệp, đồng thời giảm thiểu việc khai báo lặp lại các thuộc tính văn bản ở nhiều nơi khác nhau.

---

### 📝 `lib/core/seed_data.dart`

**Chức năng:**
Lưu trữ dữ liệu mẫu phục vụ cho việc phát triển, kiểm thử và trình diễn hệ thống.

**Nội dung thực hiện:**

* Tạo sẵn các tài khoản người dùng mẫu.
* Khởi tạo các dự án mẫu.
* Tạo danh sách công việc thử nghiệm.
* Hỗ trợ kiểm tra các chức năng mà không cần nhập dữ liệu thủ công.

**Vai trò trong hệ thống:**

File này giúp nhóm phát triển có thể nhanh chóng kiểm tra giao diện và luồng xử lý nghiệp vụ trong quá trình xây dựng dự án.

---

### 📝 `lib/core/utils/data_printer.dart`

**Chức năng:**
Là công cụ hỗ trợ hiển thị và kiểm tra dữ liệu trong quá trình phát triển ứng dụng.

**Nội dung thực hiện:**

* In thông tin đối tượng ra màn hình Console.
* Hỗ trợ kiểm tra dữ liệu của User, Project và Task.
* Hiển thị dữ liệu dưới định dạng dễ đọc.
* Hỗ trợ Debug trong quá trình phát triển và kiểm thử.

**Vai trò trong hệ thống:**

Giúp lập trình viên theo dõi dữ liệu một cách trực quan, phát hiện lỗi nhanh hơn và kiểm tra tính chính xác của các thao tác xử lý nghiệp vụ trong ứng dụng.

---

### 📌 Vai Trò Của Tầng Core Trong Hệ Thống

Tầng Core đóng vai trò là nền tảng chung cho toàn bộ ứng dụng TaskFlow. Các thành phần trong tầng này được sử dụng xuyên suốt bởi nhiều module khác nhau như Provider, Repository, Service và Screen. Việc tổ chức tập trung các cấu hình và tiện ích dùng chung giúp giảm sự phụ thuộc giữa các thành phần, tăng khả năng tái sử dụng mã nguồn và giúp hệ thống dễ dàng bảo trì trong quá trình phát triển lâu dài.

## 5.3 Tầng Mô Hình Dữ Liệu (Models Layer)

Tầng `models` là nơi định nghĩa các thực thể dữ liệu chính của hệ thống TaskFlow. Mỗi file model đại diện cho một đối tượng quan trọng trong bài toán quản lý công việc nhóm. Các model giúp chuẩn hóa dữ liệu, hỗ trợ trao đổi thông tin giữa giao diện, Provider, Repository, Service và cơ sở dữ liệu.

---

### 📝 `lib/models/user_model.dart`

**Chức năng:**
Đại diện cho thông tin người dùng trong hệ thống TaskFlow.

**Nội dung thực hiện:**

* Lưu trữ thông tin cơ bản của người dùng.
* Quản lý định danh tài khoản.
* Lưu thông tin email, họ tên và vai trò người dùng.
* Hỗ trợ phân biệt người quản lý và thành viên trong hệ thống.
* Cung cấp dữ liệu phục vụ cho việc đăng nhập, phân công nhiệm vụ và hiển thị danh sách thành viên.

**Vai trò trong hệ thống:**

`UserModel` là một trong những model quan trọng nhất vì hầu hết các chức năng của TaskFlow đều liên quan đến người dùng. Mỗi người dùng có thể tham gia vào dự án, được phân công công việc, cập nhật trạng thái nhiệm vụ và nhận thông báo từ hệ thống.

---

### 📝 `lib/models/project_model.dart`

**Chức năng:**
Đại diện cho một dự án trong hệ thống quản lý công việc nhóm.

**Nội dung thực hiện:**

* Lưu trữ tên dự án.
* Lưu mô tả dự án.
* Quản lý danh sách thành viên tham gia dự án.
* Quản lý thời gian tạo và hạn hoàn thành dự án.
* Liên kết với danh sách các công việc thuộc dự án.

**Vai trò trong hệ thống:**

`ProjectModel` đóng vai trò trung tâm trong chức năng quản lý dự án. Mỗi dự án là một không gian làm việc riêng, nơi các thành viên có thể được thêm vào, nhận nhiệm vụ, theo dõi tiến độ và cùng nhau hoàn thành mục tiêu chung.

---

### 📝 `lib/models/task_model.dart`

**Chức năng:**
Đại diện cho một công việc cụ thể trong dự án.

**Nội dung thực hiện:**

* Lưu trữ tiêu đề công việc.
* Lưu mô tả chi tiết công việc.
* Quản lý trạng thái thực hiện của nhiệm vụ.
* Lưu thông tin người được giao nhiệm vụ.
* Lưu hạn hoàn thành công việc.
* Quản lý mức độ ưu tiên hoặc tiến độ xử lý.
* Hỗ trợ cập nhật trạng thái trong quá trình làm việc.

**Vai trò trong hệ thống:**

`TaskModel` là thực thể cốt lõi của TaskFlow. Các chức năng như tạo task, chỉnh sửa task, phân công task, chuyển trạng thái task và theo dõi deadline đều dựa trên model này. Đây là đối tượng thể hiện rõ nhất mục tiêu chính của hệ thống: quản lý công việc nhóm một cách hiệu quả.

---

### 📌 Mối Quan Hệ Giữa Các Model

Trong hệ thống TaskFlow, các model có quan hệ chặt chẽ với nhau:

* Một `UserModel` có thể tham gia nhiều dự án.
* Một `ProjectModel` có thể có nhiều thành viên.
* Một `ProjectModel` có thể chứa nhiều công việc.
* Một `TaskModel` thuộc về một dự án cụ thể.
* Một `TaskModel` có thể được giao cho một người dùng cụ thể.

Mối quan hệ này giúp hệ thống mô phỏng đúng quy trình làm việc nhóm trong thực tế: người dùng tham gia dự án, dự án chứa nhiều nhiệm vụ và mỗi nhiệm vụ được phân công cho thành viên phù hợp.

## 5.4 Tầng Dịch Vụ - Tương Tác Cơ Sở Dữ Liệu (Services Layer)

Đây là tầng chịu trách nhiệm giao tiếp trực tiếp với các nguồn dữ liệu của hệ thống như Firebase Authentication, Cloud Firestore và SQLite. Các Service đóng vai trò xử lý dữ liệu ở mức thấp trước khi dữ liệu được chuyển lên Repository và Provider để phục vụ giao diện người dùng.

---

### 📝 `lib/services/auth_service.dart`

**Chức năng:**
Quản lý toàn bộ nghiệp vụ xác thực tài khoản người dùng trong hệ thống.

**Nội dung thực hiện:**

* Xử lý đăng ký tài khoản mới.
* Xử lý đăng nhập hệ thống.
* Kiểm tra thông tin xác thực người dùng.
* Quản lý trạng thái đăng xuất.
* Đồng bộ thông tin tài khoản với Firebase Authentication.
* Hỗ trợ lưu và khôi phục phiên đăng nhập.

**Vai trò trong hệ thống:**

Đây là lớp dịch vụ quan trọng đảm bảo người dùng có thể truy cập hệ thống một cách an toàn. Mọi thao tác liên quan đến đăng nhập và xác thực đều phải thông qua lớp này.

---

### 📝 `lib/services/firebase_service.dart`

**Chức năng:**
Quản lý kết nối giữa ứng dụng TaskFlow và nền tảng Firebase.

**Nội dung thực hiện:**

* Khởi tạo kết nối Firebase.
* Thiết lập Cloud Firestore.
* Quản lý truy xuất dữ liệu trên Firebase.
* Đồng bộ dữ liệu giữa thiết bị và máy chủ.
* Hỗ trợ cập nhật dữ liệu theo thời gian thực.

**Vai trò trong hệ thống:**

Đây là cầu nối chính giữa ứng dụng và cơ sở dữ liệu đám mây. Toàn bộ dữ liệu về dự án, công việc và người dùng đều được đồng bộ thông qua lớp dịch vụ này.

---

### 📝 `lib/services/firebase_seed_data.dart`

**Chức năng:**
Tự động nạp dữ liệu mẫu lên Firebase phục vụ cho việc kiểm thử và trình diễn hệ thống.

**Nội dung thực hiện:**

* Khởi tạo danh sách người dùng mẫu.
* Khởi tạo dự án mẫu.
* Khởi tạo công việc mẫu.
* Đồng bộ dữ liệu thử nghiệm lên Firestore.
* Hỗ trợ kiểm tra các chức năng khi hệ thống vừa được cài đặt.

**Vai trò trong hệ thống:**

Giúp nhóm phát triển và giảng viên có thể nhanh chóng trải nghiệm đầy đủ các chức năng của ứng dụng mà không cần nhập dữ liệu thủ công từ đầu.

---

### 📝 `lib/services/sqlite_service.dart`

**Chức năng:**
Quản lý cơ sở dữ liệu SQLite được lưu trực tiếp trên thiết bị.

**Nội dung thực hiện:**

* Tạo và khởi tạo cơ sở dữ liệu cục bộ.
* Lưu trữ dữ liệu khi thiết bị mất kết nối Internet.
* Thực hiện các thao tác thêm, sửa, xóa và truy vấn dữ liệu.
* Hỗ trợ đồng bộ dữ liệu với Firebase khi có mạng trở lại.
* Giảm độ trễ truy xuất dữ liệu và tăng tốc độ phản hồi của ứng dụng.

**Vai trò trong hệ thống:**

SQLite giúp TaskFlow hoạt động theo mô hình Offline-First. Người dùng vẫn có thể xem và thao tác dữ liệu ngay cả khi không có kết nối mạng, sau đó dữ liệu sẽ được đồng bộ lại khi thiết bị trực tuyến.

---

### 📝 `lib/services/_readme.dart`

**Chức năng:**
Chứa các hướng dẫn kỹ thuật và ghi chú dành cho lập trình viên trong quá trình phát triển hệ thống.

**Nội dung thực hiện:**

* Mô tả cách sử dụng các Service.
* Quy định cấu trúc triển khai tầng dữ liệu.
* Hướng dẫn kết nối Firebase và SQLite.
* Cung cấp các lưu ý khi mở rộng hệ thống.

**Vai trò trong hệ thống:**

Giúp các thành viên trong nhóm dễ dàng nắm bắt kiến trúc tầng dữ liệu và tuân thủ thống nhất các quy tắc phát triển dự án.

---

### 📌 Vai Trò Của Services Layer Trong Hệ Thống

Services Layer là tầng giao tiếp trực tiếp với nguồn dữ liệu và các dịch vụ bên ngoài. Tầng này giúp tách biệt hoàn toàn việc xử lý dữ liệu khỏi giao diện người dùng, đảm bảo kiến trúc hệ thống rõ ràng, dễ bảo trì và dễ mở rộng. Toàn bộ dữ liệu được xử lý tại Service trước khi được chuyển tới Repository, Provider và cuối cùng hiển thị lên giao diện người dùng.

## 5.5 Tầng Repository - Quản Lý Truy Xuất Dữ Liệu (Repository Layer)

Repository Layer là tầng trung gian giữa Provider và Service, được xây dựng dựa trên **Repository Pattern** nhằm tách biệt hoàn toàn logic truy xuất dữ liệu khỏi giao diện người dùng. Nhờ đó hệ thống trở nên dễ bảo trì, dễ kiểm thử và có khả năng mở rộng tốt hơn trong tương lai.

Tầng này bao gồm hai phần chính:

* **Repository Interface:** Định nghĩa các chức năng cần thực hiện.
* **Repository Implementation:** Hiện thực hóa chi tiết các chức năng đã được định nghĩa.

---

### 📝 `lib/repositories/auth_repository.dart`

**Chức năng:**
Định nghĩa các nghiệp vụ liên quan đến xác thực tài khoản người dùng.

**Nội dung thực hiện:**

* Đăng ký tài khoản.
* Đăng nhập hệ thống.
* Đăng xuất tài khoản.
* Kiểm tra trạng thái đăng nhập.
* Truy xuất thông tin người dùng hiện tại.

**Vai trò trong hệ thống:**

Đây là khuôn mẫu chuẩn cho mọi thao tác xác thực trong ứng dụng TaskFlow.

---

### 📝 `lib/repositories/project_repository.dart`

**Chức năng:**
Định nghĩa các thao tác quản lý dự án.

**Nội dung thực hiện:**

* Tạo dự án mới.
* Cập nhật thông tin dự án.
* Xóa dự án.
* Lấy danh sách dự án.
* Tìm kiếm dự án theo điều kiện.

**Vai trò trong hệ thống:**

Chuẩn hóa các chức năng xử lý dữ liệu dự án và giúp các tầng phía trên không cần quan tâm dữ liệu được lưu ở Firebase hay SQLite.

---

### 📝 `lib/repositories/task_repository.dart`

**Chức năng:**
Định nghĩa các thao tác xử lý công việc trong hệ thống.

**Nội dung thực hiện:**

* Tạo công việc mới.
* Chỉnh sửa công việc.
* Xóa công việc.
* Cập nhật trạng thái công việc.
* Lấy danh sách công việc theo dự án.
* Truy xuất thông tin chi tiết công việc.

**Vai trò trong hệ thống:**

Là lớp trung gian chuẩn hóa toàn bộ nghiệp vụ quản lý nhiệm vụ trong TaskFlow.

---

### 📝 `lib/repositories/user_repository.dart`

**Chức năng:**
Định nghĩa các thao tác quản lý dữ liệu người dùng.

**Nội dung thực hiện:**

* Truy xuất danh sách người dùng.
* Lấy thông tin người dùng theo ID.
* Cập nhật hồ sơ cá nhân.
* Quản lý thành viên trong hệ thống.

**Vai trò trong hệ thống:**

Giúp quản lý tập trung dữ liệu người dùng và hỗ trợ các chức năng liên quan đến thành viên dự án.

---

## 5.5.1 Nhóm Repository Implementation

Đây là các lớp hiện thực hóa chi tiết toàn bộ nghiệp vụ đã được khai báo trong các Interface Repository.

---

### 📝 `lib/repositories/impl/auth_repository_impl.dart`

**Chức năng:**
Triển khai toàn bộ chức năng xác thực người dùng thông qua Firebase Authentication.

**Nội dung thực hiện:**

* Kết nối AuthService.
* Xử lý đăng ký tài khoản.
* Xử lý đăng nhập.
* Lưu trạng thái phiên làm việc.
* Đồng bộ thông tin tài khoản.

**Vai trò trong hệ thống:**

Là lớp thực thi trực tiếp các nghiệp vụ xác thực của hệ thống.

---

### 📝 `lib/repositories/impl/project_repository_impl.dart`

**Chức năng:**
Triển khai các chức năng quản lý dự án dựa trên Firebase và SQLite.

**Nội dung thực hiện:**

* Tạo mới dự án.
* Cập nhật thông tin dự án.
* Xóa dự án.
* Truy xuất danh sách dự án.
* Đồng bộ dữ liệu dự án giữa thiết bị và Firebase.

**Vai trò trong hệ thống:**

Là lớp chịu trách nhiệm xử lý toàn bộ dữ liệu liên quan đến dự án.

---

### 📝 `lib/repositories/impl/task_repository_impl.dart`

**Chức năng:**
Triển khai toàn bộ nghiệp vụ quản lý công việc trong hệ thống.

**Nội dung thực hiện:**

* Thêm công việc mới.
* Chỉnh sửa thông tin công việc.
* Cập nhật trạng thái nhiệm vụ.
* Xóa nhiệm vụ.
* Truy xuất danh sách công việc theo dự án.
* Đồng bộ dữ liệu công việc với Firebase.

**Vai trò trong hệ thống:**

Đây là lớp xử lý dữ liệu quan trọng nhất của TaskFlow vì mọi hoạt động quản lý nhiệm vụ đều đi qua lớp này.

---

### 📝 `lib/repositories/impl/user_repository_impl.dart`

**Chức năng:**
Triển khai các chức năng quản lý người dùng.

**Nội dung thực hiện:**

* Lấy danh sách thành viên.
* Truy xuất thông tin người dùng.
* Cập nhật hồ sơ cá nhân.
* Quản lý dữ liệu thành viên tham gia dự án.

**Vai trò trong hệ thống:**

Là lớp chịu trách nhiệm xử lý dữ liệu người dùng và cung cấp dữ liệu cho các chức năng quản lý thành viên trong ứng dụng.

---

### 📌 Vai Trò Của Repository Layer Trong Hệ Thống

Repository Layer giúp tách biệt hoàn toàn giao diện người dùng khỏi tầng dữ liệu. Thay vì giao tiếp trực tiếp với Firebase hoặc SQLite, các Provider sẽ làm việc thông qua Repository. Điều này giúp hệ thống tuân thủ nguyên tắc phân tầng, giảm sự phụ thuộc giữa các module và tăng khả năng mở rộng trong tương lai.

Nhờ áp dụng **Repository Pattern**, nhóm có thể thay đổi nguồn dữ liệu hoặc bổ sung thêm cơ sở dữ liệu mới mà không cần chỉnh sửa logic xử lý ở tầng giao diện.

## 5.6 Tầng Quản Lý Trạng Thái Tập Trung (Providers Layer)

Trong kiến trúc của TaskFlow, tầng Provider đóng vai trò quản lý trạng thái (State Management) của toàn bộ ứng dụng. Nhóm sử dụng **Provider Pattern** nhằm tách biệt giao diện người dùng khỏi logic xử lý nghiệp vụ, đồng thời giúp dữ liệu được cập nhật tự động trên giao diện khi có thay đổi.

Các Provider hoạt động như cầu nối giữa tầng Repository và tầng giao diện (Screens), giúp giảm sự phụ thuộc giữa các thành phần và nâng cao khả năng bảo trì của hệ thống.

---

### 📝 `lib/providers/auth_provider.dart`

**Chức năng:**
Quản lý toàn bộ trạng thái xác thực người dùng trong hệ thống.

**Nội dung thực hiện:**

* Quản lý trạng thái đăng nhập.
* Quản lý trạng thái đăng ký tài khoản.
* Lưu thông tin người dùng hiện tại.
* Kiểm tra phiên đăng nhập.
* Thông báo thay đổi trạng thái tới giao diện.

**Vai trò trong hệ thống:**

Provider này giúp các màn hình Login, Register và Profile luôn đồng bộ với trạng thái tài khoản hiện tại mà không cần truy xuất dữ liệu trực tiếp từ Firebase.

---

### 📝 `lib/providers/project_provider.dart`

**Chức năng:**
Quản lý toàn bộ dữ liệu liên quan đến dự án trong hệ thống.

**Nội dung thực hiện:**

* Lấy danh sách dự án.
* Tạo dự án mới.
* Cập nhật thông tin dự án.
* Xóa dự án.
* Theo dõi trạng thái tải dữ liệu.
* Tự động cập nhật giao diện khi danh sách dự án thay đổi.

**Vai trò trong hệ thống:**

Provider này đóng vai trò điều phối dữ liệu giữa Repository và các màn hình quản lý dự án, giúp giao diện luôn hiển thị thông tin mới nhất.

---

### 📝 `lib/providers/task_provider.dart`

**Chức năng:**
Quản lý toàn bộ nghiệp vụ liên quan đến công việc (Task) trong hệ thống.

**Nội dung thực hiện:**

* Tạo công việc mới.
* Chỉnh sửa công việc.
* Xóa công việc.
* Thay đổi trạng thái công việc.
* Lọc công việc theo dự án.
* Theo dõi tiến độ xử lý nhiệm vụ.
* Cập nhật giao diện theo thời gian thực.

**Vai trò trong hệ thống:**

Đây là Provider quan trọng nhất của TaskFlow vì mọi chức năng cốt lõi của ứng dụng đều xoay quanh việc quản lý công việc và tiến độ thực hiện nhiệm vụ.

---

### 📝 `lib/providers/theme_provider.dart`

**Chức năng:**
Quản lý giao diện sáng (Light Mode) và tối (Dark Mode) của ứng dụng.

**Nội dung thực hiện:**

* Chuyển đổi giữa chế độ sáng và tối.
* Lưu trạng thái giao diện của người dùng.
* Cập nhật ThemeData cho toàn bộ ứng dụng.
* Đồng bộ giao diện giữa các màn hình.

**Vai trò trong hệ thống:**

Giúp người dùng có trải nghiệm sử dụng linh hoạt hơn, đồng thời đảm bảo toàn bộ ứng dụng sử dụng chung một hệ thống giao diện thống nhất.

---

### 📝 `lib/providers/_readme.dart`

**Chức năng:**
Lưu trữ các hướng dẫn kỹ thuật và quy tắc phát triển dành riêng cho tầng Provider.

**Nội dung thực hiện:**

* Hướng dẫn cách xây dựng Provider mới.
* Quy định cách quản lý trạng thái.
* Mô tả mối quan hệ giữa Provider và Repository.
* Hỗ trợ các thành viên trong nhóm duy trì kiến trúc thống nhất.

**Vai trò trong hệ thống:**

Giúp đảm bảo toàn bộ nhóm phát triển tuân thủ cùng một quy chuẩn khi mở rộng hoặc bảo trì hệ thống.

---

### 📌 Vai Trò Của Provider Layer Trong Hệ Thống

Provider Layer là trung tâm điều phối trạng thái của ứng dụng TaskFlow. Thay vì để giao diện truy xuất trực tiếp dữ liệu từ Firebase hoặc SQLite, mọi dữ liệu đều được xử lý thông qua Provider. Điều này giúp giao diện trở nên đơn giản hơn, dữ liệu được quản lý tập trung hơn và toàn bộ ứng dụng có khả năng mở rộng tốt hơn.

Việc áp dụng **Provider Pattern** giúp giảm độ phức tạp của mã nguồn, tăng khả năng tái sử dụng các thành phần và đảm bảo dữ liệu luôn được cập nhật đồng bộ trên tất cả các màn hình của hệ thống.

## 5.7 Phân Hệ Giao Diện Các Màn Hình (Screens Layer)

Tầng giao diện (Presentation Layer) là nơi người dùng tương tác trực tiếp với hệ thống TaskFlow. Các màn hình được xây dựng bằng Flutter Widget và kết nối với các Provider để hiển thị dữ liệu cũng như xử lý các thao tác của người dùng.

---

### 5.7.1 Phân Hệ Xác Thực Tài Khoản (Authentication Module)

#### 📝 `lib/screens/login_screen.dart`

**Chức năng:**
Màn hình đăng nhập vào hệ thống TaskFlow.

**Nội dung thực hiện:**

* Nhập Email và Mật khẩu.
* Kiểm tra dữ liệu đầu vào.
* Gửi yêu cầu xác thực tới AuthProvider.
* Hiển thị thông báo khi đăng nhập thành công hoặc thất bại.
* Chuyển hướng người dùng tới màn hình chính sau khi xác thực thành công.

**Vai trò trong hệ thống:**

Đây là màn hình đầu tiên người dùng tiếp xúc khi sử dụng ứng dụng, đóng vai trò kiểm soát truy cập và bảo mật hệ thống.

📌 **[CHÈN ẢNH GIAO DIỆN ĐĂNG NHẬP]**

---

#### 📝 `lib/screens/register_screen.dart`

**Chức năng:**
Màn hình đăng ký tài khoản mới.

**Nội dung thực hiện:**

* Thu thập thông tin người dùng.
* Kiểm tra tính hợp lệ của dữ liệu.
* Tạo tài khoản mới trên Firebase Authentication.
* Lưu thông tin người dùng vào hệ thống.
* Chuyển hướng sang màn hình đăng nhập sau khi đăng ký thành công.

**Vai trò trong hệ thống:**

Cho phép người dùng mới tham gia vào hệ thống và bắt đầu sử dụng các chức năng quản lý công việc.

📌 **[CHÈN ẢNH GIAO DIỆN ĐĂNG KÝ]**

---

### 5.7.2 Phân Hệ Điều Hướng Chính (Main Navigation Module)

#### 📝 `lib/screens/main_screen.dart`

**Chức năng:**
Màn hình khung điều hướng trung tâm của ứng dụng.

**Nội dung thực hiện:**

* Quản lý Bottom Navigation Bar.
* Điều hướng giữa các phân hệ chính.
* Duy trì trạng thái các màn hình khi chuyển tab.
* Liên kết Home, Projects, Users và Profile.

**Vai trò trong hệ thống:**

Đây là trung tâm điều hướng của toàn bộ ứng dụng TaskFlow, giúp người dùng di chuyển nhanh giữa các chức năng.

📌 **[CHÈN ẢNH MAIN SCREEN]**

---

### 5.7.3 Phân Hệ Trang Chủ (Home Module)

#### 📝 `lib/screens/home_screen.dart`

**Chức năng:**
Hiển thị tổng quan thông tin quan trọng của hệ thống.

**Nội dung thực hiện:**

* Hiển thị số lượng dự án.
* Hiển thị số lượng công việc.
* Hiển thị tiến độ thực hiện công việc.
* Hiển thị các nhiệm vụ gần đến hạn.
* Hiển thị thông tin nhanh của người dùng.

**Vai trò trong hệ thống:**

Đây là Dashboard tổng quan giúp người dùng nắm bắt nhanh tình hình công việc hiện tại.

📌 **[CHÈN ẢNH HOME SCREEN]**

---

### 5.7.4 Phân Hệ Quản Lý Dự Án (Project Management Module)

#### 📝 `lib/screens/project_list_screen.dart`

**Chức năng:**
Hiển thị danh sách toàn bộ các dự án mà người dùng tham gia.

**Nội dung thực hiện:**

* Hiển thị danh sách dự án.
* Tạo dự án mới.
* Chỉnh sửa thông tin dự án.
* Xóa dự án.
* Tìm kiếm dự án.
* Xem nhanh trạng thái của từng dự án.

**Vai trò trong hệ thống:**

Là trung tâm quản lý các dự án, nơi người dùng có thể theo dõi và tổ chức công việc theo từng nhóm dự án khác nhau.

📌 **[CHÈN ẢNH DANH SÁCH DỰ ÁN]**

---

#### 📝 `lib/screens/project_task_screen.dart`

**Chức năng:**
Hiển thị danh sách công việc thuộc một dự án cụ thể.

**Nội dung thực hiện:**

* Liệt kê toàn bộ công việc trong dự án.
* Lọc công việc theo trạng thái.
* Hiển thị người phụ trách.
* Theo dõi tiến độ hoàn thành.
* Chuyển tới màn hình chi tiết công việc.

**Vai trò trong hệ thống:**

Giúp người dùng quản lý toàn bộ nhiệm vụ bên trong một dự án và theo dõi tình trạng thực hiện của từng công việc.

📌 **[CHÈN ẢNH DANH SÁCH TASK]**

---

### 5.7.5 Phân Hệ Quản Lý Công Việc (Task Management Module)

#### 📝 `lib/screens/task_detail_screen.dart`

**Chức năng:**
Hiển thị chi tiết một công việc cụ thể.

**Nội dung thực hiện:**

* Xem thông tin công việc.
* Chỉnh sửa tiêu đề và mô tả.
* Thay đổi trạng thái công việc.
* Cập nhật thời hạn hoàn thành.
* Thay đổi người được giao nhiệm vụ.
* Lưu thay đổi vào hệ thống.

**Vai trò trong hệ thống:**

Là nơi xử lý trực tiếp các nghiệp vụ liên quan đến một nhiệm vụ cụ thể trong dự án.

📌 **[CHÈN ẢNH TASK DETAIL]**

---

### 5.7.6 Phân Hệ Quản Lý Thành Viên (User Management Module)

#### 📝 `lib/screens/user_list_screen.dart`

**Chức năng:**
Hiển thị danh sách người dùng trong hệ thống.

**Nội dung thực hiện:**

* Liệt kê danh sách thành viên.
* Xem thông tin người dùng.
* Hỗ trợ lựa chọn thành viên khi giao nhiệm vụ.
* Quản lý danh sách người tham gia dự án.

**Vai trò trong hệ thống:**

Giúp người quản lý dễ dàng phân công công việc và kiểm soát nguồn nhân lực trong từng dự án.

📌 **[CHÈN ẢNH USER LIST]**

---

### 5.7.7 Phân Hệ Hồ Sơ Cá Nhân (Profile Module)

#### 📝 `lib/screens/profile_screen.dart`

**Chức năng:**
Quản lý thông tin cá nhân của người dùng.

**Nội dung thực hiện:**

* Hiển thị thông tin tài khoản.
* Chỉnh sửa hồ sơ cá nhân.
* Thay đổi giao diện sáng/tối.
* Xem thông tin hệ thống.
* Đăng xuất khỏi ứng dụng.

**Vai trò trong hệ thống:**

Cho phép người dùng quản lý thông tin cá nhân và các thiết lập liên quan tới trải nghiệm sử dụng ứng dụng.

📌 **[CHÈN ẢNH PROFILE SCREEN]**

---

### 📌 Vai Trò Của Screens Layer Trong Hệ Thống

Screens Layer là tầng giao diện trực tiếp tương tác với người dùng. Đây là nơi hiển thị dữ liệu được xử lý từ Provider và Repository, đồng thời tiếp nhận các thao tác từ người dùng để gửi tới các tầng xử lý phía dưới. Việc tách riêng tầng giao diện giúp hệ thống dễ bảo trì, dễ mở rộng và tuân thủ mô hình kiến trúc phân tầng hiện đại.

## 5.8 Thành Phần Giao Diện Tái Sử Dụng (Common Widgets)

Để giảm sự trùng lặp mã nguồn và tăng khả năng tái sử dụng các thành phần giao diện, dự án TaskFlow xây dựng một thư mục Widget dùng chung cho toàn bộ hệ thống. Các Widget này được sử dụng ở nhiều màn hình khác nhau, giúp đảm bảo giao diện thống nhất và dễ dàng bảo trì trong quá trình phát triển.

---

### 📝 `lib/widgets/common/main_layout.dart`

**Chức năng:**
Đây là khung giao diện chuẩn được sử dụng cho nhiều màn hình trong hệ thống.

**Nội dung thực hiện:**

* Tạo bố cục chung cho các màn hình.
* Chuẩn hóa khoảng cách, căn lề và kích thước hiển thị.
* Quản lý phần Header và Footer dùng chung.
* Hỗ trợ hiển thị nội dung động bên trong giao diện.
* Đảm bảo tính nhất quán giữa các màn hình.

**Vai trò trong hệ thống:**

Widget này giúp giảm đáng kể lượng mã giao diện lặp lại. Thay vì mỗi màn hình tự xây dựng bố cục riêng, các màn hình chỉ cần kế thừa hoặc sử dụng MainLayout để hiển thị nội dung của mình.

---

### 📝 `lib/widgets/common/task_card.dart`

**Chức năng:**
Hiển thị thông tin tóm tắt của một công việc dưới dạng thẻ (Card).

**Nội dung thực hiện:**

* Hiển thị tiêu đề công việc.
* Hiển thị trạng thái hiện tại.
* Hiển thị người phụ trách.
* Hiển thị thời hạn hoàn thành.
* Hiển thị mức độ ưu tiên hoặc tiến độ xử lý.
* Hỗ trợ thao tác chọn nhanh để xem chi tiết công việc.

**Vai trò trong hệ thống:**

Đây là Widget được sử dụng nhiều nhất trong dự án vì hầu hết các màn hình quản lý công việc đều cần hiển thị danh sách Task. Việc tách riêng thành TaskCard giúp giao diện đồng nhất và dễ bảo trì hơn.

---

### 📝 `lib/widgets/common/app_footer.dart`

**Chức năng:**
Xây dựng phần chân trang dùng chung cho toàn bộ hệ thống.

**Nội dung thực hiện:**

* Hiển thị thông tin ứng dụng.
* Hiển thị thông tin nhóm phát triển.
* Hiển thị phiên bản hiện tại của hệ thống.
* Chuẩn hóa bố cục Footer giữa các màn hình.

**Vai trò trong hệ thống:**

Giúp tạo sự đồng nhất về giao diện và cung cấp thông tin cần thiết cho người dùng trong quá trình sử dụng ứng dụng.

---

### 📝 `lib/widgets/_readme.dart`

**Chức năng:**
Chứa các ghi chú và quy tắc phát triển dành riêng cho thư viện Widget dùng chung.

**Nội dung thực hiện:**

* Quy định cách xây dựng Widget tái sử dụng.
* Hướng dẫn đặt tên Widget.
* Mô tả nguyên tắc tổ chức giao diện.
* Hỗ trợ các thành viên trong nhóm duy trì tính thống nhất của mã nguồn.

**Vai trò trong hệ thống:**

Giúp đảm bảo các Widget được xây dựng theo cùng một tiêu chuẩn, từ đó tăng khả năng tái sử dụng và giảm chi phí bảo trì hệ thống.

---

### 📌 Vai Trò Của Common Widgets Trong Hệ Thống

Các Widget dùng chung đóng vai trò quan trọng trong việc xây dựng giao diện của TaskFlow. Chúng giúp giảm thiểu việc viết lặp mã nguồn, tăng khả năng tái sử dụng và đảm bảo tính nhất quán giữa các màn hình. Nhờ đó giao diện trở nên chuyên nghiệp hơn, đồng thời giúp nhóm phát triển dễ dàng mở rộng và nâng cấp hệ thống trong tương lai.

# 🏗️ 6. Kiến Trúc Hệ Thống (System Architecture)

## 6.1 Kiến Trúc Tổng Thể

TaskFlow được xây dựng theo mô hình kiến trúc phân tầng (Layered Architecture), giúp tách biệt giao diện người dùng, xử lý nghiệp vụ và quản lý dữ liệu. Kiến trúc này giúp hệ thống dễ bảo trì, dễ mở rộng và thuận tiện cho việc phát triển theo nhóm.

📌 **[CHÈN ẢNH KIẾN TRÚC TỔNG THỂ]**

---

## 6.2 Luồng Xử Lý Dữ Liệu

Dữ liệu trong hệ thống được xử lý theo luồng:

**UI (Screens) → Provider → Repository → Service → Firebase / SQLite**

* Người dùng thực hiện thao tác trên giao diện.
* Provider tiếp nhận và quản lý trạng thái.
* Repository xử lý nghiệp vụ truy xuất dữ liệu.
* Service giao tiếp với Firebase hoặc SQLite.
* Kết quả được trả ngược lại giao diện để hiển thị.

📌 **[CHÈN ẢNH DATA FLOW]**

---

## 6.3 Provider Pattern

Hệ thống sử dụng Provider Pattern để quản lý trạng thái ứng dụng. Cách tiếp cận này giúp giao diện tự động cập nhật khi dữ liệu thay đổi, giảm sự phụ thuộc giữa các thành phần và tăng khả năng tái sử dụng mã nguồn.

---

## 6.4 Repository Pattern

Repository Pattern được sử dụng nhằm tách biệt tầng giao diện khỏi tầng dữ liệu. Toàn bộ thao tác đọc, ghi và cập nhật dữ liệu đều được thực hiện thông qua Repository trước khi làm việc với Firebase hoặc SQLite.

---

## 6.5 Đồng Bộ Firebase Và SQLite

TaskFlow áp dụng mô hình kết hợp giữa Firebase và SQLite để đảm bảo khả năng hoạt động trực tuyến và ngoại tuyến.

* Firebase đảm nhiệm lưu trữ và đồng bộ dữ liệu trên đám mây.
* SQLite lưu trữ dữ liệu cục bộ trên thiết bị.
* Khi mất kết nối Internet, dữ liệu vẫn có thể được truy cập từ SQLite.
* Khi kết nối được khôi phục, dữ liệu sẽ được đồng bộ trở lại Firebase.

Cơ chế này giúp tăng tính ổn định và đảm bảo trải nghiệm sử dụng liên tục cho người dùng.

# 🔄 7. Quy Trình Hoạt Động Của Hệ Thống

TaskFlow được xây dựng nhằm hỗ trợ người dùng quản lý công việc và dự án theo một quy trình rõ ràng, từ việc tạo tài khoản đến theo dõi tiến độ hoàn thành nhiệm vụ.

## 7.1 Đăng Ký Và Đăng Nhập

Người dùng tạo tài khoản mới thông qua màn hình đăng ký hoặc đăng nhập bằng tài khoản đã có. Hệ thống sử dụng Firebase Authentication để xác thực và quản lý phiên làm việc.

📌 **[CHÈN ẢNH LOGIN / REGISTER]**

---

## 7.2 Quản Lý Dự Án

Sau khi đăng nhập thành công, người dùng có thể tạo dự án mới hoặc tham gia vào các dự án hiện có. Mỗi dự án sẽ chứa danh sách thành viên và các công việc liên quan.

📌 **[CHÈN ẢNH PROJECT LIST]**

---

## 7.3 Quản Lý Công Việc

Trong từng dự án, người dùng có thể tạo mới công việc, chỉnh sửa nội dung, gán người thực hiện và thiết lập thời hạn hoàn thành. Các nhiệm vụ được tổ chức và theo dõi theo từng dự án cụ thể.

📌 **[CHÈN ẢNH TASK LIST]**

---

## 7.4 Cập Nhật Trạng Thái Công Việc

Người được giao nhiệm vụ có thể cập nhật trạng thái công việc trong quá trình thực hiện. Trạng thái được thay đổi theo tiến độ thực tế giúp các thành viên khác dễ dàng theo dõi tình hình dự án.

Ví dụ:

* To Do
* In Progress
* Review
* Completed

📌 **[CHÈN ẢNH TASK DETAIL]**

---

## 7.5 Quản Lý Thành Viên

Người dùng có thể xem danh sách thành viên trong hệ thống hoặc trong từng dự án. Chức năng này hỗ trợ việc phân công nhiệm vụ và theo dõi trách nhiệm của từng cá nhân.

📌 **[CHÈN ẢNH USER LIST]**

---

## 7.6 Đồng Bộ Dữ Liệu

Mọi thay đổi về dự án và công việc được lưu trữ trên Firebase để đảm bảo tính nhất quán giữa các thiết bị. Đồng thời dữ liệu cũng được lưu cục bộ bằng SQLite nhằm hỗ trợ làm việc khi mất kết nối Internet.

📌 **[CHÈN ẢNH DATA FLOW]**

---

## 7.7 Quản Lý Hồ Sơ Cá Nhân

Người dùng có thể xem và cập nhật thông tin cá nhân, thay đổi giao diện sáng/tối và thực hiện đăng xuất khỏi hệ thống thông qua màn hình Profile.

📌 **[CHÈN ẢNH PROFILE SCREEN]**

# 📝 8. User Stories

User Stories mô tả các nhu cầu thực tế của người dùng khi sử dụng hệ thống TaskFlow. Thông qua các User Stories, nhóm xác định được các chức năng cần xây dựng nhằm đáp ứng đúng yêu cầu nghiệp vụ của hệ thống quản lý công việc nhóm.

---

## 8.1 Vai Trò Người Dùng (User)

### US01 – Đăng Ký Tài Khoản

**Là một người dùng mới**, tôi muốn đăng ký tài khoản để có thể sử dụng các chức năng của hệ thống.

### US02 – Đăng Nhập Hệ Thống

**Là một người dùng**, tôi muốn đăng nhập bằng tài khoản của mình để truy cập các dự án và công việc được giao.

### US03 – Cập Nhật Hồ Sơ Cá Nhân

**Là một người dùng**, tôi muốn chỉnh sửa thông tin cá nhân để hồ sơ của mình luôn được cập nhật chính xác.

---

## 8.2 Vai Trò Quản Lý Dự Án (Project Manager)

### US04 – Tạo Dự Án Mới

**Là một người quản lý dự án**, tôi muốn tạo dự án mới để tổ chức và quản lý công việc của nhóm.

### US05 – Quản Lý Thành Viên

**Là một người quản lý dự án**, tôi muốn thêm hoặc theo dõi các thành viên tham gia dự án để phân công công việc phù hợp.

### US06 – Tạo Công Việc

**Là một người quản lý dự án**, tôi muốn tạo các nhiệm vụ mới để phân chia công việc cho từng thành viên.

### US07 – Phân Công Nhiệm Vụ

**Là một người quản lý dự án**, tôi muốn giao nhiệm vụ cho từng thành viên để xác định rõ trách nhiệm của mỗi người.

### US08 – Theo Dõi Tiến Độ

**Là một người quản lý dự án**, tôi muốn theo dõi trạng thái các công việc để đánh giá tiến độ thực hiện của dự án.

---

## 8.3 Vai Trò Thành Viên Dự Án (Team Member)

### US09 – Xem Danh Sách Công Việc

**Là một thành viên**, tôi muốn xem các công việc được giao để biết nhiệm vụ cần thực hiện.

### US10 – Cập Nhật Trạng Thái Công Việc

**Là một thành viên**, tôi muốn thay đổi trạng thái nhiệm vụ để phản ánh tiến độ làm việc thực tế.

### US11 – Xem Chi Tiết Công Việc

**Là một thành viên**, tôi muốn xem đầy đủ thông tin của nhiệm vụ để hiểu rõ yêu cầu cần thực hiện.

### US12 – Theo Dõi Deadline

**Là một thành viên**, tôi muốn biết thời hạn hoàn thành công việc để chủ động sắp xếp thời gian làm việc.

---

## 8.4 Lợi Ích Của User Stories

Thông qua các User Stories trên, hệ thống TaskFlow đáp ứng đầy đủ các nhu cầu cơ bản của một ứng dụng quản lý công việc nhóm, bao gồm quản lý dự án, quản lý nhiệm vụ, phân công công việc, theo dõi tiến độ và hỗ trợ cộng tác giữa các thành viên trong nhóm.

# 🔍 9. Phân Tích Yêu Cầu Hệ Thống

## 9.1 Đối Tượng Sử Dụng Hệ Thống

Hệ thống TaskFlow được xây dựng phục vụ hai nhóm người dùng chính:

### Quản Lý Dự Án (Project Manager)

* Tạo và quản lý dự án.
* Tạo công việc và phân công nhiệm vụ.
* Theo dõi tiến độ thực hiện.
* Quản lý thành viên tham gia dự án.

### Thành Viên Dự Án (Team Member)

* Xem danh sách công việc được giao.
* Cập nhật trạng thái công việc.
* Theo dõi tiến độ và thời hạn hoàn thành.
* Quản lý thông tin cá nhân.

---

## 9.2 Yêu Cầu Chức Năng

Hệ thống cần đáp ứng các chức năng chính sau:

### Quản Lý Tài Khoản

* Đăng ký tài khoản.
* Đăng nhập hệ thống.
* Đăng xuất.
* Cập nhật thông tin cá nhân.

### Quản Lý Dự Án

* Tạo dự án mới.
* Chỉnh sửa thông tin dự án.
* Xóa dự án.
* Xem danh sách dự án.

### Quản Lý Công Việc

* Tạo công việc mới.
* Chỉnh sửa công việc.
* Xóa công việc.
* Phân công nhiệm vụ.
* Cập nhật trạng thái công việc.
* Theo dõi tiến độ thực hiện.

### Quản Lý Thành Viên

* Xem danh sách thành viên.
* Giao nhiệm vụ cho thành viên phù hợp.
* Theo dõi người thực hiện công việc.

---

## 9.3 Yêu Cầu Phi Chức Năng

### Hiệu Năng

* Hệ thống phản hồi nhanh.
* Truy xuất dữ liệu ổn định.
* Hỗ trợ đồng bộ dữ liệu hiệu quả.

### Bảo Mật

* Xác thực người dùng bằng Firebase Authentication.
* Chỉ người dùng hợp lệ mới được truy cập hệ thống.
* Bảo vệ dữ liệu người dùng.

### Khả Năng Mở Rộng

* Dễ dàng bổ sung chức năng mới.
* Hỗ trợ mở rộng số lượng người dùng và dự án.

### Khả Năng Sử Dụng

* Giao diện thân thiện.
* Dễ thao tác và dễ tiếp cận.
* Hỗ trợ chế độ sáng và tối.

---

## 9.4 Các Đối Tượng Chính Trong Hệ Thống

### User

Đại diện cho người sử dụng hệ thống.

### Project

Đại diện cho một dự án làm việc.

### Task

Đại diện cho một nhiệm vụ cụ thể trong dự án.

---

## 9.5 Mối Quan Hệ Giữa Các Đối Tượng

* Một **User** có thể tham gia nhiều **Project**.
* Một **Project** có thể có nhiều **User** tham gia.
* Một **Project** có thể chứa nhiều **Task**.
* Một **Task** thuộc về một **Project**.
* Một **Task** được giao cho một **User** thực hiện.

📌 **[CHÈN CLASS DIAGRAM TẠI ĐÂY]**

---

## 9.6 Kết Luận

Thông qua việc phân tích yêu cầu, nhóm xác định được các chức năng và đối tượng cốt lõi của hệ thống TaskFlow. Đây là cơ sở để thiết kế cơ sở dữ liệu, xây dựng giao diện và triển khai các chức năng nghiệp vụ trong quá trình phát triển dự án.

# 🧪 10. Kết Quả Kiểm Thử

Sau khi hoàn thành quá trình phát triển, nhóm đã tiến hành kiểm thử các chức năng chính của hệ thống nhằm đảm bảo ứng dụng hoạt động ổn định và đáp ứng đúng yêu cầu đặt ra.

| Chức năng                     | Kết quả    |
| ----------------------------- | ---------- |
| Đăng ký tài khoản             | Thành công |
| Đăng nhập hệ thống            | Thành công |
| Tạo dự án mới                 | Thành công |
| Chỉnh sửa dự án               | Thành công |
| Xóa dự án                     | Thành công |
| Tạo công việc mới             | Thành công |
| Chỉnh sửa công việc           | Thành công |
| Cập nhật trạng thái công việc | Thành công |
| Quản lý thành viên            | Thành công |
| Đồng bộ Firebase              | Thành công |
| Lưu trữ SQLite                | Thành công |
| Chuyển đổi Dark/Light Mode    | Thành công |

📌 **[CHÈN ẢNH DEMO CÁC CHỨC NĂNG]**

---

# 🚀 11. Hướng Dẫn Cài Đặt Và Chạy Dự Án

## Yêu Cầu Môi Trường

* Flutter SDK 3.x trở lên
* Dart SDK
* Android Studio hoặc Visual Studio Code
* Firebase Project đã được cấu hình

---

## Clone Dự Án

```bash
git clone <repository-url>
cd TaskFlow_Huong_Thuong_Cuong_N03_1_2026
```

---

## Cài Đặt Thư Viện

```bash
flutter pub get
```

---

## Chạy Ứng Dụng

```bash
flutter run
```

---

## Build Ứng Dụng

Android:

```bash
flutter build apk
```

Web:

```bash
flutter build web
```

---

# 🎯 12. Kết Luận

TaskFlow là hệ thống quản lý công việc nhóm được phát triển bằng Flutter, Firebase và SQLite nhằm hỗ trợ tổ chức công việc, phân công nhiệm vụ và theo dõi tiến độ dự án. Thông qua dự án, nhóm đã vận dụng các kiến thức về lập trình hướng đối tượng, quản lý trạng thái bằng Provider, Repository Pattern và phát triển ứng dụng đa nền tảng với Flutter.

Trong quá trình thực hiện, hệ thống đã hoàn thành các chức năng cốt lõi như quản lý tài khoản, quản lý dự án, quản lý công việc, quản lý thành viên và đồng bộ dữ liệu giữa Firebase và SQLite. Kết quả đạt được cho thấy ứng dụng hoạt động ổn định, đáp ứng được các yêu cầu cơ bản của một hệ thống quản lý công việc nhóm.

Trong tương lai, hệ thống có thể được mở rộng thêm các chức năng như thông báo thời gian thực, quản lý lịch làm việc, báo cáo tiến độ dự án, thống kê hiệu suất làm việc và tích hợp thêm các nền tảng cộng tác trực tuyến khác nhằm nâng cao trải nghiệm người dùng.
