# KỊCH BẢN CHI TIẾT VIDEO DEMO SẢN PHẨM - TASKFLOW (NHÓM N03)

Tài liệu này cung cấp kịch bản phân cảnh chi tiết, thời lượng phân bổ và lời thoại mẫu để quay video thuyết trình/demo sản phẩm ứng dụng **TaskFlow**. Video này được thiết kế để gây ấn tượng mạnh với giảng viên, tập trung làm nổi bật các tính năng kỹ thuật nâng cao (Offline-First, State Machine, Realtime Sync, Constraint Check).

---

## 🛠 CHUẨN BỊ TRƯỚC KHI QUAY
1. **Thiết bị:**
   * Tốt nhất sử dụng **2 thiết bị chạy song song** (hoặc 2 máy ảo, hoặc ghép màn hình):
     * **Thiết bị A:** Đăng nhập tài khoản **Manager (Trần Thị Thu Hường)**.
     * **Thiết bị B:** Đăng nhập tài khoản **Member (Nguyễn Việt Cường hoặc Nguyễn Thị Thương)**.
2. **Công cụ ghi màn hình:** OBS Studio hoặc Camtasia để ghép 2 màn hình song song (side-by-side) giúp thể hiện tính chất đồng bộ thời gian thực rõ ràng nhất.
3. **Môi trường test:** 
   * Trình duyệt mở sẵn **Firebase Firestore Console** để show dữ liệu biến động realtime.
   * Thiết bị Member có thể chủ động tắt/bật Wi-Fi (hoặc bật Chế độ máy bay) để demo tính năng Offline.

---

## 🎞 PHÂN CẢNH CHI TIẾT (TIMELINE)

### PHẦN 1: Giới thiệu dự án & User Stories (Thời lượng: 0:00 - 0:15)
* **Hình ảnh hiển thị:**
  * Màn hình slide giới thiệu dự án TaskFlow (Logo, Tên đề tài, Nhóm N03, Trường ĐH Phenikaa).
  * Chạy thử ứng dụng ở màn hình Splash Screen với hiệu ứng chuyển động mượt mà dẫn vào màn hình Login.
* **Lời thoại thuyết minh:**
  > "Xin chào cô và các bạn. Sau đây nhóm em xin trình bày và demo ứng dụng TaskFlow. Hệ thống được xây dựng từ các User Stories như đăng ký, đăng nhập, tạo dự án, giao việc, cập nhật tiến độ và nhận thông báo. Toàn bộ các User Stories này sẽ được minh họa trực tiếp trong phần demo."

---

### PHẦN 2: Luồng nghiệp vụ của Manager (Thời lượng: 0:15 - 2:15)
* **Hình ảnh hiển thị:**
  * Thao tác trên **Thiết bị A (Manager)**.
  * Thực hiện **Đăng nhập** tài khoản Manager.
  * Hiển thị **HomeScreen (Dashboard)**: Show các thẻ thống kê tổng quan (Todo, Doing, Done, Members) cùng biểu đồ hình tròn trực quan.
  * Di chuyển sang tab **Dự án (Project)** $\to$ Nhấn nút **(+)** để tạo dự án mới:
    * Nhập tên: *"Dự án Thiết kế Giao diện TaskFlow"*
    * Nhập mô tả.
    * Tích chọn thành viên tham gia dự án (chọn *Nguyễn Việt Cường* và *Nguyễn Thị Thương*).
  * Vào chi tiết dự án mới tạo $\to$ Nhấn nút **(+)** để tạo và phân công nhiệm vụ:
    * Tạo Task 1: *"Vẽ wireframe màn hình Home"*, gán cho *Nguyễn Việt Cường*, đặt cờ khẩn cấp (Urgent), chọn hạn chót (Deadline).
    * Nhấn Lưu. Task xuất hiện ngay lập tức trong Kanban/List với nhãn trạng thái `todo` màu đỏ.
* **Lời thoại thuyết minh:**
  > "*(Đăng nhập thành công)* Hệ thống gồm các đối tượng chính là User, Project, Task và Notification. Các đối tượng này được lưu trữ trên Firebase Firestore và được ánh xạ thông qua các model của ứng dụng.
  > *(Khi mở Dashboard)* Các luồng nghiệp vụ như đăng nhập, tạo dự án, giao nhiệm vụ và duyệt nhiệm vụ đã được nhóm mô hình hóa bằng Class Diagram, Activity Diagram và Sequence Diagram trong báo cáo.
  > *(Khi chuyển sang Project)* Đây là luồng công việc chính của hệ thống: Dashboard → Project → Task → Notification → Profile, tương ứng với Flow of Work đã trình bày trong báo cáo.
  > Tại đây, Manager có quyền tạo một dự án mới và gán các thành viên nhóm vào dự án đó. Tiếp theo, Manager có thể truy cập dự án và gán việc chi tiết cho từng thành viên. Như các bạn có thể thấy, em vừa tạo nhiệm vụ 'Vẽ wireframe' gán cho bạn Cường với nhãn khẩn cấp. Mọi thao tác này đều được cập nhật thời gian thực lên Cloud Firestore."

