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
        +bool updateStatus(String newStatus)
        +bool isOverdue()
        +String toString()
    }

    class ListUser {
        -List~UserModel~ _users
        +List~UserModel~ users
        +int length
        +void create(UserModel user)
        +UserModel? findById(String id)
        +bool edit(String id, ...)
        +bool delete(String id)
        +Map~String,int~ thongKe
    }

    class ListProject {
        -List~ProjectModel~ _projects
        +List~ProjectModel~ projects
        +int length
        +void create(ProjectModel project)
        +ProjectModel? findById(String id)
        +bool edit(String id, ...)
        +bool delete(String id)
        +Map~String,int~ thongKe
    }

    class ListTask {
        -List~Task~ _tasks
        +List~Task~ tasks
        +int length
        +void create(Task task)
        +Task? findById(String id)
        +bool edit(String id, ...)
        +bool delete(String id)
        +Future~Map~String,int~~ getStatistics()
    }

    ListUser "1" *-- "0..*" UserModel : chứa
    ListProject "1" *-- "0..*" ProjectModel : chứa
    ListTask "1" *-- "0..*" Task : chứa

    ProjectModel "1" -- "0..*" Task : projectId
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
        -ListTask _listTask
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
    LocalTaskRepository o-- ListTask : delegate

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
        -ListUser _listUser
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
        -ListProject _listProject
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

### 3.1 Luồng Đăng nhập & Phân quyền

```mermaid
flowchart TD
    A(["🟢 Bắt đầu"]) --> B["Mở ứng dụng"]
    B --> C{"Đã đăng nhập?"}
    C -- Chưa --> D["Hiển thị màn hình Login"]
    D --> E["Nhập email & password"]
    E --> F{"Xác thực Firebase Auth"}
    F -- Thất bại --> G["Hiển thị lỗi"]
    G --> D
    F -- Thành công --> H["Đọc role từ Firestore"]
    C -- Rồi --> H
    H --> I{"Role = ?"}
    I -- manager --> J["Hiển thị giao diện Manager"]
    I -- member --> K["Hiển thị giao diện Member"]
    J --> L["Hiển thị Project List"]
    K --> L
    L --> M(["🔴 Kết thúc"])
```

### 3.2 Luồng Tạo Task (Manager)

```mermaid
flowchart TD
    A(["🟢 Bắt đầu"]) --> B["Manager chọn Project"]
    B --> C["Nhấn nút Tạo Task (+)"]
    C --> D["Hiển thị form tạo Task"]
    D --> E["Nhập: title, assignedTo, deadline"]
    E --> F{"Dữ liệu hợp lệ?"}
    F -- Không --> G["Hiển thị lỗi validation"]
    G --> D
    F -- Có --> H["Tạo đối tượng Task mới"]
    H --> I["status = 'todo'"]
    I --> J["Gọi ListTask.create(task)"]
    J --> K["Cập nhật UI danh sách Task"]
    K --> L(["🔴 Kết thúc"])
```

    O --> P(["🔴 Kết thúc"])

### 3.4 Luồng Chỉnh sửa Task (Manager Only - Error Handling)

```mermaid
flowchart TD
    A(["🟢 Bắt đầu"]) --> B["Người dùng nhấn nút Edit"]
    B --> C{"Kiểm tra role == manager?"}
    C -- "Không ❌" --> D["Hiển thị thông báo:\n'Bạn không có quyền này'"]
    D --> E(["🔴 Kết thúc"])
    
    C -- "Có ✅" --> F["Mở màn hình EditTaskForm"]
    F --> G["Thay đổi thông tin & nhấn Save"]
    G --> H{"Dữ liệu hợp lệ?"}
    H -- "Không ❌" --> I["Hiển thị lỗi Validation"]
    I --> F
    
    H -- "Có ✅" --> J["Gọi Repository.updateTask()"]
    J --> K{"Kết nối mạng?"}
    K -- "Mất mạng" --> L["Lưu vào SQLite\n(Đánh dấu sync_pending)"]
    K -- "Có mạng" --> M["Gửi lên Firestore"]
    
    M --> N{"Thành công?"}
    N -- "Thất bại (Lỗi Server)" --> O["Ghi log & thông báo lỗi"]
    N -- "Thành công" --> P["Cập nhật UI & SQLite"]
    
    L --> P
    P --> Q(["🔴 Kết thúc"])
```

---

## 4. Sequence Diagram (Sơ đồ tuần tự)

### 4.1 Cập nhật trạng thái Task (Member nộp bài)

