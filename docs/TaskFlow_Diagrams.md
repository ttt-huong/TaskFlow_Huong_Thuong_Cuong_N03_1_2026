# Phân Tích Nghiệp Vụ & Sơ Đồ Quy Trình (TaskFlow Diagrams)

Tài liệu này trình bày chi tiết về phân tích nghiệp vụ của dự án TaskFlow, bao gồm sơ đồ Use Case toàn hệ thống, sơ đồ phân rã User Story Map và luồng hoạt động nghiệp vụ chi tiết giữa các vai trò (Manager và Member).

---

## I. PHÂN TÍCH NGHIỆP VỤ

### 1. Use Case Diagram (Sơ đồ ca sử dụng toàn hệ thống)

Sơ đồ Use Case mô tả trực quan các tác nhân (Actors) tương tác với các chức năng chính của hệ thống TaskFlow:

```mermaid
flowchart LR
    %% Thiết lập Actors
    subgraph Actors [Tác nhân]
        Manager["Quản lý (Manager) 💼"]
        Member["Thành viên (Member) 🧑‍💻"]
    end

    %% Thiết lập System Boundary
    subgraph System ["Hệ thống TaskFlow"]
        UC1(["Đăng nhập / Đăng ký"])
        UC2(["Quản lý Dự án (CRUD)"])
        UC3(["Quản lý Thành viên (Thêm/Xóa)"])
        UC4(["Giao nhiệm vụ (Tạo Task)"])
        UC5(["Chỉnh sửa / Gán lại Task"])
        UC6(["Xem danh sách Task dự án"])
        UC7(["Cập nhật trạng thái (Bắt đầu / Gửi duyệt)"])
        UC8(["Phê duyệt / Từ chối Task (Review)"])
        UC9(["Nhận thông báo tự động"])
    end

    %% Mối liên kết của Manager
    Manager --> UC1
    Manager --> UC2
    Manager --> UC3
    Manager --> UC4
    Manager --> UC5
    Manager --> UC6
    Manager --> UC8
    Manager --> UC9

    %% Mối liên kết của Member
    Member --> UC1
    Member --> UC6
    Member --> UC7
    Member --> UC9

    %% Style CSS
    style Manager fill:#eef2ff,stroke:#4f46e5,stroke-width:2px
    style Member fill:#f0fdf4,stroke:#16a34a,stroke-width:2px
    style UC1 fill:#fff,stroke:#64748b,stroke-width:1.5px
    style UC2 fill:#fff,stroke:#64748b,stroke-width:1.5px
    style UC3 fill:#fff,stroke:#64748b,stroke-width:1.5px
    style UC4 fill:#fff,stroke:#64748b,stroke-width:1.5px
    style UC5 fill:#fff,stroke:#64748b,stroke-width:1.5px
    style UC6 fill:#fff,stroke:#64748b,stroke-width:1.5px
    style UC7 fill:#fff,stroke:#64748b,stroke-width:1.5px
    style UC8 fill:#fff,stroke:#64748b,stroke-width:1.5px
    style UC9 fill:#fff,stroke:#64748b,stroke-width:1.5px
```

---

### 2. User Story Map (Bản đồ câu chuyện người dùng)

User Story Map phân rã các tính năng nghiệp vụ theo vai trò người dùng nhằm xác định các câu chuyện cụ thể cần giải quyết:

```mermaid
mindmap
  root((User Story Map))
    Manager (Quản lý)
      Project (Dự án)
        Tạo dự án mới
        Xem danh sách dự án
        Sửa/Xóa dự án
      Member (Thành viên)
        Thêm thành viên vào dự án
        Xóa thành viên khỏi dự án
        Ràng buộc kiểm tra task dở dang
      Task (Công việc)
        Tạo công việc mới
        Sửa chi tiết công việc
        Gán lại người thực hiện (Reassign)
        Xóa công việc
      Review (Phê duyệt)
        Duyệt hoàn thành (Approve -> DONE)
        Từ chối và gửi trả lại (Reject -> TODO)
    Member (Thành viên)
      View Task (Xem việc)
        Xem toàn bộ công việc trong dự án
        Xem chi tiết và lý do từ chối (nếu có)
      Update Status (Cập nhật tiến độ)
        Bắt đầu làm (TODO -> DOING)
        Gửi duyệt (DOING -> REVIEWING)
      Notification (Thông báo)
        Nhận thông báo khi được giao việc
        Nhận thông báo khi task thay đổi trạng thái
```

---

### 3. Business Workflow (Luồng nghiệp vụ hoạt động)

Sơ đồ thể hiện tiến trình làm việc phối hợp giữa Manager và Member từ khâu tạo dự án, phân công cho đến khi hoàn thành công việc:

```mermaid
flowchart TD
    %% Khởi tạo
    Start([Bắt đầu]) --> MgrCreate[Manager: Tạo dự án mới]
    MgrCreate --> MgrAddMember[Manager: Thêm các thành viên vào dự án]
    MgrAddMember --> MgrAssignTask[Manager: Giao nhiệm vụ cho Member]
    
    %% Phân công và thực hiện
    MgrAssignTask --> MemNotify[Member: Nhận thông báo giao việc]
    MemNotify --> MemView[Member: Xem chi tiết nhiệm vụ]
    MemView --> MemStart[Member: Bắt đầu làm<br><i>Chuyển sang DOING</i>]
    MemStart --> MemSubmit[Member: Hoàn thành & Gửi duyệt<br><i>Chuyển sang REVIEWING</i>]
    
    %% Review và kiểm duyệt
    MemSubmit --> MgrReview{Manager: Đánh giá kết quả?}
    
    %% Phản hồi
    MgrReview -- "Đạt yêu cầu (Approve)" --> MgrApprove[Manager: Phê duyệt hoàn tất<br><i>Chuyển sang DONE</i>]
    MgrReview -- "Chưa đạt yêu cầu (Reject)" --> MgrReject[Manager: Từ chối & Nhập lý do<br><i>Chuyển sang TODO</i>]
    
    %% Vòng lặp phản hồi
    MgrReject --> MemNotifyRej[Member: Nhận thông báo bị từ chối & lý do]
    MemNotifyRej --> MemView
    
    %% Hoàn thành
    MgrApprove --> Done([Hoàn thành])

    %% Thiết lập Styles
    style Start fill:#f1f5f9,stroke:#64748b,stroke-width:1.5px
    style Done fill:#f1f5f9,stroke:#64748b,stroke-width:1.5px
    style MgrCreate fill:#eef2ff,stroke:#4f46e5,stroke-width:1.5px
    style MgrAddMember fill:#eef2ff,stroke:#4f46e5,stroke-width:1.5px
    style MgrAssignTask fill:#eef2ff,stroke:#4f46e5,stroke-width:1.5px
    style MgrReview fill:#fffbeb,stroke:#d97706,stroke-width:1.5px
    style MgrApprove fill:#ecfdf5,stroke:#059669,stroke-width:1.5px
    style MgrReject fill:#fef2f2,stroke:#dc2626,stroke-width:1.5px
    
    style MemNotify fill:#f0fdf4,stroke:#16a34a,stroke-width:1.5px
    style MemView fill:#f0fdf4,stroke:#16a34a,stroke-width:1.5px
    style MemStart fill:#f0fdf4,stroke:#16a34a,stroke-width:1.5px
    style MemSubmit fill:#f0fdf4,stroke:#16a34a,stroke-width:1.5px
    style MemNotifyRej fill:#fef2f2,stroke:#dc2626,stroke-width:1.5px
```
