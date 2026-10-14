# Sistem Kendali BDR — Exemplar & Panduan Tugas Siswa

Aplikasi web interaktif **satu halaman** (single-page, HTML + Tailwind via CDN) untuk mata pelajaran pilihan **Sistem Kendali** dalam konteks **Belajar Dari Rumah (BDR)** saat bencana kabut asap.

Halaman ini berfungsi sebagai **contoh acuan (master sample)** pengerjaan tugas, lengkap dengan **simulator interaktif** dan **lembar kerja siswa** yang bisa diisi, disalin, dan dikirim ke cloud (opsional).

> **Live demo:** https://hendrazulpiadi.github.io/system-kendali-bdr/

---

## 1. Ringkasan

| Item | Keterangan |
|------|------------|
| Berkas utama | `index.html` |
| Jenis | Web statis (HTML + Tailwind via CDN) + Supabase (opsional) |
| Bahasa | Indonesia |
| Studi kasus | Sistem Kendali Penyaring & Monitor Kualitas Udara Otomatis (*Smart Air Quality Control System*) |
| Konteks | Tugas mandiri saat kabut asap (udara berbahaya → pembelajaran daring) |
| Server dibutuhkan | Tidak untuk fitur inti. Supabase dibutuhkan untuk fitur cloud (opsional). |
| Hosting | GitHub Pages (gratis, otomatis dari repositori) |

Tidak ada proses build dan tidak ada `package.json`. Semua logika inti berada di dalam `index.html`. Fitur cloud memakai konfigurasi `supabase-config.js`.

---

## 2. Struktur Berkas

| Berkas | Fungsi |
|--------|--------|
| `index.html` | Halaman utama (seluruh UI + logika JavaScript). |
| `supabase-config.js` | Menyimpan `url` + kunci publik Supabase (opsional). |
| `supabase-schema.sql` | Skema tabel, kebijakan RLS, dan aktivasi Realtime. Jalankan di SQL Editor Supabase. |
| `serve.ps1` | Server lokal sederhana (PowerShell) untuk pratinjau sebelum deploy. |
| `.nojekyll` | Menandai GitHub Pages agar tidak memproses situs dengan Jekyll. |

---

## 3. Menjalankan Secara Lokal

**Cara cepat:** klik dua kali `index.html`.

**Cara disarankan** (agar path relatif & Supabase berjalan normal):

```powershell
powershell -ExecutionPolicy Bypass -File serve.ps1
```

Lalu buka `http://localhost:8080/`.

Sambungan internet dibutuhkan karena library dimuat dari CDN:

- **Tailwind CSS** (styling)
- **Font Awesome 6.4** (ikon)
- **Google Fonts — Inter** (tipografi)
- **Chart.js** (grafik simulasi live)
- **Supabase JS SDK** (fitur cloud — opsional)

> Tanpa internet, layout masih tampil namun tanpa styling/ikon/grafik.

---

## 4. Publikasi ke GitHub Pages

Karena situs berupa HTML statis tanpa proses build, halaman ini bisa langsung dipublikasikan:

1. Buat repositori baru di GitHub (mis. `sistem-kendali-bdr`).
2. Unggah seluruh berkas proyek ini ke repositori tersebut (branch `main`).
3. Buka **Settings → Pages**.
4. Pada **Build and deployment → Source**, pilih **Deploy from a branch**.
5. Pilih branch **`main`** dan folder **`/ (root)`**, lalu **Save**.
6. Tunggu 1–2 menit. Situs tersedia di:
   `https://<username>.github.io/<nama-repo>/`

`index.html` otomatis dibuka saat pengunjung mengakses URL repositori. Berkas `.nojekyll` memastikan seluruh aset tersaji tanpa diproses Jekyll.

### Push dari terminal

```powershell
git init
git add .
git commit -m "Publikasi Sistem Kendali BDR ke GitHub Pages"
git branch -M main
git remote add origin https://github.com/<username>/<nama-repo>.git
git push -u origin main
```