```mermaid
sequenceDiagram
    actor Member
    participant Screen as TaskScreen
    participant ListTask as ListTask
    participant Task as Task

    Member->>Screen: Chọn Task, nhấn cập nhật "reviewing"
    Screen->>ListTask: edit(taskId, status: "reviewing")
    ListTask->>ListTask: indexWhere(id == taskId)
    
    alt Tìm thấy task
        ListTask->>Task: updateStatus("reviewing")
        
        alt doing → reviewing (Hợp lệ)
            Task-->>Task: status = "reviewing"
            Task-->>ListTask: return true
        else Sai quy trình
            Task-->>ListTask: return false
        end
        
        ListTask-->>Screen: return true/false
    else Không tìm thấy
        ListTask-->>Screen: return false
    end
    
    Screen->>Screen: setState() → rebuild UI
    Screen-->>Member: Hiển thị kết quả
```

### 4.2 Luồng Repository Pattern

```mermaid
sequenceDiagram
    actor User
    participant UI as HomePage
    participant Repo as TaskRepository
    participant Local as LocalTaskRepository
    participant Data as List~Task~

    User->>UI: Mở app
    UI->>Repo: getTasks()
    Repo->>Local: getTasks()
    Local->>Data: return List~Task~
    Data-->>Local: [Task1, Task2, Task3]
    Local-->>UI: List~Task~
    UI-->>User: Hiển thị danh sách
```

---

## 5. Sơ đồ Kiến trúc Hệ thống

```mermaid
flowchart TB
    subgraph UI["🖥 UI Layer (Screens)"]
        S1["LoginScreen"]
        S2["ProjectScreen"]
        S3["TaskScreen"]
        S4["MyTaskScreen"]
        S5["ProfileScreen"]
    end

    subgraph State["⚙ State Layer (Providers)"]
        P1["AuthProvider"]
        P2["ProjectProvider"]
        P3["TaskProvider"]
    end

    subgraph Repo["🔌 Repository Layer"]
        R1["TaskRepository\n(abstract)"]
        R2["LocalTaskRepository\n(implements)"]
    end

    subgraph Data["📦 Data Layer (Models)"]
        M1["UserModel"]
        M2["ProjectModel"]
        M3["Task"]
        L1["ListUser"]
        L2["ListProject"]
        L3["ListTask"]
    end

    subgraph Storage["💾 Storage"]
        FB["Firebase Firestore\n(Cloud)"]
        SQ["SQLite - sqflite\n(Local/Offline)"]
        FA["Firebase Auth\n(Xác thực)"]
    end

    UI --> State
    State --> Repo
    Repo --> Data
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
    [*] --> todo : Tạo Task mới
    todo --> doing : Member nhận việc
    doing --> reviewing : Member nộp bài
    reviewing --> done : Manager duyệt ✅
    reviewing --> doing : Manager yêu cầu sửa ❌

    note right of todo : 🔴 Màu đỏ
    note right of doing : 🟡 Màu vàng
    note right of reviewing : 🔵 Màu xanh dương
    note right of done : 🟢 Màu xanh lá
```

---

## 8. Sơ đồ Điều hướng Màn hình (Navigation Flow)

```mermaid
flowchart TD
    subgraph Auth["🔐 Xác thực"]
        Login["LoginScreen"]
        Register["RegisterScreen"]
    end

    subgraph Main["📱 Main App (Bottom Navigation Bar)"]
        Tab1["🗂 Projects\n(ProjectListScreen)"]
        Tab2["📋 My Tasks\n(MyTaskScreen)"]
        Tab3["👤 Profile\n(ProfileScreen)"]
    end

    Login -- "Đăng nhập thành công" --> Tab1
    Tab1 -- "Chọn Project" --> TaskList["TaskListScreen"]
    Tab1 <-. "Bottom Nav" .-> Tab2
    Tab2 <-. "Bottom Nav" .-> Tab3
    Tab3 -- "Đăng xuất" --> Login

    style Auth fill:#FFEBEE,stroke:#E74C3C
    style Main fill:#E3F2FD,stroke:#2196F3
```

---

## 9. Sơ đồ Chiến lược Lưu trữ Kép (Dual Storage)

### 9.1 Luồng Đọc dữ liệu

```mermaid
flowchart TD
    B -- "Có mạng" --> C["Firestore -> Cache SQLite -> UI"]
    B -- "Mất mạng" --> D["Đọc từ SQLite -> UI"]
```

### 9.4 Luồng Xử lý Xung đột Đồng bộ (Sync Conflict Resolution)

```mermaid
flowchart TD
    A(["🟢 Bắt đầu đồng bộ"]) --> B["Lấy bản ghi từ Local & Server"]
    B --> C{"So sánh updatedAt?"}
    
    C -- "Local > Server ⏫" --> D["Đẩy dữ liệu Local lên Cloud"]
    C -- "Server > Local ⏬" --> E["Cập nhật dữ liệu Cloud vào Local"]
    C -- "Bằng nhau =" --> F["Bỏ qua (Đã đồng bộ)"]
    
    D --> G["Đánh dấu hoàn tất đồng bộ"]
    E --> G
    F --> G
    G --> H(["🔴 Kết thúc"])
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
