# 💸 Expense Tracker App

A modern Flutter application designed to help you **track daily expenses** easily and beautifully.  
This app combines clean UI, smooth animations, and an intuitive user experience — from the **splash screen** to **authentication flow**.

---

## 🖼️ App Preview

### 🪪 Logo  
![Logo](https://github.com/user-attachments/assets/3ceb835b-48f1-4a0f-a892-6da367018157)
<img width="440" height="956" alt="Image" src="https://github.com/user-attachments/assets/3ceb835b-48f1-4a0f-a892-6da367018157" />


> **Deskripsi:**  
Logo utama aplikasi yang digunakan pada splash screen dan login page.  
Melambangkan gaya minimalis & profesional, sebagai identitas visual aplikasi pengelola keuangan.

---

### ⚡ Splash Screen  
![Splash](https://github.com/user-attachments/assets/04c8c8ed-9965-479e-9164-47780d05c6a4)
<img width="440" height="956" alt="Image" src="https://github.com/user-attachments/assets/04c8c8ed-9965-479e-9164-47780d05c6a4" />


> **Deskripsi:**  
Tampilan pertama ketika aplikasi dibuka.  
Splash screen menampilkan logo aplikasi selama beberapa detik sebelum masuk ke onboarding.  
Biasanya diatur dengan `Future.delayed` untuk transisi ke halaman berikutnya.

---

### 🎨 Onboarding Screen  
![Onboarding](https://github.com/user-attachments/assets/38474db7-7cb2-462f-9e7a-20ca72be8c59)
<img width="440" height="956" alt="Image" src="https://github.com/user-attachments/assets/38474db7-7cb2-462f-9e7a-20ca72be8c59" />


> **Deskripsi:**  
Serangkaian **slide bergambar yang bisa digeser (swipe)** oleh pengguna untuk mengenal fitur utama aplikasi.  
Biasanya terdiri dari 3–4 halaman seperti:
- Melihat total pengeluaran  
- Menambahkan transaksi baru  
- Mengatur keuangan bulanan  

Setelah onboarding selesai, pengguna diarahkan ke halaman login.

---

### 🔐 Login & Signup Page  
![Auth](https://github.com/user-attachments/assets/381a07a7-e885-46e1-9d30-794bfe1dad1a)
<img width="440" height="956" alt="Image" src="https://github.com/user-attachments/assets/381a07a7-e885-46e1-9d30-794bfe1dad1a" />


> **Deskripsi:**  
Halaman untuk autentikasi pengguna.  
Terdiri dari dua bagian utama:
- **Login** → untuk pengguna yang sudah memiliki akun  
- **Signup** → untuk pengguna baru yang ingin mendaftar  

Dilengkapi dengan validasi form, tombol interaktif, dan navigasi antar halaman.

---

<!-- ### 📱 Tampilan UI Aplikasi   -->

> **Deskripsi:**  
Contoh tampilan utama aplikasi setelah login.  
Menampilkan daftar transaksi, ringkasan keuangan, dan tombol aksi untuk menambah atau mengedit pengeluaran dengan tampilan yang modern dan responsif.

---

## 🚀 Features

✅ Splash screen animasi logo  
✅ Onboarding dengan slider interaktif  
✅ Login & signup dengan validasi form  
✅ State management yang efisien (Provider / Riverpod)  
✅ Responsive layout untuk Android, iOS, dan Web  

---

## 🧩 Tech Stack

- **Flutter** (latest stable)
- **Dart**
- **Google Fonts**
- **Lottie Animations**
- **Shared Preferences** (untuk skip onboarding)
- **Firebase Auth** *(optional)*

---

## 🧰 Setup & Run

1. **Clone repository:**
   ```bash
   git clone https://github.com/yourusername/expense-tracker.git
   cd expense-tracker
