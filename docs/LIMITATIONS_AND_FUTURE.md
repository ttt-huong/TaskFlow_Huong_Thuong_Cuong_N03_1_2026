# Báo cáo: Hạn chế kỹ thuật và Hướng phát triển của ứng dụng TaskFlow

Tài liệu này ghi nhận việc giải quyết hạn chế kỹ thuật và đề xuất các giải pháp khắc phục ở các phiên bản tiếp theo.

---

## 1. Ngăn chặn "Task mồ côi" khi xóa thành viên khỏi dự án (Đã giải quyết)

### 🚨 Hạn chế ban đầu
Khi Manager thực hiện cập nhật danh sách thành viên dự án và xóa bỏ một thành viên (loại bỏ khỏi danh sách `memberIds` của `ProjectModel`), hệ thống không tự động thay đổi thông tin người thực hiện trên các Task đang dở dang thuộc dự án đó, dẫn đến tình trạng dữ liệu mồ côi (Task được gán cho một thành viên không còn trong dự án).

### ✅ Giải pháp đã thực hiện
* **Kiểm tra ràng buộc phía Client khi xóa thành viên:** Đã xây dựng tính năng kiểm tra ràng buộc trước khi cập nhật thành viên. Khi Manager muốn xóa một thành viên khỏi dự án (bằng cách bỏ tích chọn trong dialog Quản lý thành viên), hệ thống sẽ quét tìm tất cả các Task chưa hoàn thành (`todo`, `doing`, `reviewing`) đang được giao cho người này trong dự án.
* **Cơ chế chặn và cảnh báo:** Nếu phát hiện thấy thành viên bị loại bỏ vẫn còn Task dở dang, hệ thống sẽ hiển thị hộp thoại cảnh báo chi tiết số lượng Task chưa hoàn thành và chặn thao tác lưu. Manager bắt buộc phải chuyển giao (Reassign) các Task này cho thành viên khác trước khi hoàn tất xóa thành viên đó ra khỏi dự án.


---

## 2. Đồng bộ hóa thông tin người được gán (Stale denormalized assigneeName/avatar)

### 🚨 Hạn chế hiện tại
Để tối ưu hóa hiệu năng render danh sách Task (không cần join bảng) và hỗ trợ hoàn hảo khả năng làm việc Ngoại tuyến (Offline) với SQLite, cấu trúc dữ liệu của `Task` lưu tĩnh thông tin `assigneeName` và `assigneeAvatar` dưới dạng bản sao snapshot tại thời điểm giao việc.
* **Hậu quả:** Khi một thành viên cập nhật họ tên của họ trong màn hình chỉnh sửa hồ sơ (`EditProfileScreen`), họ tên mới sẽ được lưu vào bảng `users` trên Firestore & SQLite. Tuy nhiên, thuộc tính `assigneeName` và `assigneeAvatar` trong các Task cũ đã gán cho họ không tự động cập nhật theo, dẫn đến sự không nhất quán dữ liệu hiển thị.

### 🚀 Hướng phát triển tương lai
* **Cách 1 - Cập nhật hàng loạt (Batch Update):** Khi người dùng cập nhật thành công họ tên mới của mình, hệ thống sẽ tự động thực hiện một truy vấn cập nhật hàng loạt (Firestore Batch Write / SQLite transaction) để cập nhật lại `assigneeName` và `assigneeAvatar` trên tất cả các Task đang có `assignedTo` trùng với ID của người dùng đó.
* **Cách 2 - Sử dụng cache người dùng cục bộ (Local Users Cache):** Tách biệt thông tin người dùng khỏi đối tượng Task. Hệ thống sẽ lưu trữ danh sách User đã tải về trong một cơ sở dữ liệu cache cục bộ (`users_cache_local`). Khi hiển thị Task, ứng dụng sẽ lấy thông tin tên/avatar động bằng cách ánh xạ nhanh từ cache này thông qua `assignedTo` ID, giúp dữ liệu luôn mới nhất mà vẫn đảm bảo tính năng offline.

---

## 3. Định hướng phát triển hệ thống (Future Roadmap)

Để nâng cấp TaskFlow thành một giải pháp quản trị dự án toàn diện và chuyên nghiệp, 10 định hướng phát triển chiến lược sau sẽ được triển khai trong tương lai:

### 3.1. Mô hình quản lý đa dự án (Multi-Project Manager)
* Cho phép một tài khoản Manager có thể quản lý nhiều dự án độc lập đồng thời thay vì mô hình đơn lẻ hiện tại. Hỗ trợ mô hình liên kết $1 \text{ Manager} \to N \text{ Projects} \to N \text{ Members}$.

### 3.2. Nhiều Manager đồng quản trị (Multiple Managers)
* Hỗ trợ đồng thời nhiều tài khoản Manager trong cùng hệ thống, phân quyền quản lý độc lập theo từng tập dự án hoặc hỗ trợ quản trị dự án chung.

### 3.3. Ràng buộc phụ thuộc nhiệm vụ (Task Dependency)
* Thiết lập các mối quan hệ phụ thuộc giữa các công việc (ví dụ: Task B chỉ được chuyển sang `doing` sau khi Task A hoàn thành sang `done`), kiểm soát nghiêm ngặt luồng quy trình nghiệp vụ.

### 3.4. Nhiệm vụ con (Subtask)
* Hỗ trợ tạo và chia nhỏ các đầu việc trong một nhiệm vụ cha (tương tự Jira/Trello/ClickUp). Nhiệm vụ cha chỉ được đánh dấu hoàn thành khi toàn bộ nhiệm vụ con đã xong.

### 3.5. Chế độ tối (Dark Mode)
* Bổ sung chế độ tối (Dark Mode) và cơ chế chuyển đổi giao diện tự động (System Theme Detection) giúp nâng cao trải nghiệm thị giác người dùng.

### 3.6. Thông báo đẩy nâng cao (Firebase Cloud Messaging)
* Tích hợp Firebase Cloud Messaging (FCM) để gửi thông báo đẩy thời gian thực khi ứng dụng chạy ngầm hoặc đã đóng hoàn toàn, đồng thời đồng bộ hóa trạng thái thông báo giữa các thiết bị.

### 3.7. Bảng phân tích Dashboard nâng cao (Advanced Statistics Dashboard)
* Tích hợp các biểu đồ phân tích sâu như Burn-down Chart (Tiến độ hoàn thành dự án), Velocity Chart (Tốc độ làm việc), chỉ số năng suất (Productivity Score) và bảng theo dõi hiệu suất nhóm (Team Performance Dashboard).

### 3.8. Chuẩn hóa quan hệ Nhiều - Nhiều (Project Member Mapping Table)
* Thay thế trường `memberIds` (chuỗi CSV) bằng bảng trung gian `project_members` (gồm `projectId`, `userId`, `role`) để quản lý quan hệ Nhiều-Nhiều chuyên nghiệp và tối ưu hóa tốc độ truy vấn SQLite.

### 3.9. Giải quyết xung đột thông minh (Advanced Conflict Resolution)
* Cải tiến cơ chế ghi đè tự động bằng giao diện so sánh sự khác biệt (Diff View), hỗ trợ gộp tự động (Auto-Merge) hoặc cho phép người dùng tự tay chọn phiên bản dữ liệu muốn giữ lại.

### 3.10. Đồng bộ hóa đa thiết bị (Multi-Device Synchronization)
* Đồng bộ hóa và duy trì tính nhất quán trạng thái ứng dụng đồng thời trên nhiều thiết bị đăng nhập cùng tài khoản thời gian thực.
