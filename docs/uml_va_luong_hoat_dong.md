# UML & Luồng Hoạt Động – Dự án TaskFlow (Bản Kỹ Thuật Chi Tiết)

> Cập nhật: 2026-06-12 – Đồng bộ hoàn toàn với mã nguồn thực tế và các tính năng nâng cao  
> Cấu trúc dữ liệu, logic phân quyền và luồng đồng bộ đã được nâng cấp toàn diện

---

## 1. Class Diagram (Sơ đồ lớp)

### 1.1 Data Models (`models/`)

Sơ đồ biểu diễn cấu trúc của các đối tượng dữ liệu trong hệ thống:

```mermaid
classDiagram
    class UserModel {
        +String id
        +String name
        +String email
        +String password
        +String role
        +String avatarChar
        +UserModel.fromMap(Map data, String id)
        +Map toMap()
        +bool isManager
        +String toString()
    }

    class ProjectModel {
        +String id
        +String name
        +String description
        +List<String> memberIds
        +DateTime updatedAt
        +ProjectModel.fromMap(Map data, String id)
        +Map toMap()
        +void addMember(String userId)
        +String toString()
    }

    class Task {
        +String id
        +String title
        +String description
        +String projectId
        +String assignedTo
        +String status
        +DateTime deadline
        +String assigneeName
        +String assigneeAvatar
        +bool isUrgent
        +DateTime updatedAt
        +String rejectionReason
        +int isSynced
        +static const List<String> validStatuses
        +static final Map<String, Set<String>> allowedTransitions
        +Task.fromMap(Map data, String id)
        +Map toMap()
        +Task copyWith(...)
        +bool isOverdue()
        +String toString()
    }

    class NotificationModel {
        +String id
        +String userId
        +String relatedTaskId
        +String title
        +String message
        +DateTime createdAt
        +bool isRead
        +String type
        +NotificationModel.fromMap(Map data)
        +Map toMap()
    }

    ProjectModel "1" -- "*" Task : contains
    UserModel "1" -- "*" Task : assignedTo
    ProjectModel "1" -- "*" UserModel : memberIds (N-N Logical)
    Task "1" -- "*" NotificationModel : relatedTaskId
    UserModel "1" -- "*" NotificationModel : userId

    style UserModel fill:#eef2ff,stroke:#4f46e5,stroke-width:2px
    style ProjectModel fill:#eef2ff,stroke:#4f46e5,stroke-width:2px
    style Task fill:#eef2ff,stroke:#4f46e5,stroke-width:2px
    style NotificationModel fill:#eef2ff,stroke:#4f46e5,stroke-width:2px
```

### 1.2 Generic Classes (`utils/`)

```mermaid
classDiagram
    class DataPrinter<T> {
        +T data
        +DataPrinter(T data)
        +void printData()
        +T getData()
        +void setData(T newData)
    }

    class DataListPrinter<T> {
        +List<T> dataList
        +DataListPrinter(List<T> dataList)
        +void printAllData()
        +void addData(T item)
        +List<T> getAllData()
    }

    style DataPrinter fill:#f8fafc,stroke:#64748b
    style DataListPrinter fill:#f8fafc,stroke:#64748b
```

> **Ghi chú**: Các Generic Classes này được giữ lại phục vụ cho Debug Mode và kiểm thử kiểu dữ liệu nhanh trong quá trình phát triển.

### 1.3 Repository & Services Pattern (`repositories/` & `services/`)

Sơ đồ mô tả cơ chế lưu trữ hai lớp (Local SQLite và Remote Firestore), cùng các lớp dịch vụ hạ tầng làm nhiệm vụ thao tác trực tiếp với dữ liệu:

```mermaid
classDiagram
    class SQLiteService {
        -_db Database
        +Future<Database> db
        +Future<void> cacheTask(Task task, bool isSynced)
        +Future<List<Task>> getLocalTasks(String userId)
        +Future<List<Task>> getLocalTasksByProject(String projectId)
        +Future<List<Task>> getAllLocalTasks()
        +Future<Task?> getLocalTaskById(String taskId)
        +Future<List<Task>> getUnsyncedTasks()
        +Future<void> markTaskSynced(String taskId)
        +Future<void> deleteTask(String taskId)
        +Future<void> cacheProject(ProjectModel project, bool isSynced)
        +Future<List<ProjectModel>> getLocalProjects()
        +Future<void> deleteProject(String projectId)
        +Future<List<ProjectModel>> getUnsyncedProjects()
        +Future<void> markProjectSynced(String projectId)
        +Future<void> cacheUser(UserModel user)
        +Future<List<UserModel>> getLocalUsers()
        +Future<void> cacheNotification(NotificationModel notification)
        +Future<bool> hasNotificationForTaskType(...)
        +Future<List<NotificationModel>> getLocalNotifications(String userId)
        +Future<void> markNotificationRead(String id)
        +Future<void> markAllNotificationsRead(String userId)
        +Future<void> deleteNotificationsByTaskId(String taskId)
        +Future<void> updateUserName(String userId, String newName)
        +Future<void> updateUserPassword(...)
        +Future<void> clearAllLocalData()
    }

    class FirebaseService {
        +Future<List<UserModel>> getUsers()
        +Future<UserModel?> getUserById(String id)
        +Future<void> saveUser(UserModel user)
        +Future<List<ProjectModel>> getProjects()
        +Future<void> saveProject(ProjectModel project)
        +Future<List<Task>> getTasksByProject(String projectId)
        +Future<List<Task>> getTasksByUser(String userId)
        +Future<List<Task>> getAllTasks()
        +Future<Task?> getTaskById(String taskId)
        +Future<void> saveTask(Task task)
        +Future<void> updateTaskStatus(String taskId, String status)
        +Future<void> deleteTask(String taskId)
        +Future<void> deleteProject(String projectId)
        +Future<List<ProjectModel>> getProjectsByUser(String userId)
    }

    class AuthService {
        -_sqliteService SQLiteService
        +Future<UserModel?> login(String email, String password)
        +Future<UserModel> register(...)
        +Future<void> logout()
        +Future<UserModel?> getCurrentUser()
        +Future<bool> updateName(String userId, String newName)
        +Future<bool_message> changePassword(...)
    }

    class ConnectivityService {
        +ConnectivityService instance$
        -_isOnline bool
        +bool isOnline
        +Stream<bool> onConnectivityChanged
        +Future<void> init()
        +void dispose()
    }

    class TaskRepository {
        <<abstract>>
        +Future<List<Task>> getTasks(String projectId)*
        +Future<void> addTask(Task task)*
        +Future<void> updateTask(Task task)*
        +Future<void> deleteTask(String id)*
        +Future<Map<String, int>> getStatistics(String projectId)*
        +Future<List<Task>> getUnsyncedTasks()*
        +Future<void> syncPendingTasks()*
    }

    class LocalTaskRepository {
        -SQLiteService _sqliteService
        -FirebaseService _firebaseService
        +Future<List<Task>> getTasks(String projectId)
        +Future<void> addTask(Task task)
        +Future<void> updateTask(Task task)
        +Future<void> deleteTask(String id)
        +Future<Map<String, int>> getStatistics(String projectId)
        +Future<List<Task>> getUnsyncedTasks()
        +Future<void> syncPendingTasks()
    }

    class UserRepository {
        <<abstract>>
        +Future<List<UserModel>> getUsers()*
        +Future<UserModel?> getUserById(String id)*
        +Future<void> saveUser(UserModel user)*
    }

    class LocalUserRepository {
        -SQLiteService _sqliteService
        -FirebaseService _firebaseService
        +Future<List<UserModel>> getUsers()
        +Future<UserModel?> getUserById(String id)
        +Future<void> saveUser(UserModel user)
    }

    class ProjectRepository {
        <<abstract>>
        +Future<List<ProjectModel>> getProjects()*
        +Future<void> saveProject(ProjectModel project)*
        +Future<void> deleteProject(String id)*
        +Future<List<ProjectModel>> getUnsyncedProjects()*
        +Future<void> syncPendingProjects()*
    }

    class LocalProjectRepository {
        -SQLiteService _sqliteService
        -FirebaseService _firebaseService
        +Future<List<ProjectModel>> getProjects()
        +Future<void> saveProject(ProjectModel project)
        +Future<void> deleteProject(String id)
        +Future<List<ProjectModel>> getUnsyncedProjects()
        +Future<void> syncPendingProjects()
    }

    TaskRepository <|.. LocalTaskRepository : implements
    UserRepository <|.. LocalUserRepository : implements
    ProjectRepository <|.. LocalProjectRepository : implements

    LocalTaskRepository --> SQLiteService : uses
    LocalTaskRepository --> FirebaseService : uses
    LocalUserRepository --> SQLiteService : uses
    LocalUserRepository --> FirebaseService : uses
    LocalProjectRepository --> SQLiteService : uses
    LocalProjectRepository --> FirebaseService : uses
    AuthService --> SQLiteService : uses

    style SQLiteService fill:#f0fdf4,stroke:#16a34a
    style FirebaseService fill:#fffbeb,stroke:#d97706
    style AuthService fill:#f0fdf4,stroke:#16a34a
    style ConnectivityService fill:#f0fdf4,stroke:#16a34a
    style LocalTaskRepository fill:#eef2ff,stroke:#4f46e5
    style LocalUserRepository fill:#eef2ff,stroke:#4f46e5
    style LocalProjectRepository fill:#eef2ff,stroke:#4f46e5
```

