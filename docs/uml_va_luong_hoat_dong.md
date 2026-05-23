# UML & Luồng Hoạt Động – Dự án TaskFlow (Bản Kỹ Thuật Chi Tiết)

> Cập nhật: 2026-04-26 – Đồng bộ hoàn toàn với mã nguồn nâng cao  
> CRUD thực tế nằm trong `repositories/`, Models thuần trong `models/`

---

## 1. Class Diagram (Sơ đồ lớp)

### 1.1 Data Models (`models/`)

```mermaid
classDiagram
    class UserModel {
        +String id
        +String name
        +String email
        +String role
        +UserModel.fromMap(Map data, String id)
        +Map toMap()
        +bool isManager
        +String toString()
    }

    class ProjectModel {
        +String id
        +String name
        +String description
        +List~String~ memberIds
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
        +DateTime updatedAt
        +String timeRemaining
        +static const Map validTransitions
        +Task.fromMap(Map data, String id)
        +Map toMap()
        +Future~bool~ updateStatus(String newStatus)
        +bool isOverdue()
        +String toString()
    }

    ProjectModel "1" -- "0..*" Task : contains
    UserModel "1" -- "0..*" Task : assignedTo
    ProjectModel "1" -- "0..*" UserModel : memberIds
```

### 1.2 Generics Classes (`utils/`)

```mermaid
classDiagram
    class DataPrinter~T~ {
        +T data
        +DataPrinter(T data)
        +void printData()
        +T getData()
        +void setData(T newData)
    }

    class DataListPrinter~T~ {
        +List~T~ dataList
        +DataListPrinter(List~T~ dataList)
        +void printAllData()
        +void addData(T item)
        +List~T~ getAllData()
    }
```

> **Ghi chú**: Các Generic Classes này được giữ lại phục vụ cho Debug Mode và kiểm thử kiểu dữ liệu nhanh trong quá trình phát triển.

### 1.3 Repository Pattern (`repositories/`)

```mermaid
classDiagram
    class TaskRepository {
        <<abstract>>
        +Future~List~Task~~ getTasks()*
        +Future~void~ addTask(Task task)*
        +Future~void~ updateTask(Task task)*
        +Future~void~ deleteTask(String id)*
        +Future~Map~String,int~~ getStatistics()*
        +Future~List~Task~~ searchTasks(String query)*
        +Future~List~Task~~ filterTasksByStatus(String status)*
    }

    class LocalTaskRepository {
        -SqliteService _sqliteService
        -FirebaseService _firebaseService
        +Future~List~Task~~ getTasks()
        +Future~void~ addTask(Task task)
        +Future~void~ updateTask(Task task)
        +Future~void~ deleteTask(String id)
        +Future~Map~String,int~~ getStatistics()
        +Future~List~Task~~ searchTasks(String query)
        +Future~List~Task~~ filterTasksByStatus(String status)
    }

    TaskRepository <|.. LocalTaskRepository : implements
    LocalTaskRepository --> Task : sử dụng

    class UserRepository {
        <<abstract>>
        +Future~List~UserModel~~ getUsers()*
        +Future~UserModel?~ getUserById(String id)*
        +Future~void~ addUser(UserModel user)*
        +Future~void~ updateUser(UserModel user)*
        +Future~void~ deleteUser(String id)*
        +Future~Map~String,int~~ getStatistics()*
    }

    class LocalUserRepository {
        -SqliteService _sqliteService
        -FirebaseService _firebaseService
        +Future~List~UserModel~~ getUsers()
        +Future~UserModel?~ getUserById(String id)
        +Future~void~ addUser(UserModel user)
        +Future~void~ updateUser(UserModel user)
        +Future~void~ deleteUser(String id)
        +Future~Map~String,int~~ getStatistics()
    }

    UserRepository <|.. LocalUserRepository : implements

    class ProjectRepository {
        <<abstract>>
        +Future~List~ProjectModel~~ getProjects()*
        +Future~ProjectModel?~ getProjectById(String id)*
        +Future~void~ addProject(ProjectModel project)*
        +Future~void~ updateProject(ProjectModel project)*
        +Future~void~ deleteProject(String id)*
        +Future~Map~String,int~~ getStatistics()*
    }

    class LocalProjectRepository {
        -SqliteService _sqliteService
        -FirebaseService _firebaseService
        +Future~List~ProjectModel~~ getProjects()
        +Future~ProjectModel?~ getProjectById(String id)
        +Future~void~ addProject(ProjectModel project)
        +Future~void~ updateProject(ProjectModel project)
        +Future~void~ deleteProject(String id)
        +Future~Map~String,int~~ getStatistics()
    }

    ProjectRepository <|.. LocalProjectRepository : implements
```