---

## 5. Struktur Halaman (UI)

1. **Header Peringatan BDR** — banner kuning peringatan kabut asap (sticky).
2. **Navigasi Atas** — tautan ke setiap seksi + tombol toggle mode tampilan.
3. **Hero Section** — judul dan penjelasan tugas.
4. **Seksi 1: Instruksi & Rubrik** — Tugas 1 (sintesis definisi) dan Tugas 2 (bedah sistem nyata).
5. **Seksi 2: Contoh Master (Master Sample)** — jawaban contoh grade A+:
   - Bagian 1: Sintesis definisi dari 3 literatur (Ogata, Nise, Kuo) + kesimpulan siswa.
   - Bagian 2: Anatomi 4 blok + **simulator live**.
   - Bagian 3: Perbandingan kinerja **Manual vs Otomatis** (tabel).
   - Bagian 4: Dampak penerapan (Kesehatan, Energi, Respon Waktu, Biaya).
6. **Seksi 4: Lembar Kerja Interaktif** — form draf tugas siswa + preview + tombol salin + tombol kirim ke cloud.
7. **Seksi 5: Dashboard Kelas (Supabase)** — login siswa, monitoring pengumpulan realtime, dan data contoh dari cloud.
8. **Mode Poster/Flyer** — overlay presentasi digital yang bisa dibuka lewat tombol toggle.
9. **Footer**.

---

## 6. Integrasi Supabase (Opsional)

Aplikasi mendukung backend **Supabase** untuk: menyimpan draf siswa, mengambil data contoh/master, login siswa, dan monitoring realtime. Bila tidak dikonfigurasi, semua fitur inti tetap berjalan (mode luring).

### Langkah setup