---

## 2. Use Case Diagram (Sơ đồ ca sử dụng)

```mermaid
flowchart LR
    subgraph Hệ thống TaskFlow
        UC1["Đăng nhập / Đăng ký phân quyền"]
        UC2["Xem danh sách Project"]
        UC3["Tạo Project & chọn thành viên"]
        UC4["Quản lý/Sửa thành viên dự án"]
        UC5["Kiểm tra & Cảnh báo khi xóa member (Chống Task mồ côi)"]
        UC6["Tạo Task mới & gán cho member dự án"]
        UC7["Xem toàn bộ Task trong dự án"]
        UC8["Chỉnh sửa / Gán lại Task (Manager)"]
        UC9["Cập nhật trạng thái Task được giao (Member)"]
        UC10["Phê duyệt / Từ chối công việc (Manager)"]
        UC11["Xem danh sách nhân sự"]
        UC12["Xem thống kê & Lịch biểu Calendar"]
        UC13["Đồng bộ dữ liệu ngoại tuyến (Offline Sync)"]
    end

    Manager((👔 Manager))
    Member((👤 Member))

    Manager --- UC1
    Manager --- UC2
    Manager --- UC3
    Manager --- UC4
    Manager --- UC5
    Manager --- UC6
    Manager --- UC7
    Manager --- UC8
    Manager --- UC10
    Manager --- UC11
    Manager --- UC12
    Manager --- UC13

    Member --- UC1
    Member --- UC2
    Member --- UC7
    Member --- UC9
    Member --- UC12
    Member --- UC13

    style Manager fill:#eff6ff,stroke:#1d4ed8,stroke-width:2px
    style Member fill:#f0fdf4,stroke:#16a34a,stroke-width:2px
    style UC5 fill:#fff1f2,stroke:#e11d48,stroke-width:2px
    style UC13 fill:#fffbeb,stroke:#d97706,stroke-width:2px
```

---

## 3. Activity Diagram (Sơ đồ hoạt động)

### 3.1 Luồng Đăng nhập & Phân quyền (Timeout & Offline Fallback)

```mermaid
flowchart TD
    A(["🟢 Bắt đầu"]) --> B["Mở ứng dụng"]
    B --> C{"Đã đăng nhập?"}
    C -- Chưa --> D["Hiển thị màn hình Login"]
    D --> E["Nhập email & password"]
    E --> F{"Xác thực Firebase Auth\n(Giới hạn Timeout 15s)"}
    
    F -- "Timeout / Lỗi mạng ⚠️" --> G_TIMEOUT["Hiển thị lỗi và cố gắng chuyển sang Offline Mode"]
    G_TIMEOUT --> D_LOCAL["Đọc thông tin băm mật khẩu từ local"]
    D_LOCAL --> E_LOCAL{"Mật khẩu hợp lệ ở Local?"}
    E_LOCAL -- Có --> G_ROLE["Đọc role mặc định từ Local SQLite"]
    E_LOCAL -- Không --> D
    
    F -- "Sai tài khoản ❌" --> G_AUTH["Hiển thị lỗi: 'Email hoặc mật khẩu không chính xác!'"]
    G_AUTH --> D
    
    F -- "Thành công ✅" --> H["Đọc role từ Firestore (Timeout 15s)"]
    H -- "Lỗi / Timeout ⚠️" --> G_ROLE
    
    H -- "Thành công ✅" --> I{"Role = ?"}
    G_ROLE --> I
    
    C -- Rồi --> H
    
    I -- manager --> J["Hiển thị giao diện Manager (4 Tabs + FAB)"]
    I -- member --> K["Hiển thị giao diện Member (3 Tabs, ẩn FAB)"]
    J --> L["Hiển thị Project List"]
    K --> L
    L --> M(["🔴 Kết thúc"])

    style F fill:#fffbeb,stroke:#d97706
    style G_TIMEOUT fill:#fff1f2,stroke:#e11d48
    style G_ROLE fill:#f0fdf4,stroke:#16a34a
```