---

## 2. Use Case Diagram (Sơ đồ ca sử dụng)

```mermaid
flowchart LR
    subgraph Hệ thống TaskFlow
        UC1["Đăng nhập / Đăng ký"]
        UC2["Xem danh sách Project"]
        UC3["Tạo Project"]
        UC4["Thêm thành viên vào Project"]
        UC5["Tạo Task"]
        UC6["Gán Task cho Member"]
        UC7["Xem tất cả Task"]
        UC8["Xem Task cá nhân"]
        UC9["Cập nhật tiến độ (Member)"]
        UC10["Phê duyệt công việc (Manager)"]
        UC11["Xem danh sách nhân sự"]
        UC12["Xem thống kê tiến độ"]
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
    Manager --- UC10
    Manager --- UC11
    Manager --- UC12

    Member --- UC1
    Member --- UC2
    Member --- UC8
    Member --- UC9
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
    
    F -- "Timeout / Lỗi mạng ⚠️" --> G_TIMEOUT["Hiển thị lỗi: 'Kết nối quá hạn, vui lòng thử lại!'"]
    G_TIMEOUT --> D
    
    F -- "Sai tài khoản ❌" --> G_AUTH["Hiển thị lỗi: 'Email hoặc mật khẩu không chính xác!'"]
    G_AUTH --> D
    
    F -- "Thành công ✅" --> H["Đọc role từ Firestore (Timeout 15s)"]
    H -- "Lỗi / Timeout ⚠️" --> G_ROLE["Đọc role mặc định từ Local SQLite"]
    
    H -- "Thành công ✅" --> I{"Role = ?"}
    G_ROLE --> I
    
    C -- Rồi --> H
    
    I -- manager --> J["Hiển thị giao diện Manager"]
    I -- member --> K["Hiển thị giao diện Member"]
    J --> L["Hiển thị Project List"]
    K --> L
    L --> M(["🔴 Kết thúc"])
```

### 3.2 Luồng Tạo Task (Manager - Kiểm tra trùng lặp)

```mermaid
flowchart TD
    A(["🟢 Bắt đầu"]) --> B["Manager chọn Project"]
    B --> C["Nhấn nút Tạo Task (+)"]
    C --> D["Hiển thị form tạo Task"]
    D --> E["Nhập: title, assignedTo, deadline"]
    E --> F{"Dữ liệu hợp lệ?"}
    F -- Không --> G["Hiển thị lỗi: 'Vui lòng điền đủ thông tin!'"]
    G --> D
    
    F -- Có --> CHECK_DUP{"Kiểm tra trùng Title\ntrong cùng Project?"}
    CHECK_DUP -- "Bị trùng ❌" --> G_DUP["Hiển thị lỗi: 'Tên task đã tồn tại trong dự án!'"]
    G_DUP --> D
    
    CHECK_DUP -- "Hợp lệ ✅" --> H["Tạo đối tượng Task mới (status = 'todo')"]
    H --> I["Lưu SQLite local & Sync Firestore"]
    I --> J["Cập nhật UI danh sách Task"]
    J --> K(["🔴 Kết thúc"])
```

### 3.3 Luồng Cập nhật Tiến độ (Member nộp bài - WAL & Sync)

