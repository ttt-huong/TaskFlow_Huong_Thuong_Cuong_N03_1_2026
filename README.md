# Buoi Thuc Hanh 01 - Flutter

## Thong tin du an
- Ten ung dung: Ung dung sinh ton trong Rung
- Nen tang: Flutter
- Muc tieu buoi 01: Khoi tao du an va tuy chinh man hinh chinh theo yeu cau nhom

## Noi dung da thuc hien
1. Khoi tao cau truc du an Flutter.
2. Cap nhat tieu de ung dung thanh ten ung dung nhom.
3. Hien thi danh sach thanh vien nhom tren man hinh chinh.
4. Giu nguyen giao dien va mau sac theo mau ban dau.

## Thanh vien nhom
- Tran Thi Thu Huong - 23010344
- Nguyen Thi Thuong - 23010308

## Cach chay du an
1. Cai dat Flutter SDK.
2. Tai thu vien:

	flutter pub get

3. Chay ung dung:

	flutter run

## Ghi chu
- File giao dien chinh: lib/main.dart
- README nay duoc cap nhat cho nhiem vu Buoi thuc hanh 01.

# Buoi Thuc Hanh 02 - Phat trien chuc nang quan ly du an

### Noi dung da thuc hien
- Hien thi danh sach nhan su voi cac thong tin: ID, ten, vai tro
- Hien thi danh sach cong viec voi cac thong tin: ID, ten, trang thai, nguoi duoc giao

### Danh sach nhan su
- Nguyen Van A (Manager)
- Tran Thi B (Member)
- Le Van C (Member)

### Danh sach cong viec
- Thiet ke UI (Trạng thái: Doing) - Người được giao: Tran Thi B
- Ket noi Firebase (Trạng thái: Todo) - Người được giao: Le Van C
- Test app (Trạng thái: Done) - Người được giao: Tran Thi B

## Ghi chu
- File giao dien chinh: lib/main.dart
- README nay duoc cap nhat cho nhiem vu Buoi thuc hanh 02.

# 🚀 Dự án TaskFlow - Nhóm 03

## 👥 Thành viên nhóm & Phân công công việc
1. **Trần Thị Thu Hường** (Trưởng nhóm)
   - **Phụ trách**: Xây dựng **Trang Home** (Dashboard tổng quan công việc).
   - **Nhiệm vụ**: Thiết kế giao diện theo mẫu Figma Content, quản lý điều hướng và tích hợp Header/Footer.
   
2. **Nguyễn Việt Cường**
   - **Phụ trách**: Xây dựng **Trang Content** (Danh sách dự án).
   - **Nhiệm vụ**: Thiết kế giao diện thẻ dự án, thanh tìm kiếm và phân loại công việc.

3. **Nguyễn Thị Thương**
   - **Phụ trách**: Xây dựng **Trang About** (Hồ sơ cá nhân).
   - **Nhiệm vụ**: Thiết kế trang Profile, hiển thị thông tin cá nhân và thống kê.

---

## 🔗 Thông tin nộp bài (Câu 1)
- **Link GitHub Repository**: [https://github.com/ttt-huong/TaskFlow_Huong_Thuong_Cuong_N03_1_2026](https://github.com/ttt-huong/TaskFlow_Huong_Thuong_Cuong_N03_1_2026)
- **Link README.md**: [https://github.com/ttt-huong/TaskFlow_Huong_Thuong_Cuong_N03_1_2026/blob/main/README.md](https://github.com/ttt-huong/TaskFlow_Huong_Thuong_Cuong_N03_1_2026/blob/main/README.md)

---

## 🛠 Kiến trúc ứng dụng
Dự án được xây dựng trên nền tảng **Flutter** với cấu trúc thư mục chuyên nghiệp:
- `lib/core/`: Chứa các hằng số màu sắc, font chữ và dữ liệu mẫu (SeedData).
- `lib/models/`: Định nghĩa cấu trúc dữ liệu (User, Project, Task).
- `lib/repositories/`: Xử lý logic dữ liệu và mock API.
- `lib/screens/`: Chứa giao diện các màn hình chính.
- `lib/widgets/common/`: Chứa `MainLayout` (Khung Header-Body-Footer dùng chung).
