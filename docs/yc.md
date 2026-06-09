Tóm tắt nhanh — Design tokens & hướng dẫn prompt

Mục đích: cung cấp bộ constraints rõ ràng để AI hoặc developer tái thiết kế UI Flutter theo phong cách "Premium/Minimalist".

1) Màu sắc (bắt buộc)
- Background: #F8FAFC
- Card/Surface: #FFFFFF
- Primary: #4F46E5
- Text chính: #0F172A
- Text phụ: #64748B
- Tránh: #8B5CF6 (tím neon), #000000 (đen thuần)

2) Typography
- H1: 700, 28–32px
- Section: 600, 18px
- Body: 400, 16px
- Meta/caption: 500, 12px, UPPERCASE, letter-spacing rộng

3) Spacing & layout
- Screen padding: 24px horizontal, 32px top
- Card padding: 20px
- Card radius: 24px
- Gap tối thiểu: 16px

4) Components (chú ý)
- Navbar: "Floating island" — cách đáy 24px, pill, blur nhẹ
- Cards: không viền, shadow mềm (màu #0F172A 4% opacity, blur ~20)
- Inputs: filled (#F1F5F9), không underline

5) Motion & interaction
- Animation: fade/slide, 180–240ms
- Thêm scale feedback, smooth checkbox, swipe gestures, skeleton loading

6) Prompt authoring rules (Constraints First)
- Luôn liệt kê: THAY VÌ (những thứ cấm) → HÃY DÙNG (thay thế cụ thể)
- Cung cấp số liệu: spacing scale (4px steps), sizes, radii
- Quy định hierarchy: 1 hero, 2–3 phụ, metadata nhỏ

7) Quick Flutter example (floating navbar)
```
Container(
  margin: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.9),
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF0F172A).withOpacity(0.08),
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [ /* icons */ ],
  ),
)
```

Kết luận ngắn: cung cấp constraints và design tokens rõ ràng cho AI/dev — tránh prompt chung chung "làm đẹp" để có UI nhất quán, cao cấp.

- Spacing between inputs: 16px
- Footer text: centered, color #64748B

IMPORTANT: Follow the rules exactly. Do not add your own colors."
✅ CHECKLIST TRƯỚC KHI CHẠY CODE
Trước khi AI generate code, hãy bảo AI đọc lại checklist này:


