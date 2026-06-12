# TaskFlow ERD Diagrams

Tài liệu này tách riêng hai sơ đồ ERD của hệ thống TaskFlow: một sơ đồ nghiệp vụ đơn giản dùng cho báo cáo chính và một sơ đồ kỹ thuật phản ánh cấu trúc SQLite local database hiện tại.

## 1. ERD nghiệp vụ đơn giản

Sơ đồ này mô tả các thực thể chính trong nghiệp vụ quản lý dự án và công việc. Phần này ưu tiên sự dễ hiểu, không đưa các trường kỹ thuật phục vụ đồng bộ như `isSynced`, `syncedAt`, `updatedAt` hoặc `offlineAuthHash`.

```mermaid
erDiagram
    User {
        string id
        string name
        string email
        string role
    }

    Project {
        string id
        string name
        string description
        string memberIds
    }

    Task {
        string id
        string title
        string description
        string status
        date deadline
        string assignedTo
        string projectId
        string rejectionReason
    }

    Notification {
        string id
        string userId
        string relatedTaskId
        string title
        string message
        bool isRead
        string type
    }

    User }o--o{ Project : memberIds
    Project ||--o{ Task : projectId
    User ||--o{ Task : assignedTo
    User ||--o{ Notification : userId
    Task ||--o{ Notification : relatedTaskId
```

Ghi chú:

- `Project.memberIds` là quan hệ logic nhiều-nhiều giữa User và Project.
- `Task.assignedTo` là UID của User được giao việc.
- `Notification` chỉ lưu local trong ứng dụng, không đồng bộ lên Firestore.

## 2. ERD kỹ thuật SQLite Local Database

Sơ đồ này phản ánh cấu trúc SQLite local database hiện tại trong ứng dụng. Các trường kỹ thuật như `isSynced`, `syncedAt`, `updatedAt` và `offlineAuthHash` được giữ lại vì phục vụ cơ chế Offline-First và đồng bộ dữ liệu.

```mermaid
erDiagram
    users_local {
        TEXT id PK
        TEXT name
        TEXT email
        TEXT role
        TEXT offlineAuthHash
        TEXT avatarChar
    }

    projects_local {
        TEXT id PK
        TEXT name
        TEXT description
        TEXT memberIds
        TEXT syncedAt
        INTEGER isSynced
        TEXT updatedAt
    }

    tasks_local {
        TEXT id PK
        TEXT title
        TEXT description
        TEXT projectId FK
        TEXT assignedTo
        TEXT status
        TEXT deadline
        TEXT assigneeName
        TEXT assigneeAvatar
        INTEGER isUrgent
        TEXT updatedAt
        TEXT syncedAt
        INTEGER isSynced
        TEXT rejectionReason
    }

    notifications_local {
        TEXT id PK
        TEXT userId
        TEXT relatedTaskId
        TEXT title
        TEXT message
        TEXT createdAt
        INTEGER isRead
        TEXT type
    }

    projects_local ||--o{ tasks_local : projectId
    users_local ||--o{ tasks_local : assignedTo
    users_local ||--o{ notifications_local : userId
    tasks_local ||--o{ notifications_local : relatedTaskId
    users_local ||--o{ projects_local : memberIds_logical
```

Ghi chú:

- `memberIds` được lưu dạng chuỗi UID phân tách bằng dấu phẩy để đơn giản hóa đồng bộ offline.
- `isSynced = 0` nghĩa là bản ghi đang chờ đồng bộ lên Firestore.
- `updatedAt` dùng để giải quyết xung đột dữ liệu giữa local và server.
- `offlineAuthHash` chỉ dùng cho xác thực ngoại tuyến, không được lưu lên Firestore.