1. Buat project di [supabase.com](https://supabase.com).
2. Buka **SQL Editor → New query**, tempel isi `supabase-schema.sql`, lalu **Run**.
3. Buka **Project Settings → API**, salin **Project URL** dan **publishable/anon key**.
4. Isi keduanya ke `supabase-config.js`:
   ```js
   window.SUPABASE_CONFIG = {
       url: "https://xxxx.supabase.co",
       anonKey: "sb_publishable_..."
   };
   ```
5. Buka ulang halaman. Badge status akan berubah menjadi **Terhubung ke Supabase**.

### Pengaturan saat hosting publik (GitHub Pages)

Agar **login/sign-up** dan tautan verifikasi email bekerja di domain publik:

1. Buka **Authentication → URL Configuration** di Supabase.
2. Isi **Site URL** dengan `https://<username>.github.io/<nama-repo>/`.
3. Tambahkan domain yang sama ke **Redirect URLs** (mis. `https://<username>.github.io/<nama-repo>/**`).

> PENTING: hanya pakai **publishable/anon key**. Jangan pernah menaruh **service_role key** di `supabase-config.js` karena terekspos ke browser publik.

### Tabel yang dipakai

- `student_submissions` — draf tugas siswa (definisi, nama sistem, sensor, controller, actuator, dampak). Hanya siswa yang login boleh menulis; semua boleh membaca.
- `master_samples` — data contoh yang ditampilkan di panel "Data Contoh / Master Sample".

### Catatan keamanan (RLS)

Row Level Security aktif pada kedua tabel: `SELECT` dibuka untuk publik, sedangkan `INSERT` hanya untuk pengguna terautentikasi (`auth.uid() = user_id`).

---

## 7. Anatomi Sistem Kendali yang Dipelajari

Konsep inti yang diajarkan adalah 4 blok sistem kendali (umpan balik):

| Blok | Komponen | Fungsi |
|------|----------|--------|
| 1. Input / Sensor | Sensor PM2.5 / Dust | Mendeteksi kadar partikel polusi (µg/m³) |
| 2. Controller | Mikrokontroler / PID | Membandingkan dengan *setpoint* (35 µg/m³) dan menghitung kecepatan kipas |
| 3. Output / Aktuator | Kipas HEPA Filter | Menyaring udara sesuai instruksi prosesor |
| 4. Feedback | Loop umpan balik | Sensor membaca ulang hasil penyaringan untuk penyesuaian |

---

## 8. Logika Simulator (JavaScript)

Simulator dikendalikan oleh *slider* PM2.5 (rentang 5–300 µg/m³) dengan aturan kontrol berikut:

| Kadar PM2.5 | Kecepatan Kipas | Status Sistem |
|-------------|-----------------|---------------|
| `≤ 35` | 0% (OFF) | Sistem Aman (Normal) — hijau |
| `36 – 100` | 40% | Tinjauan Polusi Sedang — kuning |
| `101 – 200` | 75% | Peringatan Polusi Tinggi — oranye |
| `> 200` | 100% | BAHAYA KABUT ASAP — merah (berkedip) |

Fungsi utama (`<script>` di bagian bawah `index.html`):

- `initSimulationChart()` — membuat grafik Chart.js (10 riwayat data terakhir).
- `updateSimulation()` — inti logika kontrol: menghitung *error* = `max(0, pmValue - setpoint)`, menentukan kecepatan kipas, animasi kipas, warna grafik, dan badge status.
- `triggerHazeSpike()` — mensimulasikan asap mendadak (set slider ke 240).
- `resetSimulation()` — mengembalikan slider ke 25 (udara bersih).
- `toggleViewMode()` — beralih antara mode artikel web dan mode poster/flyer.
- `generateStudentSummary()` — merangkum isi form lembar kerja menjadi teks draf.
- `copyWorksheetToClipboard()` — menyalin draf ke clipboard.
- `initSupabase()` — inisialisasi klien Supabase dari `supabase-config.js` dan memuat data.
- `handleAuthSubmit()` / `handleSignOut()` / `updateAuthUI()` — autentikasi siswa.
- `saveDraftToCloud()` — menyimpan draf ke tabel `student_submissions`.
- `loadSubmissions()` / `loadMasterSamples()` — mengambil data dari Supabase.
- `subscribeRealtime()` — langganan perubahan realtime (INSERT) pada tabel draf.

Variabel state global: `chartInstance` dan `simHistory` (array 10 angka).

---

## 9. Teknologi

- **HTML5** semantik
- **Tailwind CSS** (via CDN + konfigurasi tema `brand`/`air` di `<head>`)
- **JavaScript vanilla** (tanpa framework)
- **Chart.js** untuk visualisasi real-time
- **Supabase** (Postgres, Auth, Realtime) via SDK CDN — opsional
- **Font Awesome** untuk ikon
- Font **Inter**

---

## 10. Tujuan Pembelajaran

Setelah mempelajari halaman ini, siswa diharapkan mampu:

1. Menyintesis definisi **Sistem Kendali** dari minimal 3 sumber literatur dengan bahasa sendiri.
2. Membedah sistem kendali nyata ke dalam 4 elemen: **Sensor, Controller, Actuator, Feedback**.
3. Menganalisis perbedaan kinerja **manual vs otomatis** (efisiensi, respon waktu, biaya, dampak).
4. Menyusun draf tugas dalam format presentasi/flyer digital.

---

## 11. Catatan Pengembangan

- Seluruh kode ada di `index.html`; untuk mengubah data contoh, sunting langsung teks HTML-nya.
- Untuk menambah aturan kontrol, modifikasi blok `if/else` pada `updateSimulation()`.
- Untuk mengubah *setpoint* (saat ini `35`), cari variabel `const setpoint = 35;`.
- Untuk menonaktifkan Supabase, cukup biarkan `supabase-config.js` pada nilai placeholder.
- Setiap perubahan yang di-push ke branch `main` akan otomatis terbit ulang di GitHub Pages.
