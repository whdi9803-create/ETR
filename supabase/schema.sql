-- ETR (Everyone's Touch Rugby) Supabase schema
-- Supabase 대시보드 > SQL Editor에 이 파일 전체를 붙여넣고 실행하세요.
-- 실행 순서: 이 파일 1번만 실행하면 테이블 + RLS 정책 + storage 버킷까지 한 번에 준비됩니다.

-- ============================================================
-- 1) applications : 웰컴데이 신청자 명단
-- ============================================================
create table if not exists public.applications (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text not null,
  instagram text,                 -- 인스타그램 아이디 (선택)
  how_heard text,                 -- ETR을 어떻게 알게 되셨나요 (복수선택, 콤마로 join)
  exercise_frequency text,        -- 평소 운동 정도 (복수선택, 콤마로 join)
  rugby_experience text,          -- 럭비/터치럭비 경험 여부 (자유 서술)
  motivation text,                -- 참가 동기 (선택)
  utm_source text,
  utm_medium text,
  utm_campaign text,
  referrer text,
  created_at timestamptz not null default now()
);

alter table public.applications enable row level security;

-- 누구나(비로그인 방문자) 신청서를 "제출"할 수 있어야 함
create policy "applications_public_insert"
  on public.applications for insert
  to anon
  with check (true);

-- 신청자 명단 조회/삭제는 로그인한 관리자만
create policy "applications_admin_select"
  on public.applications for select
  to authenticated
  using (true);

create policy "applications_admin_delete"
  on public.applications for delete
  to authenticated
  using (true);

-- ============================================================
-- 2) gallery_photos : 갤러리 사진 메타데이터 (실제 파일은 storage에 저장)
-- ============================================================
create table if not exists public.gallery_photos (
  id uuid primary key default gen_random_uuid(),
  image_path text not null,   -- storage 내 경로 (예: gallery/xxxx.jpg)
  title text not null,
  title_en text,
  meta text,                  -- 예: "Training · 2026.06"
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

alter table public.gallery_photos enable row level security;

-- 갤러리 페이지는 로그인 없이 누구나 봐야 하므로 SELECT는 공개
create policy "gallery_public_select"
  on public.gallery_photos for select
  to anon
  using (true);

-- 추가/수정/삭제는 로그인한 관리자만
create policy "gallery_admin_insert"
  on public.gallery_photos for insert
  to authenticated
  with check (true);

create policy "gallery_admin_update"
  on public.gallery_photos for update
  to authenticated
  using (true);

create policy "gallery_admin_delete"
  on public.gallery_photos for delete
  to authenticated
  using (true);

-- ============================================================
-- 3) schedule : 훈련/웰컴데이 일정
-- ============================================================
create table if not exists public.schedule (
  id uuid primary key default gen_random_uuid(),
  title text not null,            -- 예: WELCOME DAY
  event_date date not null,
  event_time text,                -- 예: 09:00
  location text,
  location_en text,
  bring text,                     -- 예: 운동복 · 축구화, 개인 물
  tag text,                       -- 예: 모집중 · Open
  created_at timestamptz not null default now()
);

alter table public.schedule enable row level security;

create policy "schedule_public_select"
  on public.schedule for select
  to anon
  using (true);

create policy "schedule_admin_insert"
  on public.schedule for insert
  to authenticated
  with check (true);

create policy "schedule_admin_update"
  on public.schedule for update
  to authenticated
  using (true);

create policy "schedule_admin_delete"
  on public.schedule for delete
  to authenticated
  using (true);

-- ============================================================
-- 4) storage bucket : 갤러리 사진 파일 저장용 (public read)
-- ============================================================
insert into storage.buckets (id, name, public)
values ('gallery', 'gallery', true)
on conflict (id) do nothing;

create policy "gallery_bucket_public_read"
  on storage.objects for select
  to public
  using (bucket_id = 'gallery');

create policy "gallery_bucket_admin_write"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'gallery');

create policy "gallery_bucket_admin_update"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'gallery');

create policy "gallery_bucket_admin_delete"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'gallery');

-- ============================================================
-- 5) 초기 일정 시드 (홈페이지 스코어보드에 표시될 다음 세션)
-- ============================================================
insert into public.schedule (title, event_date, event_time, location, location_en, bring, tag)
values (
  'WELCOME DAY',
  '2026-07-25',
  '09:00',
  '잠원한강공원 트랙구장',
  'Jamwon Hangang Park',
  '운동복 · 축구화, 개인 물',
  '모집중 · Open'
);