```mermaid
flowchart TD
    START(["🟢 Bắt đầu"]) --> MEMBER_SELECT["Member chọn Task đang làm (doing)"]
    MEMBER_SELECT --> CLICK_SUBMIT["Click nút 'Nộp bài'"]
    CLICK_SUBMIT --> CONFIRM{"Xác nhận nộp?"}
    CONFIRM -- Không --> END_CANCEL(["🔴 Hủy bỏ"])
    
    CONFIRM -- Có --> UPDATE_LOCAL["Lưu SQLite: status = 'reviewing'\nisSynced = false (Write-Ahead)"]
    UPDATE_LOCAL --> OPTIMISTIC_UI["Rebuild UI lập tức\n(Hiển thị trạng thái 'Reviewing')"]
    
    OPTIMISTIC_UI --> CHECK_NET{"Có kết nối mạng?"}
    CHECK_NET -- Có --> PUSH_CLOUD["Đẩy lên Firebase Firestore"]
    PUSH_CLOUD --> SYNC_OK{"Firebase phản hồi OK?"}
    
    SYNC_OK -- Có --> MARK_SYNCED["Cập nhật SQLite: isSynced = true"]
    MARK_SYNCED --> NOTIFY["Hiển thị Snackbar: 'Đã nộp bài thành công!'"]
    NOTIFY --> END_SUCCESS(["🔴 Kết thúc"])
    
    SYNC_OK -- Không --> QUEUE_SYNC["Đưa vào Retry Queue"]
    CHECK_NET -- Không --> QUEUE_SYNC
    
    QUEUE_SYNC --> QUEUE_PENDING["Cảnh báo: 'Nộp bài offline, dữ liệu sẽ tự động đồng bộ khi online!'"]
    QUEUE_PENDING --> END_SUCCESS
```

### 3.4 Luồng Chỉnh sửa Task (Manager Only - Optimistic UI)

```mermaid
flowchart TD
    A(["🟢 Bắt đầu"]) --> B["Người dùng nhấn nút Edit"]
    B --> C{"Kiểm tra role == manager?"}
    C -- "Không ❌" --> D["Hiển thị thông báo:\n'Bạn không có quyền chỉnh sửa!'"]
    D --> E(["🔴 Kết thúc"])
    
    C -- "Có ✅" --> F["Mở màn hình EditTaskForm"]
    F --> G["Thay đổi thông tin & nhấn Save"]
    G --> H{"Dữ liệu hợp lệ?"}
    H -- "Không ❌" --> I["Hiển thị lỗi Validation"]
    I --> F
    
    H -- "Có ✅" --> J["Lưu SQLite local ngay\n(isSynced = 'pending', updatedAt = now)"]
    J --> K["Cập nhật UI lập tức\n(Optimistic UI)"]
    
    K --> L{"Kết nối mạng?"}
    L -- "Có mạng" --> M["Gửi lên Firestore (async)"]
    M --> N{"Firestore phản hồi OK?"}
    
    N -- "Thành công" --> O_OK["Cập nhật SQLite: isSynced = true"]
    O_OK --> P(["🔴 Kết thúc"])
    
    N -- "Thất bại (Server error)" --> O_FAIL["Hoàn tác UI local về trạng thái cũ\n& Thông báo lỗi"]
    O_FAIL --> F
    
    L -- "Mất mạng" --> P_OFF["Thông báo: 'Đã lưu local, sẽ đồng bộ khi có mạng'"]
    P_OFF --> P
```

---

## 4. Sequence Diagram (Sơ đồ tuần tự)

### 4.1 Cập nhật trạng thái Task (Member nộp bài)

