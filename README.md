# 🧾 VKU Receipt OCR & Expense Tracker (Flutter & Dart)

> **Môn học:** Lập trình Di động Đa nền tảng (Cross-Platform Mobile App Development)  
> **Sinh viên:** Nguyễn Tùng Lâm — **MSSV:** 23IT138  
> **Framework:** Flutter 3.x, Dart 3, Google ML Kit, SQLite (`sqflite`), CustomPainter  
> **Repository:** [https://github.com/pie-12/mob2026-lab3](https://github.com/pie-12/mob2026-lab3)  

---

## 🎯 Giới thiệu Dự án
Ứng dụng **VKU Receipt OCR & Expense Tracker** giải quyết bài toán quản lý tài chính và chi tiêu cho sinh viên & ban chủ nhiệm CLB tại VKU:
- Thay vì phải nhập tay từng con số vào bảng tính Excel dễ sai sót, người dùng chỉ cần **chụp ảnh hóa đơn mua sắm**.
- Trí tuệ nhân tạo trên thiết bị (**On-device Google ML Kit**) sẽ tự động nhận diện chữ mà **không cần kết nối Internet**.
- Hệ thống giải thuật Regex Heuristic Engine tự động bóc tách **Tên cửa hàng**, **Tổng số tiền thanh toán (VNĐ)**, và **Ngày trên hóa đơn**.
- Người dùng kiểm tra & hiệu chỉnh trên màn hình Review trước khi lưu vào cơ sở dữ liệu **SQLite** cục bộ.
- Vẽ trực quan các biểu đồ phân tích chi tiêu bằng **CustomPainter (Canvas 2D)**.

---

## 🏛️ Kiến trúc Hệ thống (System Architecture)

```
[Camera / Thư viện] (image_picker)
         ↓
[Google ML Kit Text Recognition] (On-device Offline OCR)
         ↓
[Dart Regex Parser Engine] (Bóc tách Tổng tiền, Ngày, Cửa hàng)
         ↓
[Màn hình Xác nhận & Kiểm tra] (Receipt Review Screen)
         ↓
[Cơ sở dữ liệu SQLite Nội bộ] (sqflite persistent storage)
         ↓
[Bảng điều khiển & Biểu đồ Canvas] (CustomPainter Pie & Bar Charts)
```

---

## 🛠️ Công nghệ sử dụng (Tech Stack)
- **Framework lõi:** Flutter 3.24+, Dart 3.0+
- **OCR Engine:** `google_mlkit_text_recognition`
- **Camera Capture:** `image_picker`
- **Database:** `sqflite`, `path`
- **Canvas Visuals:** Flutter `CustomPainter` (Pie Chart & Bar Chart)
- **Formatting:** `intl` (Định dạng tiền tệ VNĐ và ngày tháng dd/MM/yyyy)
- **CI/CD Pipeline:** GitHub Actions tự động build file `app-release.apk`

---

## 🚀 Hướng dẫn Cài đặt & Trải nghiệm

### Cách 1: Tải trực tiếp file APK từ GitHub Actions
1. Vào tab **Actions** tại repository: `https://github.com/pie-12/mob2026-lab3/actions`
2. Chọn workflow run mới nhất -> Tải artifact `app-release.apk` về cài đặt trực tiếp trên điện thoại Android.

### Cách 2: Chạy trực tiếp từ Source Code
```bash
# 1. Tải dependencies
flutter pub get

# 2. Khởi chạy trên thiết bị / máy ảo
flutter run
```
