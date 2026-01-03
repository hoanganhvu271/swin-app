# 🪵 WoodSwin

<div align="center">

![WoodSwin Logo](assets/images/app_logo.png)

**Ứng dụng nhận diện loài gỗ thông minh sử dụng AI**

[![Flutter](https://img.shields.io/badge/Flutter-3.7.2+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Go](https://img.shields.io/badge/Go-1.25+-00ADD8?style=for-the-badge&logo=go&logoColor=white)](https://golang.org)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)


</div>

---

## Mục lục

- [Giới thiệu](#-giới-thiệu)
- [Tính năng](#-tính-năng)
- [Cài đặt](#-cài-đặt)
- [Cấu trúc dự án](#-cấu-trúc-dự-án)
---

## Giới thiệu

**WoodSwin** là ứng dụng nhận diện gỗ thông minh, sử dụng mô hình học sâu **FA-Net** kết hợp **YOLOv11** để phân tích đặc trưng vân gỗ và cấu trúc bề mặt từ hình ảnh.

Ứng dụng hỗ trợ xác định chủng loại gỗ nhanh chóng, chính xác, giúp người dùng tra cứu, kiểm định và hỗ trợ ra quyết định hiệu quả trong thực tế.

### Đặc điểm nổi bật

- **Nhận diện chính xác** - Sử dụng mô hình FA-Net với độ chính xác cao
- **Hỗ trợ UVC Camera** - Kết nối với kính hiển vi USB để phân tích chi tiết vân gỗ
- **Thư viện gỗ phong phú** - Cơ sở dữ liệu đa dạng các loại gỗ Việt Nam
- **Đa ngôn ngữ** - Hỗ trợ Tiếng Việt và Tiếng Anh
- **Đa nền tảng** - Chạy trên Android, iOS và Web

---

## Tính năng

### Nhận diện gỗ
- Chụp ảnh hoặc chọn từ thư viện
- Phân tích và dự đoán loài gỗ với độ tin cậy
- Hiển thị top kết quả dự đoán

### Kết nối UVC Camera
- Hỗ trợ kính hiển vi USB (UVC Camera)
- Chụp ảnh trực tiếp từ camera kết nối
- Xem trước video realtime

### Thư viện gỗ
- Tra cứu thông tin chi tiết các loại gỗ
- Hình ảnh mẫu chất lượng cao
- Mô tả đặc điểm, công dụng

### Lịch sử dự đoán
- Lưu trữ các kết quả nhận diện
- Xem lại và so sánh kết quả

### ⚙Quản lý Model AI
- Chọn và tải các phiên bản model khác nhau
- Cập nhật model mới từ server

---

## Công nghệ sử dụng

### Mobile App (Flutter)
| Công nghệ | Mô tả |
|-----------|-------|
| Flutter 3.7.2+ | Framework phát triển đa nền tảng |
| flutter_bloc | State management |
| onnxruntime | Chạy model AI trên thiết bị |
| firebase_core | Tích hợp Firebase |
| uvc_manager | Quản lý UVC Camera |
| dio / chopper | HTTP Client |

### Backend (Go)
| Công nghệ | Mô tả |
|-----------|-------|
| Go 1.25+ | Ngôn ngữ lập trình |
| Gin | Web framework |
| Firebase Admin SDK | Quản lý Firebase |
| Cloudinary SDK | Lưu trữ hình ảnh |

### AI Model
| Công nghệ | Mô tả |
|-----------|-------|
| FA-Net | Mô hình nhận diện đặc trưng gỗ |
| YOLOv11 | Object detection |
| ONNX | Định dạng model chuẩn |

### Infrastructure
| Công nghệ | Mô tả |
|-----------|-------|
| Firebase Firestore | NoSQL Database |
| Firebase Crashlytics | Crash reporting |
| Cloudinary | Media storage |

---

## Cài đặt

### Yêu cầu

- Flutter SDK >= 3.7.2
- Go >= 1.25
- Android Studio / Xcode
- Firebase Project

### Mobile App

1. **Clone repository**
```bash
git clone https://github.com/hoanganhvu271/woodswin.git
cd woodswin
```

2. **Cài đặt dependencies**
```bash
flutter pub get
```

3. **Cấu hình Firebase**
```bash
# Cài đặt FlutterFire CLI
dart pub global activate flutterfire_cli

# Cấu hình Firebase
flutterfire configure
```

4. **Chạy ứng dụng**
```bash
# Development
flutter run

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## Cấu trúc dự án

```
woodswin/
├── 📱 lib/                          # Flutter source code
│   ├── constants/                   # Colors, dimensions, assets
│   ├── l10n/                        # Localization (vi, en)
│   ├── locators/                    # Dependency injection
│   ├── models/                      # Data models
│   ├── repository/                  # Data repositories
│   ├── ui/
│   │   ├── blocs/                   # BLoC state management
│   │   │   ├── prediction/          # Prediction logic
│   │   │   ├── wood/                # Wood list logic
│   │   │   └── wood_detail/         # Wood detail logic
│   │   ├── screens/                 # App screens
│   │   │   ├── home/                # Home screen
│   │   │   ├── library/             # Wood library
│   │   │   ├── history/             # Prediction history
│   │   │   ├── prediction/          # Prediction screen
│   │   │   ├── uvc/                 # UVC camera
│   │   │   └── more/                # Settings & info
│   │   └── widgets/                 # Reusable widgets
│   ├── utils/                       # Utilities
│   ├── firebase_options.dart        # Firebase config
│   ├── onnx_predictor.dart          # ONNX inference
│   └── main.dart                    # Entry point
```

## Cấu hình

### Firebase

1. Tạo project trên [Firebase Console](https://console.firebase.google.com)
2. Bật Firestore Database
3. Bật Crashlytics
4. Download `google-services.json` (Android) và `GoogleService-Info.plist` (iOS)

### Cloudinary

1. Đăng ký tại [Cloudinary](https://cloudinary.com)
2. Lấy Cloud Name, API Key, API Secret
3. Cấu hình trong backend

### Model AI

Model ONNX được lưu trữ trên Cloudinary và có thể cập nhật qua API:

```json
{
  "current_version": "v1.0.1",
  "versions": [
    {
      "version": "v1.0.0",
      "file": "https://res.cloudinary.com/.../model_v1.onnx",
      "name": "FA-Net v1",
      "checksum": "sha256...",
      "size": 6785155
    }
  ]
}
```
