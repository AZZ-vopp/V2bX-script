# 🚀 V2bX - Script Quản Lý Node Server Chuyên Nghiệp

<div align="center">

![V2bX Logo](https://img.shields.io/badge/V2bX-Node%20Server-blue?style=for-the-badge&logo=github)
![Version](https://img.shields.io/badge/Version-2.0.0-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Ubuntu%20%7C%20CentOS%20%7C%20Debian-orange?style=for-the-badge)

**Một script quản lý node server V2board dựa trên Xray-Core với giao diện tiếng Việt hoàn chỉnh**

[![GitHub Stars](https://img.shields.io/github/stars/AZZ-vopp/V2bX-script?style=social)](https://github.com/AZZ-vopp/V2bX-script)
[![GitHub Forks](https://img.shields.io/github/forks/AZZ-vopp/V2bX-script?style=social)](https://github.com/AZZ-vopp/V2bX-script)

</div>

---

## 📋 Mục Lục

- [🌟 Tính Năng](#-tính-năng)
- [🛠️ Hỗ Trợ Giao Thức](#️-hỗ-trợ-giao-thức)
- [⚡ Cài Đặt Nhanh](#-cài-đặt-nhanh)
- [📖 Hướng Dẫn Sử Dụng](#-hướng-dẫn-sử-dụng)
- [🔧 Cấu Hình](#-cấu-hình)
- [📊 Quản Lý](#-quản-lý)
- [🛡️ Bảo Mật](#️-bảo-mật)
- [❓ Hỗ Trợ](#-hỗ-trợ)
- [📄 Giấy Phép](#-giấy-phép)

---

## 🌟 Tính Năng

### ✨ **Giao Diện Tiếng Việt Hoàn Chỉnh**
- 🎯 Tất cả thông báo và menu đều được dịch sang tiếng Việt
- 🔧 Sử dụng editor `nano` thân thiện thay vì `vi`
- 📱 Giao diện trực quan, dễ sử dụng

### 🚀 **Quản Lý Node Server Mạnh Mẽ**
- 🔄 **Cài đặt & Cập nhật tự động** - Hỗ trợ cài đặt và cập nhật V2bX một cách dễ dàng
- 🎛️ **Quản lý dịch vụ** - Khởi động, dừng, khởi động lại V2bX
- 📊 **Giám sát trạng thái** - Theo dõi trạng thái hoạt động của dịch vụ
- 🔐 **Quản lý chứng chỉ** - Tự động tạo và quản lý chứng chỉ SSL/TLS
- ⚙️ **Tạo cấu hình** - Tạo file cấu hình tự động với wizard thông minh

### 🛡️ **Bảo Mật & Hiệu Suất**
- 🔒 **Tường lửa tự động** - Tự động mở cổng cần thiết
- 🚀 **Tối ưu BBR** - Hỗ trợ cài đặt BBR cho hiệu suất tối ưu
- 📈 **Giám sát log** - Theo dõi log chi tiết để debug
- 🔄 **Khởi động cùng hệ thống** - Tự động khởi động khi boot

---

## 🛠️ Hỗ Trợ Giao Thức

| Giao Thức | Hỗ Trợ | Mô Tả |
|-----------|--------|-------|
| **VMess** | ✅ | Giao thức chính của V2Ray |
| **VLESS** | ✅ | Giao thức nhẹ và hiệu quả |
| **Shadowsocks** | ✅ | Giao thức proxy phổ biến |
| **Trojan** | ✅ | Giao thức bảo mật cao |
| **Hysteria** | ✅ | Giao thức UDP-based |
| **Hysteria2** | ✅ | Phiên bản cải tiến của Hysteria |
| **TUIC** | ✅ | Giao thức UDP mới |
| **AnyTLS** | ✅ | Hỗ trợ TLS linh hoạt |

---

## ⚡ Cài Đặt Nhanh

### 🎯 **Cài Đặt Một Lệnh**

```bash
# Cài đặt V2bX với script tiếng Việt
wget -N https://raw.githubusercontent.com/AZZ-vopp/V2bX-script/master/install.sh && bash install.sh
```

### 🔧 **Yêu Cầu Hệ Thống**

| Hệ Điều Hành | Phiên Bản Tối Thiểu | Ghi Chú |
|--------------|---------------------|---------|
| **Ubuntu** | 16.04+ | Khuyến nghị 18.04+ |
| **CentOS** | 7+ | Khuyến nghị 8+ |
| **Debian** | 8+ | Khuyến nghị 10+ |
| **Alpine** | 3.8+ | Hỗ trợ đầy đủ |

### 📋 **Kiểm Tra Trước Khi Cài Đặt**

```bash
# Kiểm tra quyền root
sudo -v

# Kiểm tra kết nối mạng
ping -c 3 github.com

# Kiểm tra kiến trúc hệ thống
uname -m
```

---

## 📖 Hướng Dẫn Sử Dụng

### 🎮 **Menu Chính**

Sau khi cài đặt, chạy lệnh `V2bX` để mở menu quản lý:

```
🚀 V2bX - Script Quản Lý Node Server
=====================================

📋 MENU CHÍNH:
 0. Sửa đổi cấu hình
 1. Cài đặt V2bX
 2. Cập nhật V2bX
 3. Gỡ cài đặt V2bX
 4. Khởi động V2bX
 5. Dừng V2bX
 6. Khởi động lại V2bX
 7. Xem trạng thái V2bX
 8. Xem log V2bX
 9. Thiết lập V2bX khởi động cùng hệ thống
10. Hủy V2bX khởi động cùng hệ thống
11. Cài đặt một lần bbr (kernel mới nhất)
12. Xem phiên bản V2bX
13. Tạo khóa X25519
14. Nâng cấp script bảo trì V2bX
15. Tạo file cấu hình V2bX
16. Mở tất cả cổng mạng VPS
17. Thoát script
```

### 🔧 **Lệnh Quản Lý Nhanh**

```bash
# Quản lý dịch vụ
V2bX start          # Khởi động V2bX
V2bX stop           # Dừng V2bX
V2bX restart        # Khởi động lại V2bX
V2bX status         # Xem trạng thái

# Quản lý cấu hình
V2bX config         # Sửa đổi cấu hình (sử dụng nano)
V2bX generate       # Tạo cấu hình tự động

# Quản lý hệ thống
V2bX enable         # Khởi động cùng hệ thống
V2bX disable        # Hủy khởi động cùng hệ thống
V2bX log            # Xem log chi tiết

# Công cụ
V2bX x25519         # Tạo khóa X25519
V2bX version        # Xem phiên bản
```

---

## 🔧 Cấu Hình

### 🎯 **Tạo Cấu Hình Tự Động**

```bash
# Chạy wizard tạo cấu hình
V2bX generate
```

Wizard sẽ hướng dẫn bạn qua các bước:

1. **Chọn loại lõi**: Xray, SingBox, hoặc Hysteria2
2. **Nhập thông tin API**: URL và API Key từ panel
3. **Chọn giao thức**: VMess, VLESS, Shadowsocks, Trojan, v.v.
4. **Cấu hình TLS**: Tự động hoặc thủ công
5. **Tạo file cấu hình**: Tự động tạo `/etc/V2bX/config.json`

### 📝 **Cấu Hình Thủ Công**

```bash
# Sửa đổi cấu hình bằng nano
V2bX config
```

File cấu hình chính: `/etc/V2bX/config.json`

---

## 📊 Quản Lý

### 📈 **Giám Sát Trạng Thái**

```bash
# Xem trạng thái dịch vụ
V2bX status

# Xem log chi tiết
V2bX log

# Xem phiên bản
V2bX version
```

### 🔄 **Cập Nhật & Bảo Trì**

```bash
# Cập nhật lên phiên bản mới nhất
V2bX update

# Cập nhật lên phiên bản cụ thể
V2bX update 2.1.0

# Nâng cấp script quản lý
V2bX update_shell
```

### 🗑️ **Gỡ Cài Đặt**

```bash
# Gỡ cài đặt hoàn toàn
V2bX uninstall
```

---

## 🛡️ Bảo Mật

### 🔐 **Quản Lý Chứng Chỉ**

- **Tự động**: Sử dụng Let's Encrypt để tạo chứng chỉ SSL
- **DNS Challenge**: Hỗ trợ xác thực DNS cho các domain
- **Tự ký**: Tạo chứng chỉ tự ký cho môi trường test

### 🔥 **Tường Lửa**

```bash
# Mở tất cả cổng (chỉ dùng cho test)
V2bX open_ports

# Hoặc cấu hình tường lửa thủ công
ufw allow 443/tcp
ufw allow 80/tcp
```

### 🚀 **Tối Ưu Hiệu Suất**

```bash
# Cài đặt BBR cho hiệu suất tối ưu
V2bX install_bbr
```

---

## ❓ Hỗ Trợ

### 📚 **Tài Liệu**

- **Hướng dẫn chi tiết**: [Tutorial](https://v2bx.v-50.me/)
- **Source code gốc**: [InazumaV/V2bX](https://github.com/InazumaV/V2bX)
- **Test sandbox**: [Killercoda](https://killercoda.com/playgrounds/scenario/ubuntu)

### 🐛 **Báo Lỗi & Đóng Góp**

Nếu gặp vấn đề hoặc muốn đóng góp:

1. **Tạo Issue**: [GitHub Issues](https://github.com/AZZ-vopp/V2bX-script/issues)
2. **Fork & PR**: [GitHub Pull Requests](https://github.com/AZZ-vopp/V2bX-script/pulls)
3. **Thảo luận**: [GitHub Discussions](https://github.com/AZZ-vopp/V2bX-script/discussions)

### 🔧 **Troubleshooting**

```bash
# Kiểm tra log lỗi
V2bX log

# Kiểm tra cấu hình
cat /etc/V2bX/config.json

# Kiểm tra trạng thái dịch vụ
systemctl status V2bX
```

---

## 📄 Giấy Phép

Dự án này được phân phối dưới giấy phép **MIT License**. Xem file [LICENSE](LICENSE) để biết thêm chi tiết.

---

<div align="center">

### 🌟 **Nếu dự án này hữu ích, hãy cho một ⭐ Star!**

[![GitHub Stars](https://img.shields.io/github/stars/AZZ-vopp/V2bX-script?style=social&label=Star)](https://github.com/AZZ-vopp/V2bX-script)
[![GitHub Forks](https://img.shields.io/github/forks/AZZ-vopp/V2bX-script?style=social&label=Fork)](https://github.com/AZZ-vopp/V2bX-script)

**Được phát triển với ❤️ bởi [AZZ-vopp](https://github.com/AZZ-vopp)**

</div>