### 3.2 Luồng Tạo Task (Manager - Giới hạn gán cho thành viên thuộc dự án)

```mermaid
flowchart TD
    A(["🟢 Bắt đầu"]) --> B["Manager chọn Project"]
    B --> C["Nhấn nút Tạo Task (+)"]
    C --> D["Hiển thị form tạo Task"]
    D --> E["Hệ thống lọc danh sách thành viên thuộc dự án (memberIds)"]
    E --> F["Manager nhập: title, mô tả, chọn thành viên và deadline"]
    F --> G{"Dữ liệu hợp lệ?"}
    G -- Không --> H["Hiển thị lỗi: 'Vui lòng điền đủ thông tin!'"]
    H --> D
    
    G -- Có --> CHECK_DUP{"Kiểm tra trùng Title\ntrong cùng Project?"}
    CHECK_DUP -- "Bị trùng ❌" --> G_DUP["Hiển thị lỗi: 'Tên task đã tồn tại trong dự án!'"]
    G_DUP --> D
    
    CHECK_DUP -- "Hợp lệ ✅" --> I["Tạo đối tượng Task mới (status = 'todo')"]
    I --> J["Lưu SQLite local & Sync Firestore"]
    J --> K["Cập nhật UI danh sách Task"]
    K --> L(["🔴 Kết thúc"])

    style CHECK_DUP fill:#eff6ff,stroke:#1d4ed8
    style G_DUP fill:#fff1f2,stroke:#e11d48
```

### 3.3 Luồng Cập nhật Tiến độ & Đồng bộ ngược (Optimistic UI & Auto Sync cả Project & Task khi Online)

```mermaid
flowchart TD
    START(["🟢 Bắt đầu"]) --> MEMBER_SELECT["Member chọn Task đang làm (doing)"]
    MEMBER_SELECT --> CLICK_SUBMIT["Click nút 'Nộp bài'"]
    CLICK_SUBMIT --> CONFIRM{"Xác nhận nộp?"}
    CONFIRM -- Không --> END_CANCEL(["🔴 Hủy bỏ"])
    
    CONFIRM -- Có --> UPDATE_LOCAL["Lưu SQLite: status = 'reviewing'\nisSynced = 0 (Write-Ahead)"]
    UPDATE_LOCAL --> OPTIMISTIC_UI["Rebuild UI lập tức\n(Hiển thị trạng thái 'Reviewing')"]
    
    OPTIMISTIC_UI --> CHECK_NET{"Có kết nối mạng?"}
    CHECK_NET -- Có --> PUSH_CLOUD["Đẩy lên Firebase Firestore"]
    PUSH_CLOUD --> SYNC_OK{"Firebase phản hồi OK?"}
    
    SYNC_OK -- Có --> MARK_SYNCED["Cập nhật SQLite: isSynced = 1"]
    MARK_SYNCED --> NOTIFY["Hiển thị Snackbar: 'Đã nộp bài thành công!'"]
    NOTIFY --> END_SUCCESS(["🔴 Kết thúc"])
    
    SYNC_OK -- Không --> QUEUE_SYNC["Đưa vào Retry Queue"]
    CHECK_NET -- Không --> QUEUE_SYNC
    
    QUEUE_SYNC --> QUEUE_PENDING["Cảnh báo: 'Nộp bài offline, dữ liệu sẽ tự động đồng bộ khi online!'"]
    QUEUE_PENDING --> END_SUCCESS

    style CHECK_NET fill:#fffbeb,stroke:#d97706
    style OPTIMISTIC_UI fill:#f0fdf4,stroke:#16a34a
```

### 3.4 Luồng Chỉnh sửa/Gán lại Task (Manager)

```mermaid
flowchart TD
    A(["🟢 Bắt đầu"]) --> B["Manager mở Chi tiết nhiệm vụ"]
    B --> C["Nhấn nút Sửa (Icon bút chì)"]
    C --> D["Hiển thị hộp thoại Chỉnh sửa nhiệm vụ"]
    D --> E["Hệ thống tải danh sách thành viên thuộc dự án (memberIds)"]
    E --> F["Manager thay đổi: Tiêu đề, Mô tả, Hạn chót, Người nhận việc"]
    F --> G["Nhấn Lưu lại"]
    G --> H["Lưu dữ liệu thay đổi xuống SQLite cục bộ\n(isSynced = 0, updatedAt = now)"]
    H --> I["Cập nhật giao diện chi tiết tức thì (Optimistic UI)"]
    I --> J{"Có Internet?"}
    J -- Có --> K["Gửi dữ liệu cập nhật lên Firestore"]
    K --> L["Cập nhật SQLite: isSynced = 1"]
    J -- Không --> M["Lưu hàng đợi chờ đồng bộ ngầm"]
    L --> N(["🔴 Kết thúc"])
    M --> N

    style J fill:#fffbeb,stroke:#d97706
    style H fill:#f0fdf4,stroke:#16a34a
```

### 3.5 Luồng Quản lý thành viên & Ngăn chặn "Task mồ côi" (Manager)

```mermaid
flowchart TD
    A(["🟢 Bắt đầu"]) --> B["Manager mở Quản lý thành viên dự án"]
    B --> C["Bỏ tích chọn thành viên để xóa khỏi dự án"]
    C --> D["Nhấn Lưu lại"]
    D --> E{"Thành viên bị loại bỏ\ncó Task dở dang không?\n(todo, doing, reviewing)"}
    
    E -- "Có ❌" --> F["Hiển thị AlertDialog cảnh báo\nchi tiết số lượng công việc dở dang"]
    F --> G["Chặn thao tác lưu & giữ nguyên dialog"]
    G --> H(["🔴 Kết thúc (Yêu cầu Manager chuyển giao Task trước)"])
    
    E -- "Không ✅" --> I["Cập nhật danh sách memberIds mới"]
    I --> J["Lưu SQLite local & đồng bộ Firestore"]
    J --> K["Thông báo thành công & đóng dialog"]
    K --> L(["🟢 Hoàn tất"])

    style E fill:#fff1f2,stroke:#e11d48
    style F fill:#fff1f2,stroke:#e11d48
```

---

## 4. Sequence Diagram (Sơ đồ tuần tự)

### 4.1 Cập nhật trạng thái Task (Member nộp bài)

