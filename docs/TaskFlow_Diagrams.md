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
        UC10(["Quản lý hồ sơ cá nhân"])
        UC11(["Xem thống kê"])
        UC12(["Đồng bộ dữ liệu ngoại tuyến"])
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
    Manager --> UC11
    Manager --> UC12

    %% Mối liên kết của Member
    Member --> UC1
    Member --> UC6
    Member --> UC7
    Member --> UC9
    Member --> UC10
    Member --> UC12

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
    style UC10 fill:#fff,stroke:#64748b,stroke-width:1.5px
    style UC11 fill:#fff,stroke:#64748b,stroke-width:1.5px
    style UC12 fill:#fff,stroke:#64748b,stroke-width:1.5px
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

---

## II. KIẾN TRÚC HỆ THỐNG

### 4. Architecture Diagram (Sơ đồ kiến trúc phân tầng)

Sơ đồ thể hiện luồng dữ liệu và trách nhiệm của từng tầng trong kiến trúc ứng dụng (UI $\rightarrow$ Provider $\rightarrow$ Repository $\rightarrow$ Service $\rightarrow$ Databases).

> [!NOTE]
> **Ngoại lệ về luồng xử lý:** `NotificationProvider` là một ngoại lệ đặc biệt. Nó không đi qua lớp Repository mà trực tiếp lắng nghe các thay đổi trạng thái nhiệm vụ thông qua Firestore snapshots stream, sau đó ghi các bản ghi thông báo mới trực tiếp vào SQLite local thông qua `SQLiteService`.

```mermaid
flowchart TD
    subgraph UI_Layer ["Tầng Giao Diện (UI Layer)"]
        Screens["Giao diện (Screens / Widgets)"]
    end

    subgraph State_Layer ["Tầng Quản Lý Trạng Thái (State Provider Layer)"]
        Providers["Providers<br>(AuthProvider, ProjectProvider, TaskProvider, ConnectivityProvider)"]
        NotifProvider["NotificationProvider<br><i>(Ngoại lệ: Lắng nghe Firestore tasks trực tiếp & ghi SQLite local)</i>"]
    end

    subgraph Repos_Layer ["Tầng Nghiệp Vụ & Dữ Liệu (Repository Layer)"]
        AuthRepo["AuthRepository"]
        UserRepo["UserRepository"]
        ProjRepo["ProjectRepository"]
        TaskRepo["TaskRepository"]
    end

    subgraph Service_Layer ["Tầng Dịch Vụ Hạ Tầng (Service Layer)"]
        SQLiteService["SQLiteService<br>(Local Cache)"]
        FirebaseService["FirebaseService<br>(Firestore/Auth API)"]
        ConnectivityService["ConnectivityService"]
    end

    subgraph Persistence_Layer ["Tầng Lưu Trữ (Persistence Storage Layer)"]
        LocalDB[("Local DB (SQLite)")]
        RemoteDB[("Cloud Firestore & Firebase Auth")]
    end

    %% Luồng đi chuẩn: UI -> Provider -> Repository -> Service -> Firebase/SQLite
    Screens --> Providers
    Providers --> AuthRepo
    Providers --> UserRepo
    Providers --> ProjRepo
    Providers --> TaskRepo

    AuthRepo & UserRepo & ProjRepo & TaskRepo --> SQLiteService
    AuthRepo & UserRepo & ProjRepo & TaskRepo --> FirebaseService
    
    %% Luồng đi của ngoại lệ Notification
    Screens --> NotifProvider
    RemoteDB -.-> |snapshots: Lắng nghe realtime| NotifProvider
    NotifProvider --> |Ghi nhận thông báo| SQLiteService

    SQLiteService --> LocalDB
    FirebaseService --> RemoteDB
    ConnectivityService -.-> |Theo dõi mạng| SQLiteService & FirebaseService

    %% CSS Styling
    style UI_Layer fill:#f8fafc,stroke:#334155,stroke-width:1.5px
    style State_Layer fill:#f0f9ff,stroke:#0284c7,stroke-width:1.5px
    style Repos_Layer fill:#ecfdf5,stroke:#059669,stroke-width:1.5px
    style Service_Layer fill:#fffbeb,stroke:#d97706,stroke-width:1.5px
    style Persistence_Layer fill:#fff1f2,stroke:#e11d48,stroke-width:1.5px
```

---

### 5. Package Diagram (Sơ đồ Gói)

Sơ đồ gói biểu diễn mối quan hệ phụ thuộc giữa các thư mục/gói cấu trúc mã nguồn trong ứng dụng:

```mermaid
flowchart TB
    screens["📂 screens (Giao diện ứng dụng)"]
    providers["📂 providers (Quản lý trạng thái & UI logic)"]
    repositories["📂 repositories (Tầng trừu tượng dữ liệu)"]
    services["📂 services (Kết nối SQLite / Firebase)"]
    models["📂 models (Đối tượng dữ liệu / Thực thể)"]

    screens --> |import| providers
    screens --> |import| models
    providers --> |import| repositories
    providers --> |import| models
    repositories --> |import| services
    repositories --> |import| models
    services --> |import| models

    style screens fill:#f8fafc,stroke:#64748b,stroke-width:1.5px
    style providers fill:#eef2ff,stroke:#4f46e5,stroke-width:1.5px
    style repositories fill:#ecfdf5,stroke:#059669,stroke-width:1.5px
    style services fill:#fffbeb,stroke:#d97706,stroke-width:1.5px
    style models fill:#fff5f5,stroke:#e11d48,stroke-width:1.5px
```

