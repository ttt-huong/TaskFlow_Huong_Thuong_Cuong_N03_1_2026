# YC — Tóm tắt nhanh Design Tokens & Prompt

Mục đích: cung cấp bộ constraints ngắn gọn để AI/dev tái thiết kế UI Flutter theo phong cách "Premium / Minimalist".

- Background: #F8FAFC
- Surface/Card: #FFFFFF
- Primary: #4F46E5
- Text chính: #0F172A
- Text phụ: #64748B
- Tránh: #8B5CF6 (tím neon), #000000 (đen thuần)

Typography
- H1: 700, 28–32px
- Section: 600, 18px
- Body: 400, 16px
- Meta/caption: 500, 12px, UPPERCASE, letter-spacing rộng

Layout & spacing
- Screen padding: 24px horizontal, 32px top
- Card padding: 20px
- Card radius: 24px
- Gap tối thiểu: 16px (scale 4px steps)

Components (nhanh)
- Navbar: "Floating island" — cách đáy 24px, pill, blur nhẹ, opacity ~0.9
- Cards: không viền, shadow mềm (Color(0xFF0F172A).withOpacity(0.04), blur ~20)
- Inputs: filled (#F1F5F9), không underline

Motion & interaction
- Transitions: fade/slide, 180–240ms
- Add: scale feedback, smooth checkbox, swipe gestures, skeleton loading

Prompt rules (Constraints First)
- Luôn liệt kê: THAY VÌ (cấm) → HÃY DÙNG (thay thế cụ thể)
- Cung cấp số liệu cụ thể (spacing, radii, sizes)
- Đặt hierarchy: 1 hero, 2–3 phụ, metadata nhỏ

Quick Flutter snippet (Floating Navbar)
```
Container(
  margin: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.9),
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(color: Color(0xFF0F172A).withOpacity(0.08), blurRadius: 24, offset: Offset(0, 8)),
    ],
  ),
  child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [/* icons */]),
)
```

Kết: Dùng file này khi cần prompt nhanh cho AI hoặc checklist designer/dev.