```mermaid
sequenceDiagram
    actor Member
    participant Screen as TaskDetailScreen
    participant Provider as TaskProvider
    participant Repo as TaskRepository
    participant Task as Task

    Member->>Screen: Nhấn nút nộp bài "GỬI DUYỆT 📤"
    Screen->>Provider: updateTaskStatus(taskId, "reviewing")
    
    alt Kiểm tra logic cập nhật (doing -> reviewing)
        Provider->>Task: allowedTransitions["doing"] contains "reviewing"?
        Task-->>Provider: Valid (true)
        Provider->>Repo: updateTask(task)
        Repo->>Repo: Ghi SQLite local (isSynced = 0)
        Provider-->>Screen: Success (rebuild UI)
        Screen->>Screen: setState() -> Optimistic UI rebuild
        Screen-->>Member: Hiển thị Snackbar: "Đã gửi duyệt thành công!"
    else Sai quy trình chuyển đổi trạng thái (ví dụ: todo -> reviewing)
        Provider->>Task: allowedTransitions["todo"] contains "reviewing"?
        Task-->>Provider: Invalid (false)
        Provider-->>Screen: Exception / Error
        Screen-->>Member: Hiển thị Dialog thông báo lỗi
    end
```

### 4.2 Luồng Repository Pattern (Offline Fallback & Error Handling)

```mermaid
sequenceDiagram
    actor User
    participant UI as ProjectTaskListScreen
    participant Repo as TaskRepository
    participant SQLite as SQLiteService
    participant Cloud as FirebaseService

    User->>UI: Mở dự án xem danh sách Task
    UI->>Repo: getTasks(projectId)
    
    alt Có mạng
        Repo->>Cloud: getTasksByProject(projectId)
        alt Fetch thành công
            Cloud-->>Repo: List<Task> (từ server)
            Repo->>SQLite: cacheTask() (Cập nhật cache SQLite local)
            Repo-->>UI: List<Task>
            UI-->>User: Hiển thị danh sách task cập nhật mới nhất
        else Lỗi kết nối server / Timeout (15 giây)
            Cloud-->>Repo: Timeout / Exception
            Repo->>SQLite: getLocalTasksByProject(projectId)
            SQLite-->>Repo: List<Task> (cũ từ SQLite cache)
            Repo-->>UI: List<Task>
            UI-->>User: Hiển thị danh sách cũ kèm cảnh báo kết nối ngoại tuyến
        end
    else Không có mạng
        Repo->>SQLite: getLocalTasksByProject(projectId)
        SQLite-->>Repo: List<Task>
        Repo-->>UI: List<Task>
        UI-->>User: Hiển thị danh sách kèm nhãn Offline
    end
```

### 4.3 Luồng Khôi phục kết nối mạng (Auto Sync cả Project & Task)

```mermaid
sequenceDiagram
    participant Conn as ConnectivityProvider
    participant Main as main.dart (onBackOnline)
    participant ProjProv as ProjectProvider
    participant TaskProv as TaskProvider
    participant Cloud as Cloud Firestore
    participant Local as Local SQLite

    Conn->>Main: Mạng khôi phục (offline -> online)
    
    par Đồng bộ Projects
        Main->>ProjProv: syncPending()
        ProjProv->>Local: Tìm dự án isSynced = 0
        Local-->>ProjProv: Danh sách dự án chưa sync
        ProjProv->>Cloud: Đẩy các dự án lên Firestore
        Cloud-->>ProjProv: Phản hồi thành công
        ProjProv->>Local: Cập nhật isSynced = 1
    and Đồng bộ Tasks
        Main->>TaskProv: syncPending()
        TaskProv->>Local: Tìm các task isSynced = 0
        Local-->>TaskProv: Danh sách tasks chưa sync
        TaskProv->>Cloud: Đẩy các tasks lên Firestore
        Cloud-->>TaskProv: Phản hồi thành công
        TaskProv->>Local: Cập nhật isSynced = 1
    end
```

### 4.4 Luồng kiểm tra ràng buộc trước khi xóa thành viên dự án

```mermaid
sequenceDiagram
    actor Manager
    participant UI as ProjectTaskScreen (Dialog)
    participant TaskProv as TaskProvider
    participant ProjProv as ProjectProvider

    Manager->>UI: Bỏ chọn thành viên & nhấn Lưu
    UI->>TaskProv: Lấy tasks của dự án hiện tại (taskProvider.tasks)
    UI->>UI: Lọc tasks dở dang (todo, doing, reviewing) của thành viên bị xóa
    
    alt Có task chưa hoàn thành
        UI-->>Manager: Hiển thị AlertDialog cảnh báo & chặn Lưu
    else Không có task chưa hoàn thành
        UI->>ProjProv: updateProject(project)
        ProjProv-->>UI: Cập nhật thành công
        UI-->>Manager: Đóng dialog & hiển thị Snackbar thành công
    end
```

---

## 5. Sơ đồ Kiến trúc Hệ thống

```mermaid
flowchart TB
    subgraph UI["🖥 UI Layer (Screens & Dialogs)"]
        S0["SplashScreen"]
        S1["LoginScreen"]
        S1a["RegisterScreen"]
        S2["MainScreen (Container Navigation)"]
        S3["HomeScreen (Overview Tab)"]
        S4["ProjectListScreen (Project Tab)"]
        S5["ProjectTaskListScreen (Kanban/List/Calendar)"]
        S6["TaskDetailScreen (Status Matrix & Edit Dialog)"]
        S7["UserListScreen (Team Tab)"]
        S8["MemberTasksScreen (Individual Details)"]
        S9["ProfileScreen (Settings Tab)"]
    end

    subgraph State["⚙ State Layer (Providers)"]
        P1["AuthProvider"]
        P2["ProjectProvider"]
        P3["TaskProvider"]
        P4["NotificationProvider"]
        P5["ConnectivityProvider"]
    end

    subgraph Repo["🔌 Repository Layer"]
        R1["TaskRepository (Interface)"]
        R2["LocalTaskRepository (Implements)"]
        R3["UserRepository (Interface)"]
        R4["LocalUserRepository (Implements)"]
        R5["ProjectRepository (Interface)"]
        R6["LocalProjectRepository (Implements)"]
    end

    subgraph Serv["📡 Services Layer"]
        SV1["AuthService (Auth Logic)"]
        SV2["SQLiteService (Local Cache)"]
        SV3["FirebaseService (Remote Cloud)"]
        SV4["ConnectivityService (Network Monitor)"]
    end

    subgraph Storage["💾 Storage Data Layer"]
        FB["Firebase Firestore (Remote)"]
        SQ["SQLite - sqflite (Local Database)"]
        FA["Firebase Auth (Authentication API)"]
    end

    UI --> State
    State --> Repo
    State --> SV1
    State --> SV4
    Repo --> SV2
    Repo --> SV3
    SV1 --> SV2
    SV3 --> FB
    SV2 --> SQ
    SV1 --> FA
    SV4 --> SV4_PL["connectivity_plus API"]

    style UI fill:#eff6ff,stroke:#1d4ed8
    style State fill:#f0fdf4,stroke:#16a34a
    style Repo fill:#faf5ff,stroke:#7c3aed
    style Serv fill:#fffbeb,stroke:#d97706
    style Storage fill:#fff1f2,stroke:#e11d48
```

