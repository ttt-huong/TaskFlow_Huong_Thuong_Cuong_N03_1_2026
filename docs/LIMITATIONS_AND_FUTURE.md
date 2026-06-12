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
