-- ============================================================
-- Skema Supabase untuk Sistem Kendali BDR  (versi aman/idempotent)
-- Jalankan SELURUH isi file ini di:
--   Supabase Dashboard -> SQL Editor -> New query -> Run
-- Jika muncul error, salin pesan error-nya (tabel tidak akan
-- terbentuk jika ada statement yang gagal).
-- ============================================================

-- 1) Tabel draf tugas siswa
create table if not exists public.student_submissions (
    id            uuid primary key default gen_random_uuid(),
    created_at    timestamptz not null default now(),
    user_id       uuid references auth.users (id) on delete set null,
    student_email text,
    definition    text not null,
    system_name   text not null,
    sensor        text not null,
    controller    text not null,
    actuator      text not null,
    impact        text not null
);

create index if not exists student_submissions_created_at_idx
    on public.student_submissions (created_at desc);

-- 2) Tabel data contoh/master
create table if not exists public.master_samples (
    id          uuid primary key default gen_random_uuid(),
    created_at  timestamptz not null default now(),
    title       text not null,
    definition  text,
    sensor      text,
    controller  text,
    actuator    text,
    feedback    text,
    impact      text
);

-- 3) Row Level Security
alter table public.student_submissions enable row level security;
alter table public.master_samples       enable row level security;

drop policy if exists "read submissions" on public.student_submissions;
create policy "read submissions"
    on public.student_submissions for select
    using (true);

drop policy if exists "insert own submission" on public.student_submissions;
create policy "insert own submission"
    on public.student_submissions for insert
    with check (auth.uid() = user_id);

drop policy if exists "read master samples" on public.master_samples;
create policy "read master samples"
    on public.master_samples for select
    using (true);

-- 4) Seed data contoh (hanya jika tabel masih kosong)
insert into public.master_samples (title, definition, sensor, controller, actuator, feedback, impact)
select
    'Smart Air Quality Control System',
    'Sistem Kendali adalah susunan sensor, prosesor, dan aktuator yang mengukur kondisi nyata lalu menyesuaikan kinerja secara otomatis tanpa campur tangan manusia terus-menerus.',
    'Sensor PM2.5 / Dust',
    'Mikrokontroler / PID Loop',
    'Kipas HEPA Filter',
    'Sensor membaca ulang hasil penyaringan secara real-time',
    'Respon < 2 detik, hemat energi hingga 40%, menurunkan risiko ISPA hingga 70%'
where not exists (select 1 from public.master_samples);

-- 5) Aktifkan Realtime (dibungkus agar tidak pernah menggagalkan skrip)
do $$
begin
    begin
        alter publication supabase_realtime add table public.student_submissions;
    exception when duplicate_object then
        null;   -- sudah terdaftar, abaikan
    when undefined_object then
        null;   -- publication belum ada, abaikan
    end;
end $$;

-- 6) Konfirmasi
select
    (select count(*) from public.master_samples)       as jumlah_master_samples,
    (select count(*) from public.student_submissions)  as jumlah_draf_siswa;