---

## 6. Sơ đồ Quan hệ Dữ liệu (ERD)

### 6.1 Bảng SQLite Local (Phiên bản Cơ sở dữ liệu 7)

```mermaid
erDiagram
    users_local {
        TEXT id PK "Firebase UID"
        TEXT name "Tên người dùng"
        TEXT email "Email đăng nhập"
        TEXT role "manager / member"
        TEXT offlineAuthHash "Mật khẩu băm dùng cho offline"
        TEXT avatarChar "Avatar ký tự đại diện"
    }

    projects_local {
        TEXT id PK "ID dự án"
        TEXT name "Tên dự án"
        TEXT description "Mô tả dự án"
        TEXT memberIds "Danh sách ID thành viên (ngăn cách bằng dấu phẩy)"
        TEXT syncedAt "Thời gian đồng bộ lên Cloud gần nhất"
        INTEGER isSynced "Cờ đồng bộ: 0-pending, 1-synced"
        TEXT updatedAt "Thời điểm cập nhật gần nhất"
    }

    tasks_local {
        TEXT id PK "ID nhiệm vụ"
        TEXT title "Tiêu đề công việc"
        TEXT description "Mô tả công việc"
        TEXT projectId FK "projects_local(id) ON DELETE CASCADE"
        TEXT assignedTo "ID người thực hiện (Logical FK)"
        TEXT status "todo / doing / reviewing / done / cancelled / archived"
        TEXT deadline "Thời hạn hoàn thành (ISO string)"
        TEXT syncedAt "Thời điểm đồng bộ lên Cloud"
        TEXT assigneeName "Tên Snapshot của người thực hiện"
        TEXT assigneeAvatar "Avatar Snapshot của người thực hiện"
        INTEGER isUrgent "Cờ khẩn cấp: 0-không, 1-có"
        TEXT updatedAt "Thời điểm cập nhật gần nhất"
        INTEGER isSynced "Cờ đồng bộ: 0-pending, 1-synced"
        TEXT rejectionReason "Lý do từ chối phê duyệt"
    }

    notifications_local {
        TEXT id PK "ID thông báo"
        TEXT userId "ID người dùng nhận (Logical FK)"
        TEXT relatedTaskId "ID Task liên quan (Logical FK)"
        TEXT title "Tiêu đề thông báo"
        TEXT message "Nội dung chi tiết"
        TEXT createdAt "Thời điểm tạo thông báo"
        INTEGER isRead "Cờ đã đọc: 0-chưa, 1-đã đọc"
        TEXT type "Loại thông báo"
    }

    users_local ||--o{ tasks_local : "assignedTo"
    projects_local ||--o{ tasks_local : "projectId"
    tasks_local ||--o{ notifications_local : "relatedTaskId"
    users_local ||--o{ notifications_local : "userId"
    users_local }o--o{ projects_local : "memberIds (Logical Relation)"
```

### 6.2 Cấu trúc Cloud Firestore (Remote NoSQL)

```mermaid
erDiagram
    users_firestore {
        string uid PK "Document ID"
        string name
        string email
        string role
        string avatarChar
    }

    projects_firestore {
        string id PK "Document ID"
        string name
        string description
        array memberIds "Danh sách UIDs"
        string updatedAt "ISO string"
    }

    tasks_firestore {
        string id PK "Document ID"
        string title
        string description
        string projectId "ID Project liên kết"
        string assignedTo "ID User liên kết"
        string status "todo/doing/reviewing/done/cancelled/archived"
        string deadline "ISO string"
        string assigneeName
        string assigneeAvatar
        boolean isUrgent
        string updatedAt "ISO string"
        string rejectionReason
    }

    users_firestore ||--o{ tasks_firestore : "assignedTo"
    projects_firestore ||--o{ tasks_firestore : "projectId"
    users_firestore ||--o{ projects_firestore : "memberIds"
```

---

## 7. State Diagram – Trạng thái Task

Sơ đồ chuyển trạng thái chặt chẽ theo thiết kế State Machine định nghĩa trong code `Task.allowedTransitions`:

```mermaid
stateDiagram-v2
    [*] --> todo : Tạo Task mới (Manager)
    todo --> doing : Member nhận việc (Bắt đầu làm)
    doing --> reviewing : Member nộp bài (Gửi duyệt)
    doing --> todo : Member trả lại / Hoàn tác
    reviewing --> done : Manager duyệt hoàn thành ✅
    reviewing --> todo : Manager từ chối (yêu cầu sửa lại) ❌
    done --> archived : Manager lưu trữ
    todo --> cancelled : Manager hủy bỏ nhiệm vụ
    doing --> cancelled : Manager hủy bỏ nhiệm vụ
    reviewing --> cancelled : Manager hủy bỏ nhiệm vụ

    state todo {
        [*] --> ToDoState
    }
    state doing {
        [*] --> DoingState
    }
    state reviewing {
        [*] --> ReviewingState
    }
    state done {
        [*] --> DoneState
    }

    style todo fill:#fee2e2,stroke:#ef4444
    style doing fill:#fef3c7,stroke:#f59e0b
    style reviewing fill:#dbeafe,stroke:#3b82f6
    style done fill:#dcfce7,stroke:#10b981
```

---

## 8. Sơ đồ Điều hướng Màn hình (Navigation Flow)