```mermaid
sequenceDiagram
    actor Member
    participant Screen as TaskScreen
    participant Repo as TaskRepository
    participant Task as Task

    Member->>Screen: Chọn Task, nhấn cập nhật "reviewing"
    Screen->>Repo: updateTaskStatus(taskId, "reviewing")
    
    alt Kiểm tra logic cập nhật (doing -> reviewing)
        Repo->>Task: checkValidTransition("doing", "reviewing")
        Task-->>Repo: Valid (true)
        Repo->>Repo: Lưu SQLite (status: "reviewing")
        Repo-->>Screen: Success (true, "Thành công")
        Screen->>Screen: setState() -> rebuild UI
        Screen-->>Member: Hiển thị Snackbar: "Đã gửi yêu cầu phê duyệt!"
    else Sai quy trình chuyển đổi trạng thái (ví dụ: todo -> reviewing)
        Repo->>Task: checkValidTransition("todo", "reviewing")
        Task-->>Repo: Invalid (false)
        Repo-->>Screen: Failure (false, "Quy trình chuyển đổi trạng thái không hợp lệ!")
        Screen-->>Member: Hiển thị Dialog lỗi: "Không thể chuyển trạng thái trực tiếp!"
    end
```

### 4.2 Luồng Repository Pattern (Offline Fallback & Error Handling)

```mermaid
sequenceDiagram
    actor User
    participant UI as HomePage
    participant Repo as TaskRepository
    participant SQLite as LocalDatabase (SQLite)
    participant Cloud as RemoteDatabase (Firestore)

    User->>UI: Mở app
    UI->>Repo: getTasks()
    
    alt Có mạng
        Repo->>Cloud: getTasksFromServer()
        alt Fetch thành công
            Cloud-->>Repo: List<Task> (từ server)
            Repo->>SQLite: cacheDataToSQLite()
            Repo-->>UI: List<Task>
            UI-->>User: Hiển thị danh sách task đã đồng bộ
        else Lỗi kết nối server / Timeout
            Cloud-->>Repo: Connection Timeout Exception
            Repo->>SQLite: readCachedData()
            SQLite-->>Repo: List<Task> (cũ)
            Repo-->>UI: List<Task> (cũ) + Connection Warning
            UI-->>User: Hiển thị danh sách kèm cảnh báo: "Lỗi kết nối, hiển thị dữ liệu offline!"
        end
    else Không có mạng
        Repo->>SQLite: readCachedData()
        SQLite-->>Repo: List<Task>
        Repo-->>UI: List<Task>
        UI-->>User: Hiển thị danh sách kèm nhãn Offline
    end
```

---

## 5. Sơ đồ Kiến trúc Hệ thống

```mermaid
flowchart TB
    subgraph UI["🖥 UI Layer (Screens)"]
        S0["SplashScreen"]
        S1["LoginScreen"]
        S1a["RegisterScreen"]
        S2["ProjectListScreen"]
        S2a["AddProjectScreen"]
        S3["ProjectTaskListScreen"]
        S3a["CreateTaskScreen"]
        S3b["EditTaskScreen"]
        S4["TaskDetailScreen"]
        S5["ProfileScreen"]
        S6["UserListScreen"]
        S7["AddMemberScreen"]
    end

    subgraph State["⚙ State Layer (Providers)"]
        P1["AuthProvider"]
        P2["ProjectProvider"]
        P3["TaskProvider"]
    end

    subgraph Repo["🔌 Repository Layer"]
        R1["TaskRepository\n(abstract)"]
        R2["LocalTaskRepository\n(implements)"]
        R3["UserRepository\n(abstract)"]
        R4["LocalUserRepository\n(implements)"]
        R5["ProjectRepository\n(abstract)"]
        R6["LocalProjectRepository\n(implements)"]
    end

    subgraph Data["📦 Data Layer (Models)"]
        M1["UserModel"]
        M2["ProjectModel"]
        M3["Task"]
    end

    subgraph Storage["💾 Storage"]
        FB["Firebase Firestore\n(Cloud)"]
        SQ["SQLite - sqflite\n(Local/Offline)"]
        FA["Firebase Auth\n(Xác thực)"]
    end

    UI --> State
    State --> Repo
    Repo --> Data
    Repo --> Storage
    State --> Storage
```

---

