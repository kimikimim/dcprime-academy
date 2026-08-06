-- ============================================================
-- 대치프라임 아카데미 — 전체 DB 스키마 (현재 상태 기준 DDL)
-- ============================================================
-- 이 파일은 데이터 이관용 마이그레이션이 아니라, 현재 운영 중인
-- Supabase 스키마를 재구성할 수 있도록 정리해 둔 참고용 DDL입니다.
-- (실제 마이그레이션 이력은 프로젝트 루트의 supabase-*.sql 참고)
--
-- 실행 방법: Supabase SQL Editor에 붙여넣고 실행 (MCP 원격 실행 불가한 프로젝트)
-- 모든 문장에 IF NOT EXISTS / DROP POLICY IF EXISTS를 사용해 재실행해도 안전합니다.
-- ============================================================


-- ────────────────────────────────────────────
-- 1. notices — 소식 (구 공지사항, category: 설명회/평가/공지)
-- ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS notices (
  id         bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  title      text NOT NULL,
  content    text NOT NULL,
  category   text NOT NULL DEFAULT '공지' CHECK (category IN ('설명회', '평가', '공지')),
  views      integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE notices ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon select notices" ON notices;
DROP POLICY IF EXISTS "anon insert notices" ON notices;
DROP POLICY IF EXISTS "anon update notices" ON notices;
DROP POLICY IF EXISTS "anon delete notices" ON notices;

CREATE POLICY "anon select notices" ON notices FOR SELECT TO anon USING (true);
CREATE POLICY "anon insert notices" ON notices FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon update notices" ON notices FOR UPDATE TO anon USING (true);
CREATE POLICY "anon delete notices" ON notices FOR DELETE TO anon USING (true);


-- ────────────────────────────────────────────
-- 2. inquiries — 상담 신청
-- ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS inquiries (
  id              bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  student_name    text,
  student_phone   text,
  parent_name     text,
  parent_phone    text,
  school          text,
  track           text,
  grade           text,
  branch          text[] DEFAULT ARRAY[]::text[],
  subjects        text[] DEFAULT ARRAY[]::text[],
  other_detail    text,
  agree_privacy   boolean DEFAULT false,
  agree_marketing boolean DEFAULT false,
  status          text DEFAULT 'new', -- new | contacted | consulting | enrolled | closed
  assigned_to     text,
  admin_note      text,
  contacted_at    timestamptz,
  created_at      timestamptz DEFAULT now()
);
ALTER TABLE inquiries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon select inquiries" ON inquiries;
DROP POLICY IF EXISTS "anon insert inquiries" ON inquiries;
DROP POLICY IF EXISTS "anon update inquiries" ON inquiries;
DROP POLICY IF EXISTS "anon delete inquiries" ON inquiries;

CREATE POLICY "anon select inquiries" ON inquiries FOR SELECT TO anon USING (true);
CREATE POLICY "anon insert inquiries" ON inquiries FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon update inquiries" ON inquiries FOR UPDATE TO anon USING (true);
CREATE POLICY "anon delete inquiries" ON inquiries FOR DELETE TO anon USING (true);


-- ────────────────────────────────────────────
-- 3. admin_config — 관리자 비밀번호 (anon 직접 조회 불가, RPC로만 검증)
-- ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS admin_config (
  key   text PRIMARY KEY,
  value text NOT NULL
);
ALTER TABLE admin_config ENABLE ROW LEVEL SECURITY;
-- 정책 없음 = anon 직접 조회 불가 (verify_admin_password RPC로만 접근)

INSERT INTO admin_config (key, value) VALUES ('admin_password', 'Prime0979!')
ON CONFLICT (key) DO NOTHING;

CREATE OR REPLACE FUNCTION verify_admin_password(pw text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  stored_pw text;
BEGIN
  SELECT value INTO stored_pw FROM admin_config WHERE key = 'admin_password';
  RETURN stored_pw = pw;
END;
$$;

GRANT EXECUTE ON FUNCTION verify_admin_password(text) TO anon;


-- ────────────────────────────────────────────
-- 4. results — 명예의 전당 (연도별 합격자)
-- ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS results (
  id         bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  year       text NOT NULL,
  category   text NOT NULL, -- '대입' | '고입'
  school     text,          -- 대입: 출신고교 / 고입: 합격고교
  name       text NOT NULL,
  university text NOT NULL, -- 대입: 대학교 / 고입: 출신중학교
  dept       text,          -- 대입: 학과 / 고입: NULL
  created_at timestamptz DEFAULT now()
);
ALTER TABLE results ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon select results" ON results;
DROP POLICY IF EXISTS "anon insert results" ON results;
DROP POLICY IF EXISTS "anon delete results" ON results;

CREATE POLICY "anon select results" ON results FOR SELECT TO anon USING (true);
CREATE POLICY "anon insert results" ON results FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon delete results" ON results FOR DELETE TO anon USING (true);


-- ────────────────────────────────────────────
-- 5. page_content — Quill 에디터 텍스트 콘텐츠 (학원소개/커리큘럼 등)
-- ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS page_content (
  key        text PRIMARY KEY,
  value      text DEFAULT '',
  updated_at timestamptz DEFAULT now()
);
ALTER TABLE page_content ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon select page_content" ON page_content;
DROP POLICY IF EXISTS "anon insert page_content" ON page_content;
DROP POLICY IF EXISTS "anon update page_content" ON page_content;

CREATE POLICY "anon select page_content" ON page_content FOR SELECT TO anon USING (true);
CREATE POLICY "anon insert page_content" ON page_content FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon update page_content" ON page_content FOR UPDATE TO anon USING (true);

-- 사용 중인 key: about_features, about_history, about_rules,
-- curriculum_korean, curriculum_english, curriculum_math, curriculum_science,
-- curriculum_tamdoq, curriculum_entrance, in_house_exam_notice


-- ────────────────────────────────────────────
-- 6. faculty — 강사소개
-- ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS faculty (
  id         bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name       text NOT NULL,
  subject    text NOT NULL,
  motto      text DEFAULT '',
  image_url  text DEFAULT '',
  sort_order integer DEFAULT 0,
  divisions  text[] DEFAULT ARRAY[]::text[], -- 초등부 | 중등부 | 고등부 | 입시와대치 (중복 가능)
  role       text DEFAULT '',                -- 입시와대치 전용: 원장 | 부원장 | 연구원
  created_at timestamptz DEFAULT now()
);
ALTER TABLE faculty ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon select faculty" ON faculty;
DROP POLICY IF EXISTS "anon insert faculty" ON faculty;
DROP POLICY IF EXISTS "anon update faculty" ON faculty;
DROP POLICY IF EXISTS "anon delete faculty" ON faculty;

CREATE POLICY "anon select faculty" ON faculty FOR SELECT TO anon USING (true);
CREATE POLICY "anon insert faculty" ON faculty FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon update faculty" ON faculty FOR UPDATE TO anon USING (true);
CREATE POLICY "anon delete faculty" ON faculty FOR DELETE TO anon USING (true);


-- ────────────────────────────────────────────
-- 7. hero_slides — 메인 배너 슬라이드
-- ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS hero_slides (
  id         bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  image_url  text NOT NULL,
  eyebrow    text,
  title      text,
  subtitle   text,
  cta_text   text,
  cta_link   text,
  sort_order integer DEFAULT 0,
  is_active  boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE hero_slides ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon select hero_slides" ON hero_slides;
DROP POLICY IF EXISTS "anon insert hero_slides" ON hero_slides;
DROP POLICY IF EXISTS "anon update hero_slides" ON hero_slides;
DROP POLICY IF EXISTS "anon delete hero_slides" ON hero_slides;

CREATE POLICY "anon select hero_slides" ON hero_slides FOR SELECT TO anon USING (true);
CREATE POLICY "anon insert hero_slides" ON hero_slides FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon update hero_slides" ON hero_slides FOR UPDATE TO anon USING (true);
CREATE POLICY "anon delete hero_slides" ON hero_slides FOR DELETE TO anon USING (true);


-- ────────────────────────────────────────────
-- 8. space_photos — 학원소개 SPACE 탭 교육환경 사진
-- ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS space_photos (
  id         bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  campus     text NOT NULL, -- neunggok | janggok
  caption    text,
  image_url  text NOT NULL,
  sort_order integer DEFAULT 0,
  is_active  boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE space_photos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon select space_photos" ON space_photos;
DROP POLICY IF EXISTS "anon insert space_photos" ON space_photos;
DROP POLICY IF EXISTS "anon update space_photos" ON space_photos;
DROP POLICY IF EXISTS "anon delete space_photos" ON space_photos;

CREATE POLICY "anon select space_photos" ON space_photos FOR SELECT TO anon USING (true);
CREATE POLICY "anon insert space_photos" ON space_photos FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon update space_photos" ON space_photos FOR UPDATE TO anon USING (true);
CREATE POLICY "anon delete space_photos" ON space_photos FOR DELETE TO anon USING (true);


-- ────────────────────────────────────────────
-- 9. exam_reports — in_house_exam.astro 진단 평가 분석 리포트
-- ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS exam_reports (
  id                bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  grade             text NOT NULL,  -- 초5 | 초6 | 중1
  subject           text NOT NULL,  -- 국어 | 영어 | 수학 | 과학
  exam_date         text,
  total             text,
  difficulty_level  text,
  scope             text,
  overview          text,
  sections          jsonb DEFAULT '[]'::jsonb, -- 섹션 타입별 구조는 CLAUDE.md 참고
  parent_guide      text,
  created_at        timestamptz DEFAULT now(),
  updated_at        timestamptz DEFAULT now(),
  UNIQUE (grade, subject)
);
ALTER TABLE exam_reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon select exam_reports" ON exam_reports;
DROP POLICY IF EXISTS "anon insert exam_reports" ON exam_reports;
DROP POLICY IF EXISTS "anon update exam_reports" ON exam_reports;
DROP POLICY IF EXISTS "anon delete exam_reports" ON exam_reports;

CREATE POLICY "anon select exam_reports" ON exam_reports FOR SELECT TO anon USING (true);
CREATE POLICY "anon insert exam_reports" ON exam_reports FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon update exam_reports" ON exam_reports FOR UPDATE TO anon USING (true);
CREATE POLICY "anon delete exam_reports" ON exam_reports FOR DELETE TO anon USING (true);


-- ────────────────────────────────────────────
-- 10. seminar_bookings — 설명회 신청 (phone 기준 중복 신청 방지는 앱 레벨)
-- ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS seminar_bookings (
  id            bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  campus        text NOT NULL,
  name          text NOT NULL,
  grade         text,
  phone         text NOT NULL,
  memo          text,
  agree_privacy boolean DEFAULT false,
  status        text DEFAULT 'new',
  created_at    timestamptz DEFAULT now()
);
ALTER TABLE seminar_bookings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon select seminar_bookings" ON seminar_bookings;
DROP POLICY IF EXISTS "anon insert seminar_bookings" ON seminar_bookings;
DROP POLICY IF EXISTS "anon update seminar_bookings" ON seminar_bookings;
DROP POLICY IF EXISTS "anon delete seminar_bookings" ON seminar_bookings;

CREATE POLICY "anon select seminar_bookings" ON seminar_bookings FOR SELECT TO anon USING (true);
CREATE POLICY "anon insert seminar_bookings" ON seminar_bookings FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon update seminar_bookings" ON seminar_bookings FOR UPDATE TO anon USING (true);
CREATE POLICY "anon delete seminar_bookings" ON seminar_bookings FOR DELETE TO anon USING (true);


-- ────────────────────────────────────────────
-- 11. high3_consults — 고3 7월 대입 로드맵 상담 신청
-- ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS high3_consults (
  id                bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name              text NOT NULL,
  phone             text NOT NULL,
  school            text,
  interest_program  text,
  memo              text,
  diagnostic_result text, -- ques.astro 진단 퀴즈 결과 태그 연동
  agree_privacy     boolean DEFAULT false,
  created_at        timestamptz DEFAULT now()
);
ALTER TABLE high3_consults ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon select high3_consults" ON high3_consults;
DROP POLICY IF EXISTS "anon insert high3_consults" ON high3_consults;
DROP POLICY IF EXISTS "anon delete high3_consults" ON high3_consults;

CREATE POLICY "anon select high3_consults" ON high3_consults FOR SELECT TO anon USING (true);
CREATE POLICY "anon insert high3_consults" ON high3_consults FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon delete high3_consults" ON high3_consults FOR DELETE TO anon USING (true);


-- ────────────────────────────────────────────
-- 12. diagnosis_logs — 대입 전략 진단 퀴즈 로그 (ques.astro / Diagnosis.jsx)
-- ────────────────────────────────────────────
-- path jsonb 구조: { "history": string[], "answers": Record<string, string> }
CREATE TABLE IF NOT EXISTS diagnosis_logs (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  path       jsonb NOT NULL,
  result_tag text NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL
);
ALTER TABLE diagnosis_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "allow_anon_insert" ON diagnosis_logs;
DROP POLICY IF EXISTS "anon select diagnosis_logs" ON diagnosis_logs;

CREATE POLICY "allow_anon_insert" ON diagnosis_logs FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon select diagnosis_logs" ON diagnosis_logs FOR SELECT TO anon USING (true);


-- ────────────────────────────────────────────
-- 13. top_scorers — 성적우수자 (년도/학기별 사진 4칸 + 나머지는 학교/이름/과목/등급 명단)
-- ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS top_scorers (
  id         bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  year       text NOT NULL CHECK (year IN ('2024', '2025', '2026')),
  semester   text NOT NULL CHECK (semester IN ('1학기', '2학기')),
  type       text NOT NULL DEFAULT 'photo' CHECK (type IN ('photo', 'text')), -- photo: 사진(4칸 고정 노출) / text: 학교/이름/과목/등급 명단(이름만 마스킹 표시)
  name       text,       -- type='text'일 때 실명 (화면엔 중간 글자를 O로 마스킹해서 표시)
  school     text,       -- type='text'일 때, 예: 장곡고3
  subject    text,       -- type='text'일 때, 예: 영어
  grade      text,       -- type='text'일 때, 예: 전교 1등 / 100점
  image_url  text,       -- type='photo'일 때만 사용
  sort_order integer DEFAULT 0,
  is_active  boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE top_scorers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon select top_scorers" ON top_scorers;
DROP POLICY IF EXISTS "anon insert top_scorers" ON top_scorers;
DROP POLICY IF EXISTS "anon update top_scorers" ON top_scorers;
DROP POLICY IF EXISTS "anon delete top_scorers" ON top_scorers;

CREATE POLICY "anon select top_scorers" ON top_scorers FOR SELECT TO anon USING (true);
CREATE POLICY "anon insert top_scorers" ON top_scorers FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon update top_scorers" ON top_scorers FOR UPDATE TO anon USING (true);
CREATE POLICY "anon delete top_scorers" ON top_scorers FOR DELETE TO anon USING (true);

CREATE INDEX IF NOT EXISTS idx_top_scorers_year_semester ON top_scorers (year, semester, sort_order);


-- ────────────────────────────────────────────
-- 14. Storage 버킷 + 정책
-- ────────────────────────────────────────────
INSERT INTO storage.buckets (id, name, public) VALUES
  ('notice-images', 'notice-images', true),
  ('faculty-images', 'faculty-images', true),
  ('hero-images', 'hero-images', true),
  ('space-images', 'space-images', true),
  ('exam-sketch', 'exam-sketch', true),
  ('top-scorers-images', 'top-scorers-images', true)
ON CONFLICT (id) DO NOTHING;

DO $$
DECLARE
  bucket text;
BEGIN
  FOREACH bucket IN ARRAY ARRAY['notice-images', 'faculty-images', 'hero-images', 'space-images', 'exam-sketch', 'top-scorers-images']
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %L ON storage.objects', 'public read ' || bucket);
    EXECUTE format('DROP POLICY IF EXISTS %L ON storage.objects', 'anon insert ' || bucket);
    EXECUTE format('DROP POLICY IF EXISTS %L ON storage.objects', 'anon update ' || bucket);
    EXECUTE format('DROP POLICY IF EXISTS %L ON storage.objects', 'anon delete ' || bucket);

    EXECUTE format(
      'CREATE POLICY %L ON storage.objects FOR SELECT TO public USING (bucket_id = %L)',
      'public read ' || bucket, bucket
    );
    EXECUTE format(
      'CREATE POLICY %L ON storage.objects FOR INSERT TO anon WITH CHECK (bucket_id = %L)',
      'anon insert ' || bucket, bucket
    );
    EXECUTE format(
      'CREATE POLICY %L ON storage.objects FOR UPDATE TO anon USING (bucket_id = %L)',
      'anon update ' || bucket, bucket
    );
    EXECUTE format(
      'CREATE POLICY %L ON storage.objects FOR DELETE TO anon USING (bucket_id = %L)',
      'anon delete ' || bucket, bucket
    );
  END LOOP;
END $$;