```mermaid
flowchart TD
    SPLASH(["🎬 SplashScreen"]) --> LOGIN["🔐 LoginScreen"]
    LOGIN --> REGISTER["📝 RegisterScreen"]
    REGISTER -->|Back| LOGIN
    
    LOGIN --> |"Đăng nhập thành công"| ROLE_DECISION{"Phân loại Role?"}
    
    ROLE_DECISION -->|Manager| MGR_DASHBOARD["📱 Manager Navigation Dashboard\n(Floating Bottom Nav Bar - 4 Tabs + FAB)"]
    ROLE_DECISION -->|Member| MEM_DASHBOARD["📱 Member Navigation Dashboard\n(Floating Bottom Nav Bar - 3 Tabs)"]
    
    %% Manager Navigation
    subgraph Manager Navigation (4 Tabs + FAB)
        MGR_DASHBOARD --> MGR_TAB0["🏠 HomeScreen\n(Thống kê & Thẻ duyệt việc nhanh)"]
        MGR_DASHBOARD --> MGR_TAB1["🗂 ProjectListScreen\n(Manager Mode - Tạo/Xóa dự án)"]
        MGR_DASHBOARD --> MGR_FAB["⚡ Nút FAB (+)\n(Tạo việc mới nhanh)"]
        MGR_DASHBOARD --> MGR_TAB2["👥 UserListScreen\n(Danh sách nhân sự & xem thống kê task)"]
        MGR_DASHBOARD --> MGR_TAB3["👤 ProfileScreen\n(Thông tin tài khoản & đăng xuất)"]
        
        MGR_TAB1 -->|"Tap Project"| MGR_TASK_LIST["📋 ProjectTaskListScreen\n(Chế độ Danh sách / Kanban / Lịch biểu)"]
        MGR_TASK_LIST -->|"Manage Members"| MGR_MEMBER_DIALOG["👥 Manage Members Dialog\n(Tích chọn thành viên, có chặn task dở dang)"]
        MGR_TASK_LIST -->|"Tap Task"| TASK_DETAIL["🔍 TaskDetailScreen\n(Manager Mode)"]
        
        TASK_DETAIL -->|"Edit"| EDIT_TASK_DIALOG["✏️ EditTaskDialog\n(Sửa tiêu đề, mô tả, deadline, gán lại)"]
        MGR_TAB2 -->|"Tap Member"| MEMBER_TASKS["📋 MemberTasksScreen\n(Xem chi tiết các task của thành viên)"]
    end
    
    %% Member Navigation
    subgraph Member Navigation (3 Tabs)
        MEM_DASHBOARD --> MEM_TAB0["🏠 HomeScreen\n(Task khẩn cấp & thống kê cá nhân)"]
        MEM_DASHBOARD --> MEM_TAB1["🗂 ProjectListScreen\n(Member Mode)"]
        MEM_DASHBOARD --> MEM_TAB2["👤 ProfileScreen"]
        
        MEM_TAB1 -->|"Tap Project"| MEM_TASK_LIST["📋 ProjectTaskListScreen\n(Xem toàn bộ task của dự án)"]
        MEM_TASK_LIST -->|"Tap Task"| MEM_TASK_DETAIL["🔍 TaskDetailScreen\n(Member Mode)"]
    end
    
    %% Back Stack pops
    TASK_DETAIL -->|"Back"| MGR_TASK_LIST
    MGR_TASK_LIST -->|"Back"| MGR_TAB1
    MEMBER_TASKS -->|"Back"| MGR_TAB2
    MEM_TASK_DETAIL -->|"Back"| MEM_TASK_LIST
    MEM_TASK_LIST -->|"Back"| MEM_TAB1
    
    MGR_TAB3 -->|"Đăng xuất"| LOGIN
    MEM_TAB2 -->|"Đăng xuất"| LOGIN
    
    style SPLASH fill:#9e9e9e,color:#fff
    style LOGIN fill:#f44336,color:#fff
    style ROLE_DECISION fill:#9c27b0,color:#fff
    style MGR_DASHBOARD fill:#3b82f6,color:#fff
    style MEM_DASHBOARD fill:#10b981,color:#fff
    style MGR_FAB fill:#6366f1,color:#fff
```

---

## 9. Sơ đồ Chiến lược Lưu trữ Kép (Dual Storage)

### 9.1 Luồng Đọc Dữ liệu (Read Data Flow) - Cache Invalidation

```mermaid
flowchart TD
    START("App Load / Refresh") --> CONNECTIVITY{Kết nối Internet?}
    
    CONNECTIVITY -- "Có" --> FETCH["Gọi API Firestore lấy tài liệu\n+ timestamps cập nhật"]
    FETCH --> COMPARE{So sánh thời gian}
    
    COMPARE -- "Server updatedAt > Local cachedAt" --> UPDATE_UI["Ghi đè SQLite\n+ Rebuild UI"]
    UPDATE_UI --> OFFLINE_ICON["☁️ Biểu tượng: Đã sync đám mây"]
    
    COMPARE -- "Server = Local (không đổi)" --> SKIP["Đọc trực tiếp SQLite\n(Tránh tải thừa)"]
    
    CONNECTIVITY -- "Không" --> LOAD_LOCAL["Đọc dữ liệu từ SQLite\n+ hiển thị ngay"]
    LOAD_LOCAL --> OFFLINE_ICON_LATE["⚠️ Biểu tượng: OFFLINE\nDữ liệu offline"]
    
    OFFLINE_ICON --> END["✅ Hoàn tất"]
    OFFLINE_ICON_LATE --> END
    SKIP --> END
    
    style COMPARE fill:#fffbeb,stroke:#d97706
    style OFFLINE_ICON_LATE fill:#fff1f2,stroke:#e11d48
    style OFFLINE_ICON fill:#f0fdf4,stroke:#16a34a
```

### 9.2 Luồng Ghi Dữ liệu (Write Data Flow) - Write-Ahead Logging & Optimistic UI

```mermaid
flowchart TD
    START["Người dùng thực hiện Ghi / Sửa"] --> LOCAL["SQLite ghi dữ liệu mới\n(gán isSynced = 0, updatedAt = now)"]
    LOCAL --> SUCCESS_LOCAL{SQLite phản hồi?}
    
    SUCCESS_LOCAL -- "Thất bại ❌" --> ERROR_SHOW["Thông báo lỗi ngay lập tức"]
    ERROR_SHOW --> END_ERR["🔴 Kết thúc"]
    
    SUCCESS_LOCAL -- "Thành công ✅" --> UI["Rebuild giao diện lập tức\n(Optimistic UI)"]
    UI --> TRY_SYNC{Kiểm tra Internet}
    
    TRY_SYNC -- "Có mạng" --> FIRESTORE["Đẩy tài liệu lên Firestore"]
    FIRESTORE --> CHECK_SERVER{Firestore phản hồi?}
    
    CHECK_SERVER -- "Thất bại ❌" --> QUEUE["Giữ nguyên isSynced = 0\nxử lý trong hàng đợi retry"]
    QUEUE --> RETRY_TIMER["Đợi khôi phục kết nối mạng"]
    
    CHECK_SERVER -- "Thành công ✅" --> MARK_SYNC["Cập nhật SQLite: isSynced = 1\n(updatedAt đồng bộ với Server)"]
    MARK_SYNC --> FINAL["✅ Hoàn thành"]
    
    TRY_SYNC -- "Mất mạng" --> QUEUE
    
    style LOCAL fill:#f0fdf4,stroke:#16a34a
    style QUEUE fill:#fffbeb,stroke:#d97706
```

### 9.3 Luồng Đồng bộ Ngầm (Background Sync)