## 6. Sơ đồ Quan hệ Dữ liệu (ERD)

```mermaid
erDiagram
    USERS {
        string id PK "Firebase UID"
        string name "Tên người dùng"
        string email "Email đăng nhập"
        string role "manager / member"
    }

    PROJECTS {
        string id PK "ID project"
        string name "Tên project"
        string description "Mô tả dự án"
    }

    TASKS {
        string id PK "ID task"
        string title "Tên công việc"
        string projectId FK "ID project chứa task"
        string assignedTo FK "ID user được giao"
        string status "todo / doing / reviewing / done"
        DateTime deadline "Hạn hoàn thành"
        DateTime updatedAt "Thời điểm cập nhật"
    }

    USERS ||--o{ TASKS : "được giao"
    PROJECTS ||--o{ TASKS : "chứa"
    USERS }o--o{ PROJECTS : "tham gia (memberIds)"
```

---

## 7. State Diagram – Trạng thái Task

```mermaid
stateDiagram-v2
    [*] --> todo : Tạo Task mới (Manager)
    todo --> doing : Member nhận việc
    doing --> reviewing : Member nộp bài
    reviewing --> done : Manager duyệt ✅
    reviewing --> doing : Manager từ chối ❌
    
    done --> archived : Manager lưu trữ (Archive)
    archived --> [*] : Xóa vĩnh viễn (sau 30 ngày)
    
    todo --> cancelled : Manager hủy task
    doing --> cancelled : Manager hủy task
    cancelled --> [*] : Xóa khỏi thùng rác
    
    note right of todo : 🔴 Đỏ
    note right of doing : 🟡 Vàng
    note right of reviewing : 🔵 Xanh dương
    note right of done : 🟢 Xanh lá
    note right of archived : ⚪ Xám
    note right of cancelled : ⬛ Đen
```

---

## 8. Sơ đồ Điều hướng Màn hình (Navigation Flow)

```mermaid
flowchart TD
    SPLASH(["🎬 SplashScreen"]) --> LOGIN["🔐 LoginScreen"]
    LOGIN --> REGISTER["📝 RegisterScreen"]
    REGISTER -->|Back| LOGIN
    
    LOGIN --> |"Đăng nhập thành công"| ROLE_DECISION{"Phân loại Role?"}
    
    ROLE_DECISION -->|Manager| MGR_DASHBOARD["📱 Manager Navigation Dashboard\n(Bottom Nav Bar)"]
    ROLE_DECISION -->|Member| MEM_DASHBOARD["📱 Member Navigation Dashboard\n(Bottom Nav Bar)"]
    
    %% Manager Navigation
    subgraph Manager Navigation (3 Tabs)
        MGR_DASHBOARD --> MGR_TAB1["🗂 ProjectListScreen\n(Manager Mode)"]
        MGR_DASHBOARD --> MGR_TAB2["📋 MyTaskScreen\n(Manager overview)"]
        MGR_DASHBOARD --> MGR_TAB3["👤 ProfileScreen"]
        
        MGR_TAB1 -->|"+" FAB| ADD_PROJECT["🆕 AddProjectScreen"]
        MGR_TAB1 -->|"Tap Project"| MGR_TASK_LIST["📋 ProjectTaskListScreen"]
        MGR_TASK_LIST -->|"+" FAB| CREATE_TASK["🆕 CreateTaskScreen"]
        MGR_TASK_LIST -->|"Tap Task"| TASK_DETAIL["🔍 TaskDetailScreen\n(Manager Mode)"]
        
        TASK_DETAIL -->|"Edit"| EDIT_TASK["✏️ EditTaskScreen"]
        MGR_TASK_LIST -->|"Manage Members"| ADD_MEMBER["👤 AddMemberScreen"]
        ADD_MEMBER -->|"List Users"| USER_LIST["👥 UserListScreen"]
    end
    
    %% Member Navigation
    subgraph Member Navigation (2 Tabs - No FAB)
        MEM_DASHBOARD --> MEM_TAB1["🗂 ProjectListScreen\n(Member View only)"]
        MEM_DASHBOARD --> MEM_TAB2["👤 ProfileScreen"]
        
        MEM_TAB1 -->|"Tap Project"| MEM_TASK_LIST["📋 ProjectTaskListScreen"]
        MEM_TASK_LIST -->|"Tap Task"| MEM_TASK_DETAIL["🔍 TaskDetailScreen\n(Member View Mode)"]
        MEM_TASK_DETAIL -->|"Tap Status"| STATUS_DIALOG["💬 Update Status Dialog"]
    end
    
    %% Back Stack pops (Android Back Button / Navigator pop)
    EDIT_TASK -->|"Back / Save"| TASK_DETAIL
    TASK_DETAIL -->|"Back"| MGR_TASK_LIST
    CREATE_TASK -->|"Back / Save"| MGR_TASK_LIST
    ADD_MEMBER -->|"Back"| MGR_TASK_LIST
    USER_LIST -->|"Back"| ADD_MEMBER
    ADD_PROJECT -->|"Back / Save"| MGR_TAB1
    MGR_TASK_LIST -->|"Back"| MGR_TAB1
    
    MEM_TASK_DETAIL -->|"Back"| MEM_TASK_LIST
    MEM_TASK_LIST -->|"Back"| MEM_TAB1
    
    MGR_TAB3 -->|"Đăng xuất"| LOGIN
    MEM_TAB2 -->|"Đăng xuất"| LOGIN
    
    style SPLASH fill:#9E9E9E,color:#fff
    style LOGIN fill:#E74C3C,color:#fff
    style ROLE_DECISION fill:#9C27B0,color:#fff
    style MGR_DASHBOARD fill:#2196F3,color:#fff
    style MEM_DASHBOARD fill:#4CAF50,color:#fff
```

