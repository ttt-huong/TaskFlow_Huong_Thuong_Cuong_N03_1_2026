# CLAUDE.md — Karpathy + Flutter Rules

Guidelines cho **dev + AI** để tránh code sai, rối, over-engineer.

---

## 🧠 1. Think Before Coding

* Không đoán → không chắc thì hỏi
* Có nhiều cách → nêu ra, không chọn bừa
* Ưu tiên cách đơn giản nhất
* Không hiểu → dừng lại, nói rõ

---

## ✂️ 2. Simplicity First

* Chỉ làm đúng yêu cầu
* Không thêm feature ngoài scope
* Không abstraction nếu chưa cần
* Không “code cho tương lai”

> Nếu 200 dòng viết được bằng 50 → viết lại

---

## 🔧 3. Surgical Changes

* Chỉ sửa đúng phần cần
* Không refactor linh tinh
* Không sửa code không liên quan
* Match style hiện tại

✔ Xóa code thừa do mình tạo
❌ Không xóa code cũ nếu không được yêu cầu

---

## 🎯 4. Goal-Driven

Luôn rõ:

* Mục tiêu là gì
* Khi nào coi là xong

---

## 🏗️ 5. Project Structure

```id="l5iv9d"
lib/
core/        # colors, theme, constants
models/      # data
providers/   # state + logic (Riverpod)
repositories/# CRUD
services/    # API
screens/     # UI
widgets/     # reusable UI
main.dart
```

---

## 🚀 6. main.dart (STRICT)

Chỉ:

* Firebase init
* runApp

```dart id="7d5a9q"
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
```

❌ Không:

* logic
* list
* màu sắc
* API

---

## 🔄 7. Data Flow (BẮT BUỘC)

```id="uyh0zz"
UI → Provider → Repository → Service
```

❌ Không bypass tầng

---

## 📦 8. State (Riverpod)

* Provider = state + logic
* UI chỉ gọi provider

State phải có:

* loading
* success
* error

---

## ⚙️ 9. Coding Rules

### ❌ Không logic trong UI

```dart id="w9n2lm"
// ❌
await dio.post(...)

// ✅
ref.read(provider.notifier).action()
```

---

### ❌ Không hardcode

```dart id="0xntdb"
// ❌
Color(...), fontSize: 16

// ✅
AppColors, AppTextStyles
```

---

### 🔁 Không duplicate

* Lặp ≥ 2 lần → tách

---

### 📏 File size

* > 150 dòng → xem xét
* > 200 dòng → bắt buộc tách

---

### 🧼 Import

* Không import thừa
* Không import vòng

---

### ⚠️ Error handling

```dart id="5o07i6"
// ❌
print(e)

// ✅
update state error
```

---

## 🚨 10. Anti-Patterns

* Logic trong `build()`
* API trong UI
* Hardcode UI
* 1 file làm nhiều việc
* Copy-paste

---

## ✅ 11. Checklist

* main.dart có sạch?
* UI có logic không?
* Có hardcode không?
* File có quá dài?
* State đủ 3 trạng thái?
* API đúng flow?

---

## 🧠 Final Rule

> Code phải **dễ đọc hơn là thông minh**