```mermaid
flowchart TD
    START(["⏰ Lắng nghe thay đổi kết nối\nhoặc Timer kích hoạt"]) --> CONNECTIVITY{Kết nối\nInternet?}
    
    CONNECTIVITY -- "Không ❌" --> WAIT(["😴 Tiếp tục chờ\n(Đợi sự kiện Network phục hồi)"])
    WAIT --> START
    
    CONNECTIVITY -- "Có ✅" --> GET_PENDING["Lấy danh sách các bản ghi chưa sync\n(isSynced = 0) từ SQLite"]
    GET_PENDING --> LOOP{Lặp từng bản ghi}
    
    LOOP --> UPLOAD["Đẩy dữ liệu lên\nCloud Firestore"]
    UPLOAD --> CHECK_ERR{Có lỗi xảy ra?}
    
    CHECK_ERR -- "Có ❌" --> LOG_ERR["Ghi log lỗi hệ thống\n+ Chuyển bản ghi sau"]
    CHECK_ERR -- "Không ✅" --> MARK_OK["Cập nhật SQLite: isSynced = 1\nsyncedAt = DateTime.now()"]
    
    MARK_OK --> LOOP
    LOG_ERR --> LOOP
    
    LOOP -- "Hết dữ liệu" --> DONE(["✅ Đồng bộ\nHoàn tất"])
    
    style START fill:#faf5ff,stroke:#7c3aed
    style DONE fill:#f0fdf4,stroke:#16a34a
```

### 9.4 Luồng Xử lý Xung đột Đồng bộ (Sync Conflict Resolution) - Triple Conflict Merge

```mermaid
flowchart TD
    START["Đồng bộ Batch dữ liệu"] --> FETCH["Đọc bản ghi tương ứng từ\nSQLite (Local) & Firestore (Server)"]
    FETCH --> FOR_EACH{Lặp từng bản ghi}
    
    FOR_EACH --> COMPARE{So sánh các trường hợp}
    
    CASE_1[Sửa ở Local + Server không có] --> PUSH["☁️ Đẩy Local lên Server"]
    
    CASE_2[Server có sửa + Local không có] --> PULL["📥 Kéo Server về ghi đè Local"]
    
    CASE_3[Local.updatedAt > Server.updatedAt] --> PUSH
    
    CASE_4[Server.updatedAt > Local.updatedAt] --> PULL
    
    CASE_5{Sửa cùng thời điểm\nnhưng khác dữ liệu?} --> CONFLICT[⚠️ XUNG ĐỘT\nTầng dữ liệu]
    CONFLICT --> USER_CHOOSE["🤔 Lựa chọn xử lý:\nGiữ bản Local / Đè bản Server"]
    
    USER_CHOOSE --> PUSH
    USER_CHOOSE --> PULL
    
    PUSH --> MARK["Đánh dấu isSynced = 1"]
    PULL --> MARK
    
    MARK --> MORE{Còn bản ghi?}
    MORE -- "Có" --> FOR_EACH
    MORE -- "Không" --> END["✅ Kết thúc đồng bộ"]
    
    style CONFLICT fill:#fff1f2,stroke:#e11d48
    style USER_CHOOSE fill:#fffbeb,stroke:#d97706
```

---

## 10. Sơ đồ Provider – Quản lý Trạng thái

```mermaid
classDiagram
    class AuthProvider {
        -AuthService _authService
        -UserModel? _currentUser
        +UserModel? currentUser
        +bool isAuthenticated
        +Future<bool> login(String email, String password)
        +Future<void> register(...)
        +Future<void> logout()
        +Future<void> checkCurrentUser()
        +Future<bool> updateName(String newName)
        +Future<bool_message> changePassword(...)
    }

    class ProjectProvider {
        -ProjectRepository _projectRepo
        -UserRepository _userRepo
        -List<ProjectModel> _projects
        -List<UserModel> _allUsers
        +List<ProjectModel> projects
        +List<UserModel> allUsers
        +Future<void> loadProjects()
        +Future<void> loadAllUsers()
        +Future<void> createProject(String name, String desc, List<String> memberIds)
        +Future<void> updateProject(ProjectModel project)
        +Future<void> deleteProject(String projectId)
        +Future<void> syncPending()
    }

    class TaskProvider {
        -TaskRepository _taskRepo
        -ProjectRepository _projectRepo
        -List<Task> _tasks
        -Map<String, Map<String, int>> _projectStats
        +List<Task> tasks
        +Map<String, Map<String, int>> projectStats
        +Future<void> loadTasksByProject(String projectId)
        +Future<void> loadMyTasks(String userId)
        +Future<void> createTask(Task task)
        +Future<void> editTask(Task task)
        +Future<void> updateTaskStatus(String taskId, String newStatus)
        +Future<void> approveTask(String taskId)
        +Future<void> rejectTask(String taskId, String reason)
        +Future<void> syncPending()
    }

    class NotificationProvider {
        -SQLiteService _sqliteService
        -List<NotificationModel> _notifications
        +List<NotificationModel> notifications
        +Future<void> loadNotifications(String userId)
        +Future<void> addNotification(NotificationModel notification)
        +Future<void> markAsRead(String id)
        +Future<void> markAllAsRead(String userId)
    }

    class ConnectivityProvider {
        -ConnectivityService _connectivityService
        -bool _isOnline
        -VoidCallback? _onBackOnline
        +bool isOnline
        +void init(VoidCallback onBackOnline)
        +void updateSyncCallback(VoidCallback callback)
    }

    ChangeNotifier <|-- AuthProvider
    ChangeNotifier <|-- ProjectProvider
    ChangeNotifier <|-- TaskProvider
    ChangeNotifier <|-- NotificationProvider
    ChangeNotifier <|-- ConnectivityProvider

    style AuthProvider fill:#eef2ff,stroke:#4f46e5
    style ProjectProvider fill:#eef2ff,stroke:#4f46e5
    style TaskProvider fill:#eef2ff,stroke:#4f46e5
    style NotificationProvider fill:#eef2ff,stroke:#4f46e5
    style ConnectivityProvider fill:#eef2ff,stroke:#4f46e5
```

---

## 11. Cấu trúc Điều hướng Bottom Navigation Bar & Tổ chức các Màn hình

Ứng dụng TaskFlow tổ chức luồng giao diện thông qua một màn hình khung chính (**MainScreen**) đóng vai trò làm Router cục bộ và quản lý trạng thái điều hướng đa nhiệm qua **Bottom Navigation Bar**.

### 11.1 Cấu trúc Thanh điều hướng nổi (Floating Bottom Navigation Bar)

Thanh Bottom Navigation được thiết kế theo dạng **Floating Glassmorphism** (Thanh nổi bo tròn, phủ kính mờ) nằm cách đáy màn hình `24px` để tăng tính hiện đại và cao cấp cho giao diện.

