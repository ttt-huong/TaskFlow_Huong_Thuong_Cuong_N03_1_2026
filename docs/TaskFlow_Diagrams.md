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
        AuthService["AuthService<br>(Firebase Auth + user profile cache)"]
        FirebaseService["FirebaseService<br>(Firestore API)"]
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

    AuthRepo --> AuthService
    UserRepo & ProjRepo & TaskRepo --> SQLiteService
    UserRepo & ProjRepo & TaskRepo --> FirebaseService
    AuthService --> SQLiteService
    AuthService --> RemoteDB
    
    %% Luồng đi của ngoại lệ Notification
    Screens --> NotifProvider
    RemoteDB -.-> |snapshots: Lắng nghe realtime| NotifProvider
    NotifProvider --> |Ghi nhận thông báo| SQLiteService

    SQLiteService --> LocalDB
    FirebaseService --> RemoteDB
    ConnectivityService -.-> |Cung cấp trạng thái mạng| Providers
    ConnectivityService -.-> |Cung cấp trạng thái mạng| UserRepo
    ConnectivityService -.-> |Cung cấp trạng thái mạng| ProjRepo
    ConnectivityService -.-> |Cung cấp trạng thái mạng| TaskRepo

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
    widgets["📂 widgets (Widget dùng chung)"]
    core["📂 core (Màu sắc, text style, tiện ích chung)"]
    theme["📂 theme (Cấu hình giao diện)"]

    screens --> |import| providers
    screens --> |import| models
    screens --> |import| widgets
    screens --> |import| core
    providers --> |import| repositories
    providers --> |import| models
    providers -.-> |một số provider dùng trực tiếp| services
    repositories --> |import| services
    repositories --> |import| models
    services --> |import| models
    widgets --> |import| core
    theme --> |import| core

    style screens fill:#f8fafc,stroke:#64748b,stroke-width:1.5px
    style providers fill:#eef2ff,stroke:#4f46e5,stroke-width:1.5px
    style repositories fill:#ecfdf5,stroke:#059669,stroke-width:1.5px
    style services fill:#fffbeb,stroke:#d97706,stroke-width:1.5px
    style models fill:#fff5f5,stroke:#e11d48,stroke-width:1.5px
    style widgets fill:#f0f9ff,stroke:#0284c7,stroke-width:1.5px
    style core fill:#f8fafc,stroke:#334155,stroke-width:1.5px
    style theme fill:#faf5ff,stroke:#7e22ce,stroke-width:1.5px
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
    Task --> |Thay đổi trạng thái / assignee| Notify
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
    Step2 --> StepBase{"Snapshot đầu tiên?"}
    StepBase -- "Có" --> StepBaseSave["Lưu baseline previousTasks<br>không tạo thông báo"]
    StepBase -- "Không" --> Step3["NotificationProvider: So sánh trạng thái Task hiện tại và trước đó (previousTasks)"]
    Step3 --> Step4{"Trạng thái thay đổi hợp lệ?"}
    Step4 -- "Có (giao việc, từ chối, duyệt, chờ duyệt)" --> Step5["SQLite: Tạo notification_local (cacheNotification)"]
    Step4 -- "Không" --> StepDone([Bỏ qua])
    Step5 --> Step6["UI: Màn hình thông báo / Badge hiển thị tức thì"]
    StepBaseSave --> StepDone
    Step6 --> StepDone

    style Step1 fill:#fff1f2,stroke:#e11d48,stroke-width:1.5px
    style Step2 fill:#f0f9ff,stroke:#0284c7,stroke-width:1.5px
    style StepBase fill:#fffbeb,stroke:#d97706,stroke-width:1.5px
    style StepBaseSave fill:#f1f5f9,stroke:#64748b,stroke-width:1.5px
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

---

## III. CƠ SỞ DỮ LIỆU

### 8. ERD SQLite (Sơ đồ quan hệ cơ sở dữ liệu cục bộ SQLite)

Sơ đồ biểu diễn cấu trúc bảng vật lý và các khóa ngoại liên kết cục bộ trong tệp cơ sở dữ liệu di động của dự án:

```mermaid
erDiagram
    users_local {
        string id PK
        string name
        string email
        string role
        string offlineAuthHash
        string avatarChar
    }
    projects_local {
        string id PK
        string name
        string description
        string memberIds
        string syncedAt
        int isSynced
        string updatedAt
    }
    tasks_local {
        string id PK
        string title
        string description
        string projectId FK
        string assignedTo
        string status
        string deadline
        string syncedAt
        string assigneeName
        string assigneeAvatar
        int isUrgent
        string updatedAt
        int isSynced
        string rejectionReason
    }
    notifications_local {
        string id PK
        string userId FK
        string relatedTaskId FK
        string title
        string message
        string createdAt
        int isRead
        string type
    }

    projects_local ||--o{ tasks_local : "contains (projectId)"
    users_local ||--o{ tasks_local : "assignedTo"
    users_local ||--o{ notifications_local : "userId"
    tasks_local ||--o{ notifications_local : "relatedTaskId"
```

---

### 9. ERD Firestore (Sơ đồ NoSQL Firestore - Quan hệ logic)