---

### PHẦN 3: Luồng công việc của Member & Trải nghiệm giao diện (Thời lượng: 2:15 - 4:15)
* **Hình ảnh hiển thị:**
  * Chuyển sang thao tác trên **Thiết bị B (Member)**.
  * Member đăng nhập $\to$ Vào tab dự án chung $\to$ Chọn dự án *"Dự án Thiết kế Giao diện TaskFlow"*.
  * Show các cách hiển thị linh hoạt:
    * **Kanban Tab:** Lướt ngang mượt mà qua các cột trạng thái.
    * **Calendar Tab:** Hiển thị lịch biểu mini, các ngày có task sẽ có chấm màu tương ứng trạng thái task.
  * Bắt đầu nhận việc: Member nhấn vào Task 1 $\to$ Nhấn **"BẮT ĐẦU LÀM"** $\to$ Trạng thái chuyển sang `doing` (màu vàng hổ phách).
  * Gửi duyệt công việc: Khi hoàn thành, Member nhấn **"GỬI DUYỆT"** $\to$ Hệ thống hỏi xác nhận $\to$ Chuyển trạng thái sang `reviewing` (màu xanh dương).
* **Lời thoại thuyết minh:**
  > "Bây giờ, hãy chuyển sang màn hình của **Member**. Member đăng nhập vào sẽ thấy các dự án mà mình được gán tham gia. Giao diện của chúng em hỗ trợ xem danh sách công việc linh hoạt dạng bảng Kanban trực quan hoặc dạng Lịch biểu (Calendar View) hiển thị các chấm màu chỉ định hạn chót nhiệm vụ.
  > Member sẽ bấm nhận việc bằng cách nhấn 'Bắt đầu làm' để chuyển task sang trạng thái 'Doing'. Khi hoàn tất công việc, Member chỉ cần nhấn nút 'Gửi duyệt' để chuyển trạng thái sang 'Reviewing' gửi lên cho Manager kiểm tra chất lượng."

---

### PHẦN 4: Tương tác phê duyệt & Local Notification (Thời lượng: 4:15 - 5:45)
* **Hình ảnh hiển thị:**
  * Quay lại **Thiết bị A (Manager)** $\to$ Vào màn hình chi tiết Task 1 đang ở trạng thái `reviewing`.
  * Đồng thời, trên **Thiết bị B (Member)**, show màn hình điện thoại nhận được **Local Notification** thông báo trạng thái nhiệm vụ thay đổi.
  * Manager thực hiện **Từ chối (Reject)**:
    * Nhập lý do: *"Thiếu thiết kế phiên bản Dark Mode, vui lòng bổ sung"* $\to$ Task quay về trạng thái `todo` và hiển thị lý do từ chối chi tiết trên màn hình Member.
  * Sau khi Member nộp lại $\to$ Manager nhấn **"DUYỆT"** $\to$ Trạng thái task chuyển thành `done` (màu xanh lá), phần trăm tiến độ của dự án trên Dashboard tự động tăng lên.
* **Lời thoại thuyết minh:**
  > "Tại thiết bị của Manager, một thẻ yêu cầu duyệt khẩn cấp sẽ nổi lên ở trang chủ. Manager xem chi tiết công việc của Member gửi. Nếu chưa đạt yêu cầu, Manager có thể nhấn 'Từ chối' và nhập lý do sửa đổi. Lúc này, nhờ cơ chế background listener, thiết bị của Member sẽ ngay lập tức nhận được một thông báo đẩy cục bộ (Local Notification) cảnh báo nhiệm vụ bị từ chối kèm lý do cụ thể.
  > Sau khi Member cập nhật và gửi duyệt lại, Manager phê duyệt hoàn tất. Task chuyển sang trạng thái 'Done' và tiến độ dự án trên trang chủ tự động tính toán lại thời gian thực."

---

### PHẦN 5: Tính năng nâng cao - Khóa Task mồ côi & Offline Sync (Thời lượng: 5:45 - 7:45)
* **Hình ảnh hiển thị:**
  * **Demo 1: Ràng buộc xóa thành viên (Task mồ côi)**
    * Trên máy Manager, vào quản lý thành viên dự án $\to$ Thử bỏ tích chọn Member đang có task dở dang (`todo/doing/reviewing`) $\to$ Nhấn Lưu $\to$ Hiện hộp thoại cảnh báo: *"Chặn hành động! Thành viên đang có công việc dở dang..."*
  * **Demo 2: Cơ chế Offline-First (Quan trọng nhất)**
    * Trên máy Member $\to$ **Tắt Wi-Fi** (hoặc bật Chế độ máy bay).
    * Member nhận một Task 2 khác $\to$ Nhấn **"BẮT ĐẦU LÀM"**.
    * Show màn hình cập nhật ngay lập tức sang trạng thái `doing` và hiển thị nhãn cảnh báo: *"Offline Mode - Thay đổi sẽ được đồng bộ khi có kết nối mạng"*. (Đây là cơ chế Optimistic UI và lưu cache local SQLite).
    * Mở Firebase Firestore Console trên trình duyệt để show cho giảng viên thấy: Dữ liệu trên server chưa hề thay đổi (vì đang offline).
    * **Bật Wi-Fi trở lại** trên thiết bị Member $\to$ Trong vòng vài giây, góc màn hình thông báo: *"Đồng bộ thành công dữ liệu ngoại tuyến"* $\to$ Màn hình Firebase Console tự động cập nhật dữ liệu nhảy sang trạng thái `doing` mà không cần reload.