- **Đặc trưng phân quyền (Role-Based Tabs)**:
  - **Manager (Quản trị viên)**: Hiển thị **4 Tabs** + **1 Nút FAB (+)** nổi bật ở giữa:
    - Tab 0: Trang chủ (`HomeScreen`)
    - Tab 1: Dự án (`ProjectListScreen`)
    - [Center]: Nút **FAB (+)** thêm nhiệm vụ nhanh (`FloatingActionButton` ở vị trí `centerDocked`)
    - Tab 2: Nhóm (`UserListScreen`)
    - Tab 3: Hồ sơ (`ProfileScreen`)
  - **Member (Thành viên)**: Hiển thị **3 Tabs** và **ẨN HOÀN TOÀN** nút FAB (+) ở giữa:
    - Tab 0: Trang chủ (`HomeScreen`)
    - Tab 1: Dự án (`ProjectListScreen`)
    - Tab 2: Hồ sơ (`ProfileScreen`)

### 11.2 Sơ đồ Điều hướng và Chuyển trang (Main Navigation Flow)

Dưới đây là sơ đồ Mermaid mô tả luồng điều hướng hoạt động trong `MainScreen`:

```mermaid
flowchart TD
    START(["👤 Đăng nhập vào App"]) --> CHECK_ROLE{Kiểm tra vai trò\ncurrentUser.role}
    
    CHECK_ROLE -- "isManager = true 👑" --> BUILD_MANAGER_SHELL["🏗️ Render MainScreen (Manager)\n- Hiện 4 Tabs\n- Hiện FAB (+) ở centerDocked"]
    CHECK_ROLE -- "isManager = false 👥" --> BUILD_MEMBER_SHELL["🏗️ Render MainScreen (Member)\n- Hiện 3 Tabs\n- Ẩn FAB (+)"]

    subgraph Manager Navigation Tabs
        BUILD_MANAGER_SHELL --> M_TAB0["Tab 0: Trang chủ\nHomeScreen\n(Tổng quan nhóm & duyệt việc nhanh)"]
        BUILD_MANAGER_SHELL --> M_TAB1["Tab 1: Dự án\nProjectListScreen\n(Quản trị dự án & xem việc)"]
        BUILD_MANAGER_SHELL --> M_FAB["⚡ Nút FAB (+)\n(Tạo việc mới gán cho thành viên)"]
        BUILD_MANAGER_SHELL --> M_TAB2["Tab 2: Thành viên\nUserListScreen\n(Danh sách nhân sự & thống kê task)"]
        BUILD_MANAGER_SHELL --> M_TAB3["Tab 3: Hồ sơ\nProfileScreen\n(Thông tin tài khoản & đăng xuất)"]
    end

    subgraph Member Navigation Tabs
        BUILD_MEMBER_SHELL --> MEM_TAB0["Tab 0: Trang chủ\nHomeScreen\n(Việc đang làm & tiến độ cá nhân)"]
        BUILD_MEMBER_SHELL --> MEM_TAB1["Tab 1: Dự án\nProjectListScreen\n(Xem dự án tham gia & nhận việc)"]
        BUILD_MEMBER_SHELL --> MEM_TAB2["Tab 2: Hồ sơ\nProfileScreen\n(Thông tin cá nhân)"]
    end

    style M_FAB fill:#5b5fef,color:#fff,stroke-width:2px
    style START fill:#10b981,color:#fff
```

### 11.3 Danh sách Tổ chức các Màn hình Chính (Screen Hierarchy)

Toàn bộ các màn hình chính nằm dưới thư mục `lib/screens/` và được tổ chức một cách khoa học:

| Tên màn hình | Đường dẫn file | Vai trò chính trong hệ thống | Phân quyền hiển thị |
| :--- | :--- | :--- | :--- |
| **Login Screen** | [login_screen.dart](file:///d:/Workspace/TBDD/TaskFlow_Huong_Thuong_Cuong_N03_1_2026/lib/screens/login_screen.dart) | Màn hình xác thực đăng nhập, tích hợp xử lý ngoại tuyến. | Tất cả người dùng |
| **Register Screen** | [register_screen.dart](file:///d:/Workspace/TBDD/TaskFlow_Huong_Thuong_Cuong_N03_1_2026/lib/screens/register_screen.dart) | Đăng ký tài khoản mới, cho phép chọn vai trò Manager/Member. | Khách vãng lai |
| **Main Screen** | [main_screen.dart](file:///d:/Workspace/TBDD/TaskFlow_Huong_Thuong_Cuong_N03_1_2026/lib/screens/main_screen.dart) | Khung sườn điều hướng chung, chứa Floating Bottom NavBar. | Tất cả người dùng |
| **Home Screen** | [home_screen.dart](file:///d:/Workspace/TBDD/TaskFlow_Huong_Thuong_Cuong_N03_1_2026/lib/screens/home_screen.dart) | Giao diện tổng quan & thẻ duyệt nhanh / task khẩn cấp. | Tất cả người dùng |
| **Project List Screen** | [project_list_screen.dart](file:///d:/Workspace/TBDD/TaskFlow_Huong_Thuong_Cuong_N03_1_2026/lib/screens/project_list_screen.dart) | Xem danh sách dự án. Manager có quyền Tạo/Xóa dự án. | Tất cả người dùng |
| **Project Task Screen** | [project_task_screen.dart](file:///d:/Workspace/TBDD/TaskFlow_Huong_Thuong_Cuong_N03_1_2026/lib/screens/project_task_screen.dart) | Hiển thị chi tiết tất cả đầu việc (Kanban/Calendar). Có tính năng Quản lý thành viên. | Tất cả người dùng |
| **User List Screen** | [user_list_screen.dart](file:///d:/Workspace/TBDD/TaskFlow_Huong_Thuong_Cuong_N03_1_2026/lib/screens/user_list_screen.dart) | Danh sách thành viên phục vụ giao việc và theo dõi hiệu suất. | **Chỉ Manager** |
| **Member Tasks Screen** | [member_tasks_screen.dart](file:///d:/Workspace/TBDD/TaskFlow_Huong_Thuong_Cuong_N03_1_2026/lib/screens/member_tasks_screen.dart) | Xem chi tiết danh sách nhiệm vụ đã gán của một thành viên. | **Chỉ Manager** |
| **Profile Screen** | [profile_screen.dart](file:///d:/Workspace/TBDD/TaskFlow_Huong_Thuong_Cuong_N03_1_2026/lib/screens/profile_screen.dart) | Xem thông tin tài khoản cá nhân, đổi trạng thái và đăng xuất. | Tất cả người dùng |