---

## 9. Sơ đồ Chiến lược Lưu trữ Kép (Dual Storage)

### 9.1 Luồng Đọc Dữ liệu (Read Data Flow) - Cache Invalidation

```mermaid
flowchart TD
    START("App Load") --> CONNECTIVITY{Kết nối Internet?}
    
    CONNECTIVITY -- "Có" --> FETCH["Firestore.getDocs()\n+ timestamps"]
    FETCH --> COMPARE{So sánh}
    
    COMPARE -- "Server updatedAt > Local cachedAt" --> UPDATE_UI["Update UI\n+ Cache SQLite"]
    UPDATE_UI --> OFFLINE_ICON["☁️ Icon: đã sync"]
    
    COMPARE -- "Server = Local (không đổi)" --> SKIP["Giữ UI\n(stale OK)"]
    
    CONNECTIVITY -- "Không" --> LOAD_LOCAL["SQLite.getAll()\n+cachedAt"]
    LOAD_LOCAL --> OFFLINE_ICON_LATE["⚠️ Icon: OFFLINE\nHiển thị dữ liệu cũ"]
    
    OFFLINE_ICON --> END["✅ Done"]
    OFFLINE_ICON_LATE --> END
    SKIP --> END
    
    style COMPARE fill:#FF9800
    style OFFLINE_ICON_LATE fill:#F44336,color:#fff
```

### 9.2 Luồng Ghi Dữ liệu (Write Data Flow) - Write-Ahead Logging & Optimistic UI