* **Lời thoại thuyết minh:**
  > "Tiếp theo là hai tính năng nổi bật của hệ thống. Đầu tiên là **cơ chế ngăn chặn Task mồ côi**. Hệ thống sẽ tự động chặn không cho phép xóa thành viên ra khỏi dự án nếu họ đang gánh vác các task chưa hoàn tất. Manager bắt buộc phải giao việc cho người khác trước để đảm bảo tính trách nhiệm.
  > Thứ hai là **kiến trúc ngoại tuyến Offline-First**. Khi em ngắt hoàn toàn kết nối Wi-Fi trên máy Member và tiến hành nhận việc, ứng dụng vẫn phản hồi ngay lập tức nhờ ghi đè dữ liệu cục bộ vào SQLite. 
  > Khi mạng được khôi phục, bộ lọc ConnectivityProvider sẽ tự động quét hàng đợi SQLite local và đẩy đồng bộ ngược lên Firestore thời gian thực, đảm bảo dữ liệu không bị mất mát hay xung đột."

---

### PHẦN 6: Minh họa đồng bộ Firebase Cloud Firestore (Thời lượng: 7:45 - 8:15)
* **Hình ảnh hiển thị:**
  * Mở trình duyệt web hiển thị **Firebase Console (Cloud Firestore)** của dự án.
  * Chỉ rõ các collection chính (`users`, `projects`, `tasks`, `notifications`) và click mở cụ thể một document bên trong (ví dụ click vào một task thuộc collection `tasks` để show rõ các trường dữ liệu thực tế được ánh xạ như `title`, `assignedTo`, `status`...).
* **Lời thoại thuyết minh:**
  > "Toàn bộ dữ liệu đang được đồng bộ với Cloud Firestore. Các model sử dụng cơ chế toMap và fromMap để ánh xạ giữa Object và Document Firebase."

---

### PHẦN 7: Kiểm thử tính đúng đắn hệ thống - Validation & Testing (Thời lượng: 8:15 - 8:45)
* **Hình ảnh hiển thị:**
  * Thử nhập sai định dạng email hoặc mật khẩu không khớp khi Đăng nhập/Đăng ký.
  * Thử tạo nhiệm vụ và bỏ trống các trường bắt buộc (như Tiêu đề).
  * Show thông báo cảnh báo/validator phản hồi tức thì trên màn hình giao diện.
* **Lời thoại thuyết minh:**
  > "Nhóm đã thực hiện kiểm thử các trường hợp hợp lệ và không hợp lệ nhằm đảm bảo ứng dụng hoạt động ổn định."

---

### PHẦN 8: Quản lý mã nguồn trên GitHub (Thời lượng: 8:45 - 9:05)
* **Hình ảnh hiển thị:**
  * Mở trình duyệt hiển thị **GitHub Repository** của nhóm.
  * Mở các trang **Contributors** và **Commit History** trên GitHub để giảng viên thấy rõ tần suất và chi tiết đóng góp của từng thành viên nhóm.
* **Lời thoại thuyết minh:**
  > "Toàn bộ mã nguồn được quản lý trên GitHub. Mỗi thành viên đều có lịch sử commit riêng thể hiện đóng góp cá nhân. README, báo cáo và video demo được đính kèm theo yêu cầu của học phần."

---

### PHẦN 9: Kết luận & Lời cảm ơn (Thời lượng: 9:05 - 9:30)
* **Hình ảnh hiển thị:**
  * Màn hình slide cảm ơn (Slide Kết thúc).
* **Lời thoại thuyết minh:**
  > "Hệ thống TaskFlow đã hoạt động ổn định với đầy đủ các chức năng quản lý dự án, giao việc, theo dõi tiến độ, thông báo và đồng bộ dữ liệu. Nhóm N03 xin chân thành cảm ơn cô và các bạn đã theo dõi phần trình bày và demo sản phẩm của nhóm em."

---

## 💡 MẸO ĐỂ ĐẠT ĐIỂM TỐI ĐA (10/10)
* **Lồng ghép âm thanh chất lượng:** Nói to, rõ ràng, lọc nhiễu âm nền tốt. Tránh để video bị rè hoặc ngập ngừng.
* **Show code trực tiếp nếu cần thiết:** Ở cuối video hoặc lồng vào các phân cảnh, có thể dành ra 30 giây show lướt qua tệp `lib/services/sqlite_service.dart` hoặc quy tắc `firestore.rules` để khẳng định nhóm tự viết mã nguồn và giải quyết bài toán đồng bộ thực tế.
* **Tốc độ demo:** Chỉnh sửa cắt bỏ các khoảng chờ load ứng dụng không cần thiết để nhịp video nhanh, gọn, dứt khoát.