Sơ đồ mô tả cấu trúc các tài liệu (Documents) thuộc các tập hợp (Collections) trong NoSQL Cloud Firestore và liên kết logic giữa chúng:

```mermaid
erDiagram
    users {
        string id PK
        string name
        string email
        string role
        string avatarChar
    }
    projects {
        string id PK
        string name
        string description
        array_string memberIds
        timestamp updatedAt
    }
    tasks {
        string id PK
        string title
        string description
        string projectId FK
        string assignedTo FK
        string status
        timestamp deadline
        string assigneeName
        string assigneeAvatar
        boolean isUrgent
        timestamp updatedAt
        string rejectionReason
    }

    projects ||--o{ tasks : "logical contains"
    users ||--o{ tasks : "assignedTo"
    projects }o--o{ users : "memberIds references"
```

---

### 10. Data Dictionary Diagram (Sơ đồ phân rã từ điển dữ liệu)

Sơ đồ phân rã trực quan mô tả chi tiết kiểu dữ liệu và ý nghĩa của từng trường thông tin trong các thực thể:

```mermaid
mindmap
  root((Từ điển dữ liệu<br>Data Dictionary))
    UserModel
      id : Định danh duy nhất (String / UUID)
      name : Tên hiển thị người dùng (String)
      email : Địa chỉ email đăng nhập (String)
      role : Vai trò (manager / member)
      password / offlineAuthHash : Mã băm mật khẩu ngoại tuyến (String)
      avatarChar : Ký tự đại diện người dùng (String)
    ProjectModel
      id : Định danh dự án (String / UUID)
      name : Tên dự án (String)
      description : Mô tả dự án (String)
      memberIds : Danh sách ID thành viên (Array String / CSV)
      updatedAt : Thời gian cập nhật cuối cùng (DateTime)
    Task
      id : Định danh công việc (String / UUID)
      title : Tiêu đề công việc (String)
      description : Mô tả chi tiết (String)
      projectId : ID dự án trực thuộc (String)
      assignedTo : ID thành viên được giao việc (String)
      status : Trạng thái (todo, doing, reviewing, done, cancelled)
      deadline : Hạn chót hoàn thành (DateTime)
      assigneeName : Tên người thực hiện (String)
      assigneeAvatar : Ký tự đại diện người thực hiện (String)
      isUrgent : Cờ khẩn cấp (Boolean / Integer)
      updatedAt : Thời gian cập nhật trạng thái (DateTime)
      rejectionReason : Lý do từ chối kiểm duyệt (String)
      isSynced : Cờ đồng bộ offline (Integer / Boolean)
    NotificationModel
      id : Định danh thông báo (String / UUID)
      userId : ID người nhận thông báo (String)
      relatedTaskId : ID công việc liên quan (String)
      title : Tiêu đề thông báo (String)
      message : Nội dung thông báo (String)
      createdAt : Thời gian tạo thông báo (DateTime)
      isRead : Trạng thái đã đọc (Boolean / Integer)
      type : Loại thông báo (task_assigned, task_rejected, task_approved, task_review_submitted)
```

---

### 11. Offline Sync Database Diagram (Sơ đồ đồng bộ dữ liệu ngoại tuyến)

Sơ đồ biểu diễn luồng đồng bộ hai chiều giữa Firestore và SQLite dựa trên cờ trạng thái đồng bộ (`isSynced`) và nhãn thời gian cập nhật (`updatedAt`):

```mermaid
flowchart LR
    %% Triển khai đồng bộ dữ liệu ngoại tuyến
    subgraph ServerNode ["Đám mây Firestore"]
        FS_Doc["Firestore Document<br>(updatedAt)"]
    end

    subgraph SyncEngine ["Cơ chế Đồng bộ (Sync Logic)"]
        direction TB
        ConflictCheck{"So sánh updatedAt<br>(Local vs Server)"}
        UnsyncedCheck{"Quét SQLite có<br>isSynced = 0?"}
    end

    subgraph LocalNode ["SQLite Local Cache"]
        SQL_Row["SQLite Table Row<br>(isSynced, updatedAt)"]
    end

    %% Luồng đẩy lên (Push offline modifications)
    SQL_Row --> |1. Tìm bản ghi có isSynced = 0| UnsyncedCheck
    UnsyncedCheck --> |2. Lưu Firestore & chuyển isSynced = 1| FS_Doc

    %% Luồng kéo về & giải quyết xung đột (Pull & Resolve Conflicts)
    FS_Doc --> |3. Đọc dữ liệu server| ConflictCheck
    SQL_Row --> |3. Đọc dữ liệu local| ConflictCheck
    ConflictCheck --> |4a. Server mới hơn: Ghi đè vào SQLite & đặt isSynced = 1| SQL_Row
    ConflictCheck --> |4b. Local mới hơn: Đẩy lên Firestore & đặt isSynced = 1| FS_Doc

    %% CSS Styling
    style ServerNode fill:#fff1f2,stroke:#e11d48,stroke-width:1.5px
    style LocalNode fill:#f0f9ff,stroke:#0284c7,stroke-width:1.5px
    style SyncEngine fill:#fffbeb,stroke:#d97706,stroke-width:1.5px
```