Copy code
"Before generating code, verify:
[ ] Không dùng màu đen (#000000) cho text
[ ] Không dùng viền cứng (hard border)
[ ] Radius tối thiểu 16px, tốt nhất 24px
[ ] Navbar cách đáy > 20px
[ ] Màu nền không phải trắng tinh
[ ] Button không bị vuông góc
[ ] Mọi text không cùng cỡ/cùng đậm
📌 TÓM TẮT
Điều cần nói rõ

Cách nói trong prompt

Tránh màu gì

"Don't use bright purple"

Dùng màu gì

"Use #4F46E5 as primary"

Khoảng cách

"Use 24px padding"

Hình dạng

"Radius 24px minimum"

Font

"Weight 700 for title, 400 for body"

Navbar

"Floating with blur, margin 24px bottom"

Kết luận: AI không biết "đẹp" là gì. Nó chỉ biết "đúng constraints". Bạn càng đưa nhiều số liệu và ví dụ NEGATIVE (không được làm gì), AI càng ít sai.


thế bạn tìm cho tôi tất cả các ví dụ negative hiện có

Copy message
Edit message


Thought for a moment
H SÁCH NEGATIVE EXAMPLES (Đầy đủ)

1. MÀU SẮC ❌
Sai

Lý do

Đúng

#8B5CF6 (Neon Purple)

Quá gắt, giống template cũ

#4F46E5 hoặc #6366F1

#000000 (Đen tuyệt đối)

Quá harsh cho text

#0F172A (Slate 900)

#FFFFFF làm nền chính

Quá plain

#F8FAFC (Slate 50)

Màu quá nhiều

Loạn, không premium

giới hạn 3-4 màu

Gradient gắt

Lỗi thời, rẻ tiền

Solid color hoặc subtle blur

2. TYPOGRAPHY ❌
Sai

Lý do

Đúng

Poppins Bold everywhere

Quá mạnh, không có hierarchy

Mix: 700/500/400

Tất cả cùng cỡ

Không có điểm nhấn

32px, 18px, 16px, 12px

Chữ thường cho meta

Không nổi bật

UPPERCASE, Letter spacing 1.0

Montserrat đậm

Giống blog xưa

Dùng Inter/SF Pro

Không có khoảng cách dòng

Chật, khó đọc

Line height 1.5

3. SPACING & LAYOUT ❌
Sai

Lý do

Đúng

Element dính nhau

Bức bí, không breathing room

Min 16px gap

Padding quá nhỏ (8-12px)

UI chật

20-24px

Screen padding < 16px

Không có không gian

24px horizontal

Căn lề không đều

Thiếu logic

4px grid system

Khoảng trắng quá lớn

UI bị vỡ

Scale có quy luật

4. CARDS ❌
Sai

Lý do

Đúng

Viền cứng (hard border)

Giống form, template

Không viền, dùng shadow

Vuông (radius 8-12px)

Quá cứng

Min 16px, tốt nhất 24px

Shadow đen mạnh (opacity > 10%)

Nặng nề

Opacity 4-8%, blur lớn

Tất cả card bằng nhau

Không có hierarchy

Featured > Secondary

Card có border xám

Lỗi thời

Chỉ dùng shadow mềm

5. BUTTONS & INPUTS ❌
Sai

Lý do

Đúng

Button vuông góc

Giống Bootstrap

Radius 16px hoặc pill

Input có gạch dưới (underline)

Material cũ

Container filled

Input trắng có viền xám

Form cũ

Filled #F1F5F9

Button quá nhỏ

Không touch-friendly

Height tối thiểu 48px

Tất cả button cùng màu

Không distinguish

Primary vs Secondary

6. NAVIGATION ❌
Sai

Lý do

Đúng

Navbar dính đáy màn hình

Nặng nề

Cách đáy 24px

Navbar nền đặc trắng

Đè hết content

Blur với opacity 0.9

Navbar hình chữ nhật

Giống tab bar cũ

Pill shape / Floating Island

Header flat (logo + text)

Không nổi bật

Floating + blur

Back button mặc định

Không premium

Icon nhỏ + text

7. MOTION ❌
Sai

Lý do

Đúng

Không có animation

UI tĩnh, nhàm chán

Subtle fade/slide

Animation quá nhanh

Cứng

Duration 300-500ms

Easing cứng

Thô

UseCurves.easeOutCubic

Không có stagger

List nhảy đột ngột

Staggered animation

Loading gif cổ

Lỗi thời

Shimmer hoặc skeleton

8. COMPOSITION ❌
Sai

Lý do

Đúng

Mọi thứ ngang hàng

Không có focus point

1 Hero element

Quá nhiều box nhỏ

Giống admin dashboard

Sử dụng list hoặc card lớn

Icon cùng kích thước

Thiếu hierarchy

Icons small, text larger

Ảnh tròn đều nhau

Boring

Kết hợp aspect-ratio

Không có empty state

UI trống không xử lý

Custom illustration

9. TỔNG HỢP ❌
Sai

Lý do

Đúng

Theo Material Design mặc định

Giống mọi app Android

Custom design system

Theo Admin Dashboard pattern

Giống web quản lý

Mobile-first thinking

Theo Flutter template cũ

Template bán trên mạng

Clean, premium

Copy app khác 100%

Legal issue

Lấy cảm hứng, không copy

Cố gắng làm "cool"

Trông rẻ

Minimal is premium

📋 PROMPT NEGATIVE TEMPLATE (Copy & Paste)
Khi viết prompt cho AI, hãy dán đoạn này vào đầu:

STRICT NEGATIVE CONSTRAINTS - DO NOT DO THESE:

❌ DON'T use bright purple (#8B5CF6), use #4F46E5 instead
❌ DON'T use pure black (#000000), use #0F172A instead
❌ DON'T use hard borders, use soft shadows
❌ DON'T make cards square, use 24px radius
❌ DON'T put navbar at very bottom, use floating style with 24px margin
❌ DON'T use all-bold text, create hierarchy with font weights
❌ DON'T use Material default icons, use outlined or minimal style
❌ DON'T make everything equal size, one hero, others smaller
❌ DON'T use gradient backgrounds
❌ DON'T use underline inputs
Follow these strictly. Violating any rule = fail.

✅ CÁCH TỔNG HỢP
Để AI tuân thủ, bạn cần:

Số lẻ = Sai → Dùng 4, 8, 16, 24, 32, 48
Viền cứng = Sai → Dùng shadow mềm
Trắng tinh = Sai → Dùng #F8FAFC
Flat = Sai → Dùng blur + floating
Đều nhau = Sai → Dùng hierarchy
Tóm lại: Negative examples giúp AI biết "TRÁNH", nhưng bạn cần cho nó biết cụ thể "THAY BẰNG CÁI GÌ" để nó làm đúng.


tôi nghĩ còn nhiều nữa bạn tiếp tục viết

Copy message
Edit message


Thought for a moment
📚 NEGATIVE EXAMPLES - BỔ SUNG (Tiếp theo)
10. ICONOGRAPHY ❌
Sai

Lý do

Đúng

Icon quá to (32px+)

Chiếm không gian, không premium

20-24px, text là chính

Icon filled đậm đều

Nặng nề

Outlined hoặc duotone

Icon không consistent style

Loạn

Dùng 1 bộ icon system

Icon màu đầy đủ

Rối mắt

Monochrome hoặc 2 màu

Icon không căn chỉnh

Lệch, thiếu chuyên nghiệp

Center hoặc baseline

Không có icon cho empty state

User không hiểu

Custom illustration icon

Dùng emoji thay icon

Không professional

Vector icon

11. LIST & REPEATER ❌
Sai

Lý do

Đúng

List không có separator

Không phân biệt item

Divider nhẹ hoặc spacing

Separator quá đậm

Làm gián đoạn visual flow

Opacity 10%

Item cao cố định quá (>120px)

Lãng phí không gian

Flex height

Pull-to-refresh mặc định

Không custom

branded animation

Infinite scroll không loading

User không biết còn data

Skeleton hoặc spinner

List không có empty state

Screen trống không giải thích

Illustration + text

Swipe action không có hint

User không biết có action

Visual indicator

12. IMAGES & MEDIA ❌
Sai

Lý do

Đúng

Ảnh bị vỡ scale

Ảnh méo, xấu

BoxFit.cover cứng

Placeholder là ảnh xám

Lộ, rẻ tiền

Blur placeholder hoặc skeleton

Aspect ratio không nhất quán

UI lệch

Lưới grid hoặc fixed ratio

Ảnh quá lớn (load chậm)

App ù ù

Compress hoặc lazy load

Gallery không preview

Không xem trước

Full screen tap

Video auto play không mute

Khó chịu

Always muted

Ảnh circle khi có text bên cạnh

Mất cân đối

Square hoặc rounded

13. INTERACTIVE STATES ❌
Sai

Lý do

Đúng

Không có tap feedback

User không biết đã tap

Ripple hoặc scale nhẹ

Loading state = biến mất

Nhảy layout

Skeleton hoặc spinner in place

Error state = just text

Không rõ lỗi gì

Icon + illustration + text

Disabled state không distinct

User không biết disabled

Opacity 50% hoặc grey

Success state chỉ có text

Không joyful

Animation hoặc checkmark

Hover state trên mobile

Không có

Tap state thay hover

14. FORMS & VALIDATION ❌
Sai

Lý do

Đúng

Validation sau khi submit

Quá trễ

Real-time validation

Error message không rõ

User không sửa được

"Email phải có @"

Error màu đỏ everywhere

Stress

Primary color cho error

Placeholder làm label

Mất khi focus

Floating label

Required field không mark

User không biết bắt buộc

Dấu * hoặc text

Keyboard type không đúng

User phải switch

Email - email, phone - number

Autofill không support

Nhập lại mệt

Autocomplete attributes

15. MODALS & BOTTOM SHEETS ❌
Sai

Lý do

Đúng

Modal hiện quá lớn (full screen)

Không context

Bottom sheet hoặc dialog

Bottom sheet không drag handle

Không biết kéo

Drag indicator

Modal không có close button

Không thoát được

X button + tap outside

Sheet background trắng tinh

Nổi bật quá

Semi-transparent

Sheet không rounded top

Thô

Radius 24px top

Modal animation quá mạnh

Giật

Fade + slide up nhẹ

Không dismiss được bằng swipe

Frustrating

Swipe to dismiss

16. SEARCH & FILTERS ❌
Sai

Lý do

Đúng

Search bar quá nhỏ

Khó tap

Min 48px height

Clear button không có

Xóa khó

X icon khi có text

Filter phải vào page mới

Quá nhiều tap

Bottom sheet hoặc chip

Filter không show active

Không biết đang filter

Highlight chip

Search không debounce

Gọi API liên tục

300ms debounce

No result = biến mất

User không biết

"Không tìm thấy" state

Recent search không lưu

Nhập lại

Show recent searches

17. EDGE CASES ❌
Sai

Lý do

Đúng

Long text không ellipsis

Vỡ layout

maxLines: 1, overflow: TextOverflow.ellipsis

Network error = crash

App dừng

Error state + retry

Offline không indication

User không biết

Banner hoặc icon

Data trống = crash

App dừng

Empty state

Date format không localization

Không quen

Dùng intl package

Currency không format

Đọc khó

1.000.000 ₫

Số điện thoại không link

Copy khó

Tap to call

18. CONSISTENCY ❌
Sai

Lý do

Đúng

Back button ở đâu cũng khác

Confusion

1 vị trí duy nhất

Cancel/Skip button không cùng screen

Không đối xứng

Cùng vị trí

Primary action thay đổi vị trí

Muscle memory fail

Right hoặc bottom cố định

Icon set không đồng nhất

Mix icons

1 bộ icons duy nhất

Spacing không consistent

Thiếu grid

Multiples of 4

19. ACCESSIBILITY ❌
Sai

Lý do

Đúng

Text contrast < 4.5:1

Không đọc được

Đảm bảo contrast ratio

Touch target < 48px

Khó tap

Min 48x48

Không có semantic

Screen reader fail

Semantics widget

Focus order không logical

Tab navigation lộn

Focus traversal

Font size < 14px

Quá nhỏ

Min 14px

Animation không tắt được

Epilepsy concern

prefers-reduced-motion

Color only làm meaning

Colorblind không hiểu

Icon + text

20. PERFORMANCE ❌
Sai

Lý do

Đúng

Large list không lazy load

Chậm

ListView.builder

Image không cache

Load lại mỗi lần

Cached network image

Rebuild toàn widget

Chậm

const, useMaterial3 optimization

Animation trên main isolate

Giật

Use TickerMode

API không cancel

Memory leak

Cancel token

21. ANIMATION ❌
Sai

Lý do

Đúng

Animated quá nhanh (<200ms)

Không thấy

300-500ms

Animated quá chậm (>800ms)

Chậm

Duration tùy context

EasingDefault

Thô

Curves.easeOutCubic

Stagger delay = 0

Nhảy đồng loạt

50-100ms delay

Animating property không nên

Opacity + scale nhẹ

Tránh transform lớn

Background color animate

Expensive

Opacity thay màu

22. DATA PRESENTATION ❌
Sai

Lý do

Đúng

Number lớn không format

1000000

1,000,000 hoặc 1M

Date hiển thị T12/01/2024

Không quen

"Hôm qua" hoặc "2 giờ trước"

Percentage không context

85%

"85% hoàn thành"

Boolean = check/x

Không universal

Yes/No hoặc Icon

Enum = số

Không đọc được

Text label

23. PROGRESS & FEEDBACK ❌
Sai

Lý do

Đúng

Progress bar không có label

Không biết đang làm gì

"% đã tải"

Linear progress không animate

Đứng yên

Indeterminate hoặc animate

Skeleton không match content

Placeholder sai

Fake data layout

Shimmer angle 45deg

Template feel

30deg hoặc -30deg

Circular progress quá nhỏ

Không thấy

Min 64px

24. NAVIGATION PATTERNS ❌
Sai

Lý do

Đúng

Deep link không handle

Lỗi app

Deep link handling

Hardware back exit app

Mất state

Confirm dialog

Tab + floating action clash

Overlap

Dưới tab hoặc hide tab

Nest navigation quá sâu

Confusing

Max 3 levels

Swipe back không enable

Không intuitive

Enable swipe back

25. CONTENT ❌
Sai

Lý do

Đúng

Lorem ipsum để đấy

Không hình dung

Realistic text

Copy viết tắt không giải thích

Không hiểu

Full text hoặc tooltip

Help text quá dài

Không đọc

Short + "Tìm hiểu thêm"

Error code hiển thị user

Không cần

User-friendly message

Placeholder không có hướng dẫn

Không biết nhập gì

"Nhập email của bạn"

26. VISUAL DETAILS ❌
Sai

Lý do

Đúng

Devider 1px

Quá mảnh

0.5px, opacity 10%

Status bar color không match

Lệch màu

Same as app

Safe area không handle

Bị che

SafeArea widget

Notch không handle

Chặt màn

SafeArea

Keyboard không push content

Che input

resizeToAvoidBottomInset

Overscroll không custom

Bounce mặc định

Custom glow

27. ONBOARDING ❌
Sai

Lý do

Đúng

Onboarding quá dài (>5 slide)

Drop off

Max 3-4 slides

Skip button không nổi bật

Không skip được

Clear skip option

Dots indicator quá to

Distract

Small dots

Animation tự động quá nhanh

Không đọc kịp

User-controlled swipe

Continue không indicate

Không biết next

Arrow hoặc button

Close = skip all

Confusing

Clear flow

28. PROFILE & SETTINGS ❌
Sai

Lý do

Đúng

Avatar quá nhỏ

Không thấy

Min 80px

Avatar không có placeholder

Vỡ

Initials hoặc icon

Setting tile có border

Form feel

No border

Switch không có label

Không biết toggle cái gì

Label + switch

29. CHARTS & GRAPHS ❌
Sai

Lý do

Đúng

Chart quá nhiều màu

Rối

Max 4-5 màu

Legend không click

Không filter

Interactive legend

Tooltip quá nhỏ

Không đọc

Sized properly

No data = blank

Không info

"Không có dữ liệu" state

30. NOTIFICATIONS ❌
Sai

Lý do

Đúng

Toast quá lâu (>3s)

Khó chịu

3s max

Toast không dismiss

Stuck

Auto dismiss

Notification quá nhiều

Spamming

Batch notifications

Sound không option

Disturbing

Settings to toggle

📋 FULL PROMPT TEMPLATE
FULL NEGATIVE CONSTRAINTS:

Colors:

❌ Don't use bright purple #8B5CF6 → Use #4F46E5
❌ Don't use pure black #000000 → Use #0F172A
❌ Don't use pure white background → Use #F8FAFC
❌ Don't use gradient backgrounds
Typography:

❌ Don't use all-bold text
❌ Don't use all caps for body
❌ Don't use font size < 14px
❌ Don't use letter spacing < 0 for body
❌ Don't use line height < 1.2
Spacing:

❌ Don't use odd numbers (13, 27) → Use multiples of 4
❌ Don't use padding < 16px
❌ Don't use border-radius < 16px
❌ Don't use hard borders
Components:

❌ Don't use underline inputs
❌ Don't use standard Material buttons
❌ Don't put navbar at very bottom edge
❌ Don't use square buttons
❌ Don't use skeleton that doesn't match layout
Motion:

❌ Don't use duration < 200ms
❌ Don't use duration > 800ms
❌ Don't use Curves.default
Lists:

❌ Don't use standard ListView for large data
❌ Don't show empty state as blank
Images:

❌ Don't use BoxFit.fill for aspect ratio content
❌ Don't leave broken images
❌ Don't load full res images
Accessibility:

❌ Don't use touch targets < 48px
❌ Don't use contrast ratio < 4.5:1
Follow these rules strictly. Any violation = regenerate.

✅ TỔNG KẾT NEGATIVE EXAMPLES
STT

Danh mục

Số lỗi

1

Màu sắc

5

2

Typography

6

3

Spacing & Layout

5

4

Cards

5

5

Buttons & Inputs

5

6

Navigation

6

7

Motion

5

8

Composition

5

9

Tổng hợp

5

10

Iconography

7

11

Lists

7

12

Images

7

13

Interactive States

6

14

Forms & Validation

7

15

Modals & Sheets

7

16

Search & Filters

7

17

Edge Cases

7

18

Consistency

5

19

Accessibility

7

20

Performance

5

21

Animation

6

22

Data Presentation

5

23

Progress & Feedback

5


tiếp tục

Copy message
Edit message


Thought for a moment
📚 NEGATIVE EXAMPLES - PHẦN 3 (Tiếp theo)

31. EMPTY STATES ❌
Sai

Lý do

Đúng

Empty = thông báo text

User không hình dung

Illustration + text

Illustration quá lớn

Chiếm quá nhiều space

Max 40% height

Không có action

User stuck

"Tạo mới" button

Empty state giống error

Confusing

Different visual

Không clear context

User không biết empty gì

Title rõ ràng

32. LOADING STATES ❌
Sai

Lý do

Đúng

Loading = spinner tròn

Cổ điển, nhàm chán

Shimmer skeleton

Skeleton không match layout

Không predict được

Exact same layout

Loading text không rõ

User không biết đang load

"Đang tải..." hoặc skeleton

Infinite spinner

User nghĩ app crash

Progress % hoặc skeleton

Nhiều loading cùng lúc

Confusing

1 global loading

33. ERROR STATES ❌
Sai

Lý do

Đúng

Error chỉ có text

Không rõ lỗi gì

Icon + illustration + text

Error message dev

Không user-friendly

"Connection timeout" → "Không kết nối được"

Retry không có

User stuck

Retry button

Error giống empty

Confusing

Different visual

Error không log

Không debug được

Log error code

34. SUCCESS STATES ❌
Sai

Lý do

Đúng

Success chỉ có text

Không joyful

Animation hoặc checkmark

Success không auto dismiss

Stuck

Auto dismiss hoặc navigate

Success vibration mặc định

Có thể không muốn

Optional

Không redirect

User không biết làm gì tiếp

Navigate hoặc guide

35. DEBUG/DEV UI ❌
Sai

Lý do

Đúng

Show dev data user

Leak information

Hide dev markers

Console log không clean

Không để production

Remove logs

Test endpoints

User không dùng được

Use production API

Mock data không remove

Không real

Use real data

Dev flag không remove

Security risk

Clean build

36. DARK MODE ❌
Sai

Lý do

Đúng

Black background (#000000)

Quá contrast

#121212 hoặc #1E1E1E

Light text on dark

Không contrast

#E2E8F0

Không handle toggle

Chỉ có light

System + Manual toggle

Colors không invert

Colors lỗi

Invert hoặc define dark palette

Card trắng trên dark

Óc chèo

Dark card color

37. RESPONSIVE LAYOUT ❌
Sai

Lý do

Đúng

Fix width

Không responsive

Flexible hoặc max width

Scroll ngang

Không mobile-friendly

Vertical list

Element fit không đều

Vỡ layout

Flexible grid

Text overflow

Vỡ giao diện

Ellipsis hoặc wrap

Breakpoint không handle

Lỗi trên tablet

Define breakpoints

38. TAB BAR ❌
Sai

Lý do

Đúng

Tab bar > 5 items

Crowded

Max 5

Tab label dài

Cắt

Truncate hoặc icon only

Tab active không highlight

User không biết đang ở đâu

Color + indicator

Tab swipe không enable

Không intuitive

Swipeable tabs

Tab badge quá to

Distract

Small badge

39. ACTION SHEETS & MENUS ❌
Sai

Lý do

Đúng

Menu quá dài

Hard to find

Max 6-7 items

Menu item không có icon

Không distinguish

Icon + text

Destructive không đỏ

User không biết danger

Red color

Menu không positioned

Không anchor

Relative to trigger

Menu animation không smooth

Giật

Fade + scale

40. CHIPS & TAGS ❌
Sai

Lý do

Đúng

Chip quá to

Chiếm space

Min height 32px

Chip selected không rõ

Không biết đang active

Background change

Chip không removable

Stuck

X button

Chip quá nhiều

Wrap không đẹp

Max 3-4 + "more"

Chip không clickable

Không interactive

tappable

41. TOOLTIPS ❌
Sai

Lý do

Đúng

Tooltip không auto dismiss

Stuck

2-3s auto dismiss

Tooltip quá nhỏ

Không đọc được

Min width + padding

Tooltip không positioned

Che content

Auto position

Tooltip trigger khó

User không biết hover

Show on tap too

Dev tooltips để production

Lộ

Remove in prod

42. KEYBOARDS ❌
Sai

Lý do

Đúng

Keyboard che input

User không thấy

Scroll into view

Return không submit

User phải tap button

Submit on return

Keyboard type sai

Wrong keyboard

Email → email, number → number

Toolbar không custom

Không có shortcuts

Custom toolbar

Dismiss không work

Stuck

Tap outside dismiss

43. PULL TO REFRESH ❌
Sai

Lý do

Đúng

Indicator quá to

Distract

Minimal spinner

Custom indicator không standard

User không biết pull

Standard or consistent

Refresh không cancel

Pull không stop

Cancel on release

Overscroll không handle

Bounce không custom

Custom overscroll

RTL không handle

Lỗi

Flip indicator

44. INFINITE SCROLL ❌
Sai

Lý do

Đúng

Load more button only

Không auto

Auto load on scroll

Scroll position không save

Lại từ đầu

Maintain position

Nhiều requests cùng lúc

Duplicate

Prevent duplicate

End of list không detect

Load mãi

Detect end

Cache không handle

Cũ data

Update + show new

45. AVATARS ❌
Sai

Lý do

Đúng

Placeholder giống broken

User nghĩ lỗi

Initials hoặc icon

Avatar không rounded

Thô

Circle hoặc rounded

Avatar quá lớn

Chiếm space

Max 120px

Avatar không lazy load

Chậm init

Image cache

Avatar click không preview

Không xem

Tap full size

46. BADGES & COUNTS ❌
Sai

Lý do

Đúng

Badge quá to

Distract

Max 20px

Badge không truncate

100+ = "100"

99+

Badge overflow không handle

Badge vỡ

Position adjust

Red dot không có meaning

User không biết gì mới

Badge count

Badge không dismiss

Stuck

Auto dismiss on read

47. DIVIDERS & SEPARATORS ❌
Sai

Lý do

Đúng

Divider quá đậm

Visual noise

Opacity 10-20%

Divider có màu

Không neutral

Grey tone

Divider position không consistent

Lệch

Full width hoặc inset

Grouped divider không inset

Form feel

Inset 16px

Divider animation

Expensive

Static

48. DRAWER & SIDE MENU ❌
Sai

Lý do

Đúng

Drawer quá rộng

Chiếm quá nhiều

Max 80% width

Drawer header không sticky

Scroll mất header

Sticky header

Menu item không selected

User không biết ở đâu

Highlight selected

Drawer không close on tap outside

Stuck

Tap outside close

Back swipe không open

Không intuitive

Enable edge swipe

49. TIMELINE ❌
Sai

Lý do

Đúng

Line không connect

Không timeline feel

Vertical line

Dot không position

Lệch

Center aligned

Past/future không distinguish

Không chronological

Different colors

Animation không stagger

Nhảy đồng loạt

Staggered

Scroll không auto scroll

Không follow

Auto scroll to current

50. WALLET & PAYMENT UI ❌
Sai

Lý do

Đúng

Card number không mask

Security risk

•••• •••• •••• 1234

CVV không hidden

Security risk

Hidden by default

Expiry format không standard

Confusion

MM/YY

Payment logo không resize

Logo lệch

Fixed size

Success không animation

Không satisfying

Checkmark animation

51. AUDIO/VIDEO CONTROLS ❌
Sai

Lý do

Đúng

Controls auto hide

User không biết có controls

Show on tap

Scrubber không preview

Không drag được

Preview on scrub

Volume không show

User không biết adjust

Show volume

Fullscreen không toggle

Không fullscreen

Toggle button

Playback speed không options

User không adjust

Speed options

52. MAPS & LOCATION ❌
Sai

Lý do

Đúng

Map không load permission

App crash

Handle permission

Marker không cluster

Map chậm

Cluster markers

Current location không highlight

User không biết

Blue dot + accuracy

Map controls không position

UI lệch

Position + style

Directions không calculate

Không route

Calculate + display

53. QR & BARCODE ❌
Sai

Lý do

Đúng

Scanner không guide

User không biết scan

Scan frame

Light on by default

Drain battery

Manual toggle

Flash không off

Blind user

Auto off

Success vibration không indicate

User không biết success

Haptic + visual

Copy không confirm

User không biết copied

Toast confirm

54. FILE UPLOAD ❌
Sai

Lý do

Đúng

No file type restriction

Dangerous

Restrict types

Size limit not shown

User không biết limit

Show limit

Upload progress không show

User không biết đang up

Progress bar

Cancel upload không enable

Stuck

Cancel button

Preview không show

User không biết file gì

Thumbnail

55. MULTIMEDIA MESSAGING ❌
Sai

Lý do

Đúng

Image không compress

Slow send

Compress before send

Video không transcode

Fail to send

Transcode first

Send button không disable

Multi send

Disable while sending

Delivery status không show

User không biết gửi được

Status indicators

Retry không auto

Fail = lost

Auto retry

56. CHAT & MESSAGES ❌
Sai

Lý do

Đúng

Message bubble không timestamp

User không biết giờ

Show time

Date separator không sticky

Scroll = mất date

Sticky date

Typing indicator không standard

User không biết

3 dots animation

Read receipt không optional

Privacy

User setting

Scroll to bottom không available

Không jump

FAB scroll

57. NOTIFICATIONS & PERMISSIONS ❌
Sai

Lý do

Đúng

Permission popup immediate

User block

Explain first

Permission denied không handle

App break

Handle fallback

Local notification không scheduled

User không nhớ

Schedule ahead

Notification category không

Can't action

Categories + actions

Badge không update

Wrong count

Sync with server

58. ANALYTICS & EVENTS ❌
Sai

Lý do

Đúng

Event không track

No data

Track key events

Sensitive data track

Privacy

Strip PII

Duplicate events

Inflated data

Deduplicate

Custom event không name

Confusion

Consistent naming

User property không set

No segmentation

Set user properties

59. FEATURE FLAGS & CONFIG ❌
Sai

Lý do

Đúng

Hardcoded configs

No flexibility

Remote config

Feature flag không default

Crash risk

Default = off

Flag không cleanup

Dead code

Remove old flags

Config không version

Conflict

Version configs

Fallback không handle

Crash

Default values

60. DEEPLINKS & URLS ❌
Ai

Lý do

Đúng

URL scheme không unique

Conflict

Custom scheme

Universal link không verify

Not working

App association

Deferred deep link

No handling

Handle on start

Link không expires

Security

Expiration

Redirect không handle

Loop

Handle redirects

61. SECURITY & PRIVACY ❌
Sai

Lý do

Đúng

Token không storage

Lost on close

Secure storage

Sensitive log

Leak

Remove logs

HTTPS không enforce

Insecure

Force HTTPS

Biometric không optional

Privacy

Allow fallback

PII không mask

Privacy

Mask in UI

62. CACHING STRATEGY ❌
Sai

Lý do

Đúng

No cache

Slow load

Cache strategy

Cache không invalidate

Stale data

Expire policy

Cache size unlimited

Storage full

Max size

Cache không fallback

No data

Fallback to network

Image cache không clear

Storage full

Clear policy

63. NETWORK HANDLING ❌
Sai

Lý do

Đúng

Retry không exponential

Hammer server

Exponential backoff

Timeout không handle

Stuck

Timeout + retry

Offline không detect

App crash

Check connectivity

Request queue không

Race condition

Queue + execute

Response không parse safely

Crash

Try-catch

64. STATE MANAGEMENT ❌
Sai

Lý do

Đúng

State in widget

Prop drilling

Global state

Loading/error không handle

Blank screen

Handle states

Optimistic update không revert

Wrong data

Revert on fail

State không persist

Lose on close

Persist state

Unsubscribed still fire

Memory leak

Handle dispose

65. DEPENDENCY INJECTION ❌
Sai

Lý do

Đúng

Singleton everywhere

Test khó

Inject everywhere

Static reference

Coupling

Interface injection

DI không dispose

Memory leak

Dispose

Mock không possible

Test khó

Interface

Circular dependency

Crash

Resolve

66. TESTING UI ❌
Sai

Lý do

Đúng

No test automation

Regression

Automate tests

Test không isolation

Flaky

Mock dependencies

Snapshot không update

Fail

Update snapshots

Accessibility không test

A11y issues

Test a11y

Performance không measure

Slow

Benchmark

67. LOCALIZATION ❌
Sai

Lý do

Đúng

Hardcoded string

Can't translate

Use keys

Date format không locale

Wrong format

Use locale

Number format không locale

Wrong format

Use locale

RTL layout không handle

Lỗi

Handle RTL

String concatenation

Order issue

Named parameters

68. VERSIONING & DEPLOYMENT ❌
Sai

Lý do

Đúng

Version không show

No version info

Show in settings

Changelog không show

User không biết

Show on update

Force update tidak ada

Old version

Force update

Rollback tidak ada

Bad release

Rollback plan

Feature deprecation

User confused

Deprecation notices

69. MAINTENANCE & MONITORING ❌
| Sai | Lý do | Đúng


tiếp tục

Copy message
Edit message


Thought for a moment
📚 NEGATIVE EXAMPLES - PHẦN 4 (Tiếp theo)

69. MAINTENANCE & MONITORING ❌
Sai

Lý do

Đúng

No crash reporting

Không biết crash

Crashlytics/Sentry

Logs không collect

No insights

Centralized logging

Performance không monitor

Slow but don't know

APM tool

No health check endpoint

Can't monitor

Health endpoint

Alert không threshold

Alert fatigue

Define thresholds

Dashboard không real-time

Stale data

Real-time dashboard

No degradation strategy

Fail = down

Degradation plan

70. DELEGATION & RESPONSIBILITIES ❌
Sai

Lý do

Đúng

Singleton pattern overuse

Khó test

Dependency injection

Static methods everywhere

Khó mock

Instance methods

Global variables

Race conditions

State management

Tight coupling

Khó maintain

Loose coupling

No interface

Khó swap

Use interfaces

Circular dependencies

Crash

Remove cycles

God class/function

Khó understand

Single responsibility

71. CODE ORGANIZATION ❌
Sai

Lý do

Đúng

All code in one file

Khó navigate

Feature-based folders

No naming convention

Confusion

Naming standards

Comment everywhere

Noise

Self-documenting code

No folder structure

Chaos

Clean architecture

Mixed responsibilities

Hard to find

Organized by feature

Dead code không remove

Bloat

Remove unused

File name không descriptive

"Utils.dart"

Feature naming

72. API DESIGN ❌
Sai

Lý do

Đúng

REST không standard

Confusion

Follow REST

No versioning

Breaking changes

Version in URL

No pagination

Slow response

Pagination

No error structure

No handling

Standard error JSON

No request validation

Invalid data

Validate request

Response không consistent

Hard to parse

Consistent schema

No rate limiting

Abuse

Implement rate limit

GraphQL n+1 queries

Slow

Dataloader

73. DATABASE ❌
Sai

Lý do

Đúng

No indexing

Slow queries

Index columns

Queries in loop

N+1 problem

Batch queries

No migrations

Schema conflicts

Versioned migrations

Sensitive data không encrypt

Security risk

Encrypt at rest

No backup

Data loss

Regular backups

No connection pooling

Connection exhaustion

Pool config

Migration không reversible

Rollback risk

Up/Down scripts

74. AUTHENTICATION ❌
Sai

Lý do

Đúng

Password không hash

Security risk

bcrypt/argon2

Token không expire

Security risk

Short expiry

JWT không signed

Tampering

Signed JWT

No refresh token

Session expire

Refresh token

Credentials in URL

Leaked

POST body

No account lockout

Brute force

Lockout policy

2FA không optional

UX friction

Optional 2FA

75. AUTHORIZATION ❌
Sai

Lý do

Đúng

All admin

Security risk

Role-based

No permission check

Access control fail

Check permissions

Front-end only check

Bypassable

Backend check

IDOR vulnerability

Access other data

Verify ownership

No audit trail

No accountability

Log actions

Permission không hierarchical

Complexity

RBAC/ABAC

76. LOGGING ❌
Sai

Lý do

Đúng

No logging

No visibility

Log important events

Log everything

Noise

Log meaningful

Sensitive data in log

Leak

Mask PII

Console.log in production

Performance

File/remote logging

No log level

Can't filter

Use levels

No structure

Can't parse

JSON structure

Log không searchable

Useless

Searchable format

77. CRASH HANDLING ❌
Sai

Lý do

Đúng

No try-catch

Crash app

Handle exceptions

Catch all = hide errors

Silent failures

Specific handling

Crash không report

No fix

Crash reporting

No user message

Confusion

User-friendly message

Recovery không attempt

Stuck state

Recovery options

Stack trace to user

Scary

Hide details

78. MEMORY MANAGEMENT ❌
sai

Lý do

Đúng

Undisposed streams

Memory leak

Close streams

List không limit

Memory bloat

Paginate/limit

Image không dispose

Memory leak

Dispose image

Closure references

Memory leak

Weak references

Large object in memory

OOM

Release unused

No memory monitoring

Hidden leak

Monitor memory

79. THREADING & CONCURRENCY ❌
Sai

Lý do

Đúng

UI thread work

ANR

Background thread

Shared mutable state

Race conditions

Immutable

No synchronization

Data corruption

Synchronize

Blocking UI

Frozen app

Async/await

Thread không pool

Thread overhead

Use executor

Deadlock

App freeze

Avoid lock ordering

Future không handle

Unhandled

Chain properly

80. ERROR HANDLING ❌
Sai

Lý do

Đúng

Empty catch

Silent fail

Log or handle

Throw generic

No handling

Specific exceptions

Error không user message

Confusion

User-friendly errors

No error recovery

Stuck

Provide alternatives

Error swallowing

Hidden bugs

Log and rethrow

Stack trace exposed

Security

Hide details

81. CONFIGURATION ❌
Sai

Lý do

Đúng

Hardcoded config

No flexibility

Remote config

API keys in code

Security risk

Environment variables

No staging config

Testing issues

Environment-specific

Config not documented

Unknown

Document configs

No default config

Crash

Default values

Config không validate

Invalid config

Schema validation

Config in database

Slow read

Environment/env vars

82. BUILD & DEPLOYMENT ❌
Sai

Lý do

Đúng

Manual build

Error-prone

CI/CD pipeline

No build caching

Slow builds

Cache dependencies

Debug build production

Performance

Release build

No signing config

Security

Configure signing

Build không reproducible

Inconsistent

Lock dependencies

Large APK/AAB

Slow download

Proguard/shake

Assets không optimize

Large size

Compress assets

83. DOCUMENTATION ❌
Sai

Lý do

Đúng

No README

No context

Setup instructions

Outdated docs

confusion

Keep updated

API không documented

Hard to use

API docs

No code comments

Hard to understand

Explain why

No architecture doc

No overview

Architecture docs

Docs only in head

Lost knowledge

Write docs

No changelog

User không biết

Keep changelog

84. CODE REVIEW ❌
Sai

Lý do

Đúng

No code review

Low quality

Required review

Review không thorough

Bugs

Review checklist

Nitpicking

Wasted time

Focus critical

No review guidelines

Inconsistent

Guidelines

Self-approve

No check

Require approval

Review delayed

Blocked

Quick turnaround

85. VERSION CONTROL ❌
Sai

Lý do

Đúng

No .gitignore

Unwanted files

Configure ignores

Large commits

Hard to review

Atomic commits

No branch strategy

Chaos

Feature branches

Merge conflicts often

Wasted time

Keep updated

Commit messages không meaningful

Hard to trace

Semantic messages

Direct push to main

No review

PR workflow

Forget to commit

Lost work

Regular commits

86. REFACTORING ❌
Sai

Lý do

Đúng

Never refactor

Tech debt

Scheduled refactor

Big refactor

Risky

Incremental

No tests refactor

Breakage

Test coverage

Refactor without reason

Waste

Clear goal

Keep broken windows

Tech debt

Fix immediately

Duplicate code

Maintenance

DRY principle

87. DEBT MANAGEMENT ❌
Sai

Lý do

Đúng

Ignore tech debt

Slowdown

Track debt

No debt backlog

Unknown

Backlog items

Debt priority low

Never fix

Prioritize

Quick fix everywhere

Accumulation

Proper fix

No code ownership

No ownership

Assign owners

Dead code

Bloat

Clean up

88. SECURITY ❌
Sai

Lý do

Đúng

SQL injection

Hack

Parameterize

XSS không sanitize

Script injection

Sanitize

CSRF không token

Attack

CSRF token

Sensitive in URL

Leaked

POST body

No input validation

Injection

Validate all

Outdated dependencies

Vulnerable

Update

No security review

Unknown

Regular audit

89. COMPLIANCE ❌
Sai

Lý do

Đúng

No GDPR compliance

Legal risk

GDPR compliance

No consent

Privacy violation

Consent mechanism

Data retention no rule

Storage bloat

Retention policy

User data không delete

Privacy

Right to delete

No privacy policy

Legal

Post policy

Cookies không consent

Compliance

Cookie consent

Data not anonymized

PII risk

Anonymize

90. USER RESEARCH ❌
Sai

Lý do

Đúng

No user research

Wrong features

User interviews

Assumption only

No validation

Test with users

No beta program

Bugs in prod

Beta testing

No feedback mechanism

No insight

Feedback collection

Analytics only

No context

Qualitative + quantitative

Ignore user complaints

Churn

Address complaints

No usability testing

Hard to use

Regular testing

91. ONCALL & SUPPORT ❌
Sai

Lý do

Đúng

No oncall

No response

Oncall rotation

No runbook

No guidance

Document procedures

Alert fatigue

Ignored alerts

Tune alerts

No escalation

Stuck

Escalation path

No SLA

No commitment

Define SLA

Outage không post-mortem

Repeat

Post-mortem

92. TECH SPEC & PLANNING ❌
Sai

Lý do

Đúng

No spec

Scope creep

Write spec

Spec outdated

Confusion

Keep updated

Spec != code

Mismatch

Sync

No technical review

Fail

Review spec

Over-engineering

Waste

Simple solution

Under-engineering

Issues later

Proper design

No alternatives

Not optimal

Compare options

93. FEATURE FLAGS ❌
Sai

Lý do

Đúng

No feature flags

Full release

Gradual rollout

Flag = forever

Dead code

Remove old flags

No user targeting

Can't test

Targeting

No gradual rollout

Risk

1-10-50-100%

Flag không track

No visibility

Track metrics

No kill switch

Can't disable

Emergency kill

94. A/B TESTING ❌
Sai

Lý do

Đúng

No A/B testing

No data

Run experiments

Test duration short

Invalid

Run long enough

No statistical significance

Noise

Significant sample

Test too many

Confounding

One variable

Ignore negative results

Confirmation bias

Accept results

No hypothesis

Random

Clear hypothesis

95. INCIDENT RESPONSE ❌
Sai

Lý do

Đúng

No incident process

Panic

Defined process

No communication

User confusion

Updates

No root cause

Repeat

Post-mortem

Blame culture

Hidden issues

Blameless

No incident tracking

Lost

Document

96. RELEASE PROCESS ❌
Sai

Lý do

Đúng

Release anytime

Confusion

Cadence

No release notes

User confusion

Changelog

No rollback plan

Stuck

Rollback capability

Release Friday

Weekend issues

Safe release day

No canary

Fail fast

Canary

No feature freeze

Unstable

Feature freeze

97. DEPENDENCY MANAGEMENT ❌
Sai

Lý do

Đúng

No lock file

Inconsistent

Lock dependencies

Outdated dependencies

Bugs/vulnerabilities

Update regular

Unused dependencies

Bloat

Clean up

Major version upgrades

Breaking

Incremental

No vulnerability scan

Security risk

Regular scan

Private dependencies

Risk

Audit packages

98. ACCESSIBILITY ❌
Sai

Lý do

Đúng

Focus not visible

Can't navigate

Visual focus

No keyboard nav

Can't use

Keyboard support

Screen reader not supported

A11y issue

Semantics

Color meaning only

Colorblind

Icon + color

No skip links

Wasted navigation

Skip links

Animations not pause

A11y issue

Pause option

Touch target too small

Hard to tap

Min 48px

99. PERFORMANCE ❌
Sai

Lý do

Đúng

No performance goals

No target

Define goals

No profiling

Don't know slow

Profile

Large bundle

Slow load

Split code

No lazy loading

Slow init

Lazy load

Memory leaks

OOM

Fix leaks

Main thread blocking

ANR

Background work

Inefficient layouts

Slow render

Optimize

100. FINAL CHECKLIST ❌
Sai

Lý do

Đúng

No code climate

Low quality

Quality gates

Security not a priority

Vulnerable

Security first

Tech debt ignored

Slowdown

Track & fix

No observability

Blind

Logging + metrics

No user empathy

User issues

User focus

No team syncs

Misaligned

Regular syncs

No training

Skill gaps

Learning

📋 TỔNG KẾT NEGATIVE EXAMPLES THEO NHÓM
STT

Nhóm

Số lỗi

1

Màu sắc

5

2

Typography

6

3

Spacing & Layout

5

4

Cards

5

5

Buttons & Inputs

5

6

Navigation

6

7

Motion

5

8

Composition

5

9

Tổng hợp

5

10

Iconography

7

11

Lists

7

12

Images

7

13

Interactive States

6

14

Forms & Validation

7

15

Modals & Sheets

7

16

Search & Filters

7

17

Edge Cases

7

18

Consistency

5

19

Accessibility

7

20

Performance

5

21

Animation

6

22

Data Presentation

5

23

Progress & Feedback

5

24

Navigation Patterns

5

25

Content

5

26

Visual Details

6

27

Onboarding

5

28

Profile & Settings

5

29

Charts & Graphs

5

30

Notifications

5

31

Empty States

5

32

Loading States

5

33

Error States

5

34

Success States

4

35

Debug/Dev UI

5

36

Dark Mode

5

37

Responsive Layout

5

38

Tab Bar

5

39

Action Sheets

5

40

Chips & Tags

5

41

Tooltips

5

42

Keyboards

5

43

Pull to Refresh

5

44

Infinite Scroll

5

45

Avatars

5

46

Badges & Counts

5

47

Dividers

5

48

Drawer & Side Menu

5

49

Timeline

5

50

Wallet & Payment

5

51

Audio/Video Controls

5

52

Maps & Location

5

53

QR & Barcode

5

54


tiếp

Copy message
Edit message


Thought for a moment
📚 NEGATIVE EXAMPLES - PHẦN 5 (Tiếp theo)
101. E-COMMERCE ❌
Sai

Lý do

Đúng

Add to cart không feedback

User không biết

Animation + toast

Price không format

Không đọc được

1.000.000 ₫

Original price không visible

Không biết sale

Strikethrough

Out of stock không indicate

User không biết

Disabled + text

Variant không preview

Không thấy màu

Image gallery

Cart không persist

Mất khi reload

Save cart

Checkout quá bước

Drop off

One/two step

No guest checkout

Barrier

Guest option

No order tracking

Không biết đâu

Tracking page

Return policy không visible

Không rõ

Policy page

No wishlist

Không save

Wishlist feature

No recently viewed

Không nhớ

History

102. PRODUCT DETAIL ❌
Sai

Lý do

Đúng

Image không zoom

Không xem

Pinch to zoom

Description quá ngắn

Không thuyết phục

Full description

Specification không table

Không clear

Table format

Reviews không real

Fake reviews

Verified

Rating distribution không show

Không đánh giá được

Distribution chart

Related products không

No cross-sell

Related

No video

Không thấy thực tế

Video

Size chart không

Fit không đúng

Size chart

Stock không real-time

Hết hàng

Real-time

Social share không

Không share

Share buttons

103. SEARCH & DISCOVERY ❌
Sai

Lý do

Đúng

Search results không sort

Không find

Sort options

Filters không apply

Không filter

Instant apply

No autocomplete

Slow

Autocomplete

Search không typo

Không find

Fuzzy search

No trending searches

Không gợi ý

Trending

Category không tree

Hard to navigate

Tree

No breadcrumb

Lost

Breadcrumb

Grid/list toggle không

Không switch

Toggle

No clear all filters

Stuck

Clear all

Results count không

Không biết bao nhiêu

Show count

104. CART & CHECKOUT ❌
Sai

Lý do

Đúng

No order summary

Không xem

Expandable

Shipping cost không show

Surprise

Show upfront

Promo code không show

Không enter

Input field

Guest checkout không

Barrier

Continue as guest

Payment methods limited

Payment fail

Multiple methods

No express checkout

Slow

Express option

Address không validate

Wrong address

Validate

Order confirmation không

Không confirm

Confirmation

No email confirmation

Không biết

Email

Payment fail không clear

Confusion

Clear error

105. USER ACCOUNTS ❌
Sai

Lý do

Đúng

Password không strength

Weak password

Strength indicator

Email không verify

Unverified

Verify email

No password reset

Locked out

Reset flow

Profile không complete

Missing info

Progress

No account deletion

Retention

Delete option

Login không social

Slow

Social login

Session không expire

Security

Auto expire

Multiple devices không show

Security

Device list

No activity log

Security

Activity log

Account merge không

Split

Merge option

106. REVIEWS & RATINGS ❌
Sai

Lý do

Đúng

Rating only = stars

Không rõ

Stars + text

Review moderation

Bad reviews

Moderate

No photo reviews

Fake

Photo reviews

Review sorting

Không useful

Sort by helpful

No Q&A

Questions

Q&A

Incentivized review

Bias

Disclosure

Review limit

Limited

No limit

Selfreview

Fake

Verified

107. SHIPPING & FULFILLMENT ❌
Sai

Lý do

Đúng

Tracking không update

Stuck

Push update

Delivery estimate không

Customer hỏi

Estimate

No free shipping threshold

Không trigger

Threshold

Shipping options không clear

Confusing

Clear options

No pickup option

No choice

Pickup

International không clear

Confusion

Country info

Shipping calculator không

Slow

Calculator

Label print không

Print

Instructions

No signature required

Security

Option

108. REFUNDS & RETURNS ❌
Sai

Lý do

Đúng

Return policy không rõ

Dispute

Clear policy

Return label không

Hủy

Print label

Return status không update

Stuck

Track return

Refund method không

Surprise

Method options

Refund timeline không

Impatient

Timeline

No store credit

Options

Credit option

Restocking fee không

Surprise

Disclose

109. LOYALTY & REWARDS ❌
Sai

Lý do

Đúng

Points không show

Không biết

Display balance

Points expiry không warn

Surprise

Warning

Rewards không relevant

No interest

Personalized

Tier benefits không clear

Confusion

Benefits list

Points value không

Không hiểu

Value explanation

Referral reward không

No growth

Referral program

Redemption options limited

Limited

Options

110. SOCIAL FEATURES ❌
Sai

Lý do

Đúng

No social login

Friction

Social login

Share không native

Không share

Native share

No activity feed

Dead

Feed

Followers count không

No social proof

Show count

No notifications

Dead

Alerts

Block/report không

Harassment

Options

Privacy settings limited

Privacy

Settings

No messaging

Isolation

Chat

No groups/community

Isolation

Groups

111. CONTENT CREATION ❌
Sai

Lý do

Đúng

Editor limited

Hard to edit

Rich editor

Draft không save

Lost

Auto save

No undo/redo

Mistakes

Undo/redo

Media upload slow

Upload

Batch upload

No auto crop

Wrong

Auto adjust

No filters

Boring

Filters

No tagging

Not findable

Tags

No mention

Can't tag

Mention

No hashtags

Not discoverable

Hashtags

Scheduling không

Timing

Schedule

112. FEED & TIMELINE ❌
Sai

Lý do

Đúng

Feed không algorithm

Dead feed

Algorithm

Feed too linear

Boring

Algorithm mix

No infinite scroll

Break

Scroll

No pull to refresh

Old

Refresh

Post engagement low

No interaction

Engagement

No trending

Not findable

Trending

Feed repeats

Repetitive

No duplicates

No "See more"

Long

Truncate

113. MESSAGING ❌
Sai

Lý do

Đúng

Messages not real-time

Slow

WebSocket

No typing indicator

Confusion

Indicator

No read receipts

Uncertainty

Receipts

No encryption

Security

E2E

Chat history lost

Lost

Cloud sync

No group chat

Isolation

Groups

No attachment limit

Bloat

Limit

No notification settings

Distraction

Settings

114. GROUPS & COMMUNITIES ❌
Sai

Lý do

Đúng

Group permissions weak

Chaos

Roles

No moderation

Spam

Mod tools

No member list

No transparency

List

No group analytics

Unknown

Stats

Invite link public

Leak

Approval

No announcements

No notice

Announce

115. PUSH NOTIFICATIONS ❌
Sai

Lý do

Đúng

Permission at start

Decline

Explain first

Too many notifications

Spamming

Frequency cap

No notification center

Lost

Center

Notification sound annoying

Mute

Customizable

Deep link không work

Not open

Handle

Notification grouping

Clutter

Group

No quiet hours

Disturb

Schedule

116. INVITATIONS & REFERRALS ❌
Sai

Lý do

Đúng

Invite flow complex

Drop off

Simple

Share options limited

Friction

All options

Invite tracking

No track

Track

Reward không clear

Confusion

Clear reward

Referral link expriyable

Expired

No expiry

Manual entry not

Friction

Manual option

117. GAMIFICATION ❌
Sai

Lý do

Đúng

No badges

No motivation

Badges

Progress invisible

No progress

Show

No leaderboard

No competition

List

Achievement không celebrate

Dead

Celebrate

Points meaningless

No value

Value

Challenges hidden

No challenge

Visible

118. ANALYTICS DASHBOARD ❌
Sai

Lý do

Đúng

Dashboard overload

Confusion

Key metrics

No date range

No comparison

Range picker

No export

No data

Export

Charts don't sync

Mismatch

Sync

Real-time data old

No real

Live

No custom reports

Limited

Custom

119. ADMIN & CMS ❌
Sai

Lý do

Đúng

CMS clunky

Slow

Mobile-friendly

Media library mess

Can't find

Organize

Batch operations missing

Slow

Bulk

Version control missing

Lost

Versioning

Preview not accurate

Mismatch

Preview

Draft published

Mistake

Confirm

120. MULTI-TENANCY ❌
Sai

Lý do

Đúng

No branding custom

Generic

Custom branding

White-label limited

Limited

Full

Subdomain not

Hard

Subdomain

Tenant isolation weak

Leak

Isolate

No tenant config

Shared

Config

Billing not separated

Shared

Separate

121. SUBSCRIPTION & BILLING ❌
Sai

Lý do

Đúng

Plan comparison unclear

Confusion

Clear

Feature matrix missing

Unclear

Matrix

Trial không explain

Surprise

Clear trial

Proration not shown

Confusion

Show

Cancel flow complex

Churn

Easy

No pause option

Churn

Pause

No family plan

Family

Plan

Upgrade flow not

Downgrade only

Both

122. INVOICING ❌
Sai

Lý do

Đúng

Invoice not professional

Unprofessional

Template

Tax calculation wrong

Wrong

Proper

Currency not support

Limited

Multi

Payment terms not

Terms

Option

Late fees not

Overdue

Notice

Invoice PDF không

Print

Download

Recurring invoice

Manual

Auto

123. CUSTOMER SUPPORT ❌
Sai

Lý do

Đúng

Support channel limited

One channel

Multi

No self-service

Cost

Help center

No chat bot

Slow

Bot

Ticket status không

Stuck

Track

Response time slow

Churn

SLA

No satisfaction

Quality

Survey

No knowledge base

Repetitive

KB

124. CHAT SUPPORT ❌
Sai

Lý do

Đúng

Chat queue unknown

Impatient

Position

Chat transfer

Frustrating

Seamless

No transcript

Lost

Email

No file transfer

Blocked

Share

Chat rating missing

Feedback

Rate

Offline không show

Expect

Offline

125. HELPCENTER & KB ❌
Sai

Lý do

Đúng

Search doesn't work

Can't find

Search

Articles not found

Dead

Link

No categories

Messy

Organized

Content outdated

Wrong

Update

No feedback

No improve

Rate

No related articles

Incomplete

Link

126. IN-APP MESSAGING ❌
Sai

Lý do

Đúng

Message generic

Not helpful

Contextual

Action not clear

What now

Button

Message timing wrong

Interrupt

Timing

Dismissible not

Repeat

Allow dismiss

Priority not correct

Wrong

Priority

127. COOKIES & CONSENT ❌
Sai

Lý do

Đúng

Cookie banner intrusive

Block content

Non-intrusive

Consent not granular

All or nothing

Granular

Consent not recallable

Settings

Remember

Cookie categories unclear

Confusing

Categories

Third-party not disclosed

Privacy

Disclosure

128. GDPR & PRIVACY ❌
Sai

Lý do

Đúng

Data export not

GDPR

Export

Data delete not

GDPR

Delete

Consent not proof

Legal

Proof

DNT not respect

Privacy

Respect

Data retention not

Legal

Policy

129. ACCESSIBILITY A11Y ❌
Sai

Lý do

Đúng

Screen reader crash

A11y

Test

Color contrast fail

Not readable

Ratio > 4.5

Focus trap

Keyboard

No trap

No alt text

Screen reader

Alt

Escape not work

Keyboard

Close

Skip link missing

A11y

Link

Form labels missing

A11y

Label

130. INTERNATIONALIZATION i18n ❌
Sai

Lý do

Đúng

Hardcoded text

Not translate

Key

String not plural

Wrong

Plural

Date format wrong

Locale

Locale

Currency format wrong

Locale

Locale

Language switch hard

Hard

Switch

RTL not supported

Arabic

Support

Character limit wrong

Length

Per-language

131. DEVICE SUPPORT ❌
Sai

Lý do

Đúng

Landscape not support

Rotate

Support

Tablet layout wrong

Scale

Optimize

Desktop not support

Browser

Desktop

Foldable not support

Fold

Support

Watch not support

Watch

Watch

Orientation lock

Lock

Auto

132. NETWORK RESILIENCE ❌
Sai

Lý do

Đúng

No offline mode

Break

Mode

Offline actions lost

Lost

Queue

Sync conflict not

Crash

Resolve

Retry mechanism missing

Fail

Retry

Optimistic UI fail

Wrong

Handle

133. CLOUD SYNC ❌
Sai

Lý do

Đúng

Sync not automatic

Manual

Auto

Sync conflict

Data loss

Resolve

Sync indicator missing

Unknown

Show

Selective sync missing

All

Choose

Sync frequency slow

Old

Real-time

134. BACKUP & RESTORE ❌
Sai

Lý do

Đúng

Backup not automatic

Lost

Scheduled

Backup location unclear

Unknown

Show

Restore not test

Unknown

Test

Selective restore not

All

Partial

Backup encryption not

Security

Encrypt

135. EXPORT & IMPORT ❌
Sai

Lý do

Đúng

Export format limited

Format

Multiple

Import mapping hard

Manual

Map

Import preview missing

Unknown

Preview

Import error unclear

Error

Clear

Export large data timeout

Timeout

Chunk

136. LIVE STREAMING ❌
Sai

Lý do

Đúng

Buffering often

Watch

Adaptive

Quality auto not

Quality

Auto

Live replay not

Replay

Option

Chat lag

Delay

Minimize

Viewer count not

Social

Show

137. VIDEO CALLS ❌
Sai

Lý do

Đúng

Audio quality poor

Can't hear

HD

Video quality poor

Pixelated

HD

Screen share not

Share

Share

Recording not

Record

Option

Mute indicator missing

Feedback

Show

Connection quality not

Unknown

Indicator

138. VOICE FEATURES ❌
Sai

Lý do

Đúng

Voice recognition poor

Wrong

Improve

Wake word not

Activate

Options

Voice feedback poor

Can't hear

Options

Speech not continuous

Pause

Continuous

Voice command missing

Commands

Full

139. AUGMENTED REALITY AR ❌
Sai

Lý do

Đúng

AR quality poor

Ghost

Improve

Surface detection slow

Wait

Instant

AR not stable

Jitter

Stable

Lighting not handle

Dark

Adapt