```mermaid
flowchart TD
    START["User Input & Save"] --> LOCAL["SQLite.write(\nisSynced = 'pending', localCreatedAt = now)"]
    LOCAL --> SUCCESS_LOCAL{Local\nWrite OK?}
    
    SUCCESS_LOCAL -- "FAIL ❌" --> ERROR_SHOW["❌ Lỗi ngay"]
    ERROR_SHOW --> END_ERR["🔴 End"]
    
    SUCCESS_LOCAL -- "OK ✅" --> UI["✅ UI update ngay\n(Optimistic UI)"]
    UI --> TRY_SYNC{Try sync\n(background)}
    
    TRY_SYNC -- "Có network" --> FIRESTORE["Firestore.create()"]
    FIRESTORE --> CHECK_SERVER{Server\nOK?}
    
    CHECK_SERVER -- "FAIL ❌" --> QUEUE["📋 Giữ trong\nretry queue"]
    QUEUE --> RETRY_TIMER["⏰ Retry with\nexponential backoff"]
    
    CHECK_SERVER -- "OK ✅" --> MARK_SYNC["✅ isSynced = true\nupdatedAt = serverTimestamp()"]
    MARK_SYNC --> FINAL["✅ Done"]
    
    TRY_SYNC -- "Không network" --> QUEUE
    
    style LOCAL fill:#4CAF50,color:#fff
    style QUEUE fill:#FF9800,color:#fff
```

### 9.3 Luồng Đồng bộ Ngầm (Background Sync)

```mermaid
flowchart TD
    START(["⏰ App background\nhoặc Timer tick"]) --> CONNECTIVITY{Kết nối\nInternet?}
    
    CONNECTIVITY -- "Không ❌" --> WAIT(["😴 Chờ\n(lượng lại sau)"])
    WAIT --> START
    
    CONNECTIVITY -- "Có ✅" --> GET_PENDING["📋 Lấy danh sách\nisSynced = false"]
    GET_PENDING --> LOOP{For each\nrecord}
    
    LOOP --> UPLOAD["☁️ Upload lên\nFirestore"]
    UPLOAD --> CHECK_ERR{Lỗi?}
    
    CHECK_ERR -- "Có ❌" --> LOG_ERR["📝 Ghi log lỗi\n+ Skip"]
    CHECK_ERR -- "Không ✅" --> MARK_OK["✅ Đánh dấu\nisSynced = true"]
    
    MARK_OK --> LOOP
    LOG_ERR --> LOOP
    
    LOOP -- "Hết dữ liệu" --> DONE(["✅ Sync\nHoàn tất"])
    
    style START fill:#9C27B0,color:#fff
    style DONE fill:#4CAF50,color:#fff
```

### 9.4 Luồng Xử lý Xung đột Đồng bộ (Sync Conflict Resolution) - Triple Conflict Merge

```mermaid
flowchart TD
    START["Sync batch"] --> FETCH["Fetch both\nLocal & Server"]
    FETCH --> FOR_EACH{For each record}
    
    FOR_EACH --> COMPARE{Compare scenarios}
    
    CASE_1[Local edit + Server not exist] --> PUSH["☁️ Push Local"]
    
    CASE_2[Server edit + Local not exist] --> PULL["📥 Pull Server"]
    
    CASE_3[Local updatedAt > Server] --> PUSH
    
    CASE_4[Server updatedAt > Local] --> PULL
    
    CASE_5{Server & Local\nDIFFERENT?\n(Same time)} --> CONFLICT[⚠️ TRIPLE\nConflict]
    CONFLICT --> USER_CHOOSE["🤔 Dialog:\nKeep Local / Keep Server"]
    
    USER_CHOOSE --> PUSH
    USER_CHOOSE --> PULL
    
    PUSH --> MARK["✅ Mark synced"]
    PULL --> MARK
    
    MARK --> MORE{More?}
    MORE -- "Yes" --> FOR_EACH
    MORE -- "No" --> END["✅ Done"]
    
    style CONFLICT fill:#F44336,color:#fff
```

---

## 10. Sơ đồ Provider – Quản lý Trạng thái
```mermaid
classDiagram
    class AuthProvider {
        -UserModel? _currentUser
        +Future login()
        +Future register()
    }
    class ProjectProvider {
        -List~ProjectModel~ _projects
        +Future loadProjects()
    }
    class TaskProvider {
        -List~Task~ _tasks
        +Future loadTasks()
        +Future updateStatus()
    }
    ChangeNotifier <|-- AuthProvider
    ChangeNotifier <|-- ProjectProvider
    ChangeNotifier <|-- TaskProvider
```