---

### 6. Component Diagram (Sơ đồ thành phần)

Sơ đồ biểu diễn các thành phần nghiệp vụ và kỹ thuật cốt lõi tương tác với nhau trong hệ thống:

```mermaid
flowchart LR
    subgraph CoreComponents ["Thành phần cốt lõi (Core Components)"]
        Auth["Xác thực (Authentication)"]
        Project["Quản lý Dự án (Project)"]
        Task["Quản lý Công việc (Task)"]
        Notify["Thông báo (Notification)"]
        Stats["Thống kê (Statistics)"]
        OfflineSync["Đồng bộ ngoại tuyến (Offline Sync)"]
    end

    Auth --> |Cung cấp thông tin User| Project
    Auth --> |Cung cấp thông tin User| Task
    Project --> |Chứa danh sách| Task
    Task --> |Kích hoạt| Notify
    Task --> |Cung cấp dữ liệu nguồn| Stats
    OfflineSync --> |Đồng bộ hai chiều dữ liệu| Project
    OfflineSync --> |Đồng bộ hai chiều dữ liệu| Task

    style Auth fill:#eef2ff,stroke:#4f46e5,stroke-width:1.5px
    style Project fill:#ecfdf5,stroke:#059669,stroke-width:1.5px
    style Task fill:#f0f9ff,stroke:#0284c7,stroke-width:1.5px
    style Notify fill:#fdf2f8,stroke:#db2777,stroke-width:1.5px
    style Stats fill:#fffbeb,stroke:#d97706,stroke-width:1.5px
    style OfflineSync fill:#fef2f2,stroke:#dc2626,stroke-width:1.5px
```

---

### 6b. Notification Flow Diagram (Sơ đồ luồng xử lý thông báo thực tế)

Sơ đồ chi tiết cơ chế lắng nghe thay đổi nhiệm vụ trực tiếp và lưu trữ thông báo cục bộ của `NotificationProvider`:

```mermaid
flowchart TD
    Step1["Firestore: Trạng thái Task thay đổi (CRUD từ xa)"] --> Step2["NotificationProvider: Lắng nghe snapshot qua StreamSubscription"]
    Step2 --> Step3["NotificationProvider: So sánh trạng thái Task hiện tại và trước đó (previousTasks)"]
    Step3 --> Step4{"Trạng thái thay đổi hợp lệ?"}
    Step4 -- "Có (giao việc, từ chối, duyệt, chờ duyệt)" --> Step5["SQLite: Tạo notification_local (cacheNotification)"]
    Step4 -- "Không" --> StepDone([Bỏ qua])
    Step5 --> Step6["UI: Màn hình thông báo / Badge hiển thị tức thì"]
    Step6 --> StepDone

    style Step1 fill:#fff1f2,stroke:#e11d48,stroke-width:1.5px
    style Step2 fill:#f0f9ff,stroke:#0284c7,stroke-width:1.5px
    style Step3 fill:#f0f9ff,stroke:#0284c7,stroke-width:1.5px
    style Step4 fill:#fffbeb,stroke:#d97706,stroke-width:1.5px
    style Step5 fill:#ecfdf5,stroke:#059669,stroke-width:1.5px
    style Step6 fill:#fdf2f8,stroke:#db2777,stroke-width:1.5px
    style StepDone fill:#f1f5f9,stroke:#64748b,stroke-width:1.5px
```

---

### 7. Deployment Diagram (Sơ đồ triển khai vật lý)

Sơ đồ phân bố vật lý của các môi trường ứng dụng chạy ở client và lưu trữ đám mây phía server:

```mermaid
flowchart TD
    subgraph ClientNode ["Thiết bị khách hàng (Client Node)"]
        AndroidDevice["Thiết bị di động Android<br>(Hỗ trợ Flutter runtime / minSdk của dự án)"]
        subgraph AppRuntime ["Môi trường chạy App (TaskFlow App)"]
            FlutterApp["Ứng dụng Flutter / Dart VM"]
            SQLiteDB[("SQLite Database file<br>(taskflow.db)")]
            FlutterApp <--> |Đọc/Ghi cục bộ| SQLiteDB
        end
    end

    subgraph CloudServer ["Đám mây Google Cloud Platform / Firebase"]
        FirebaseAuthNode["Firebase Authentication<br>(Xác thực người dùng)"]
        FirestoreNode["Cloud Firestore NoSQL Database<br>(Lưu trữ tài liệu và đồng bộ)"]
    end

    FlutterApp --> |HTTPS / WSS (gRPC)| FirebaseAuthNode
    FlutterApp --> |HTTPS / WSS (gRPC)| FirestoreNode

    %% CSS Styling
    style ClientNode fill:#f8fafc,stroke:#475569,stroke-width:1.5px
    style AndroidDevice fill:#f0fdf4,stroke:#16a34a,stroke-width:1.5px
    style AppRuntime fill:#fffbeb,stroke:#d97706,stroke-width:1.5px
    style CloudServer fill:#fff1f2,stroke:#e11d48,stroke-width:1.5px
    style FirebaseAuthNode fill:#fff,stroke:#64748b,stroke-width:1px
    style FirestoreNode fill:#fff,stroke:#64748b,stroke-width:1px
```

