-- ============================================================
-- 대치프라임 신규 테이블 (관리자 GUI 편집 기능)
-- Supabase SQL Editor에서 실행
-- ============================================================

-- ────────────────────────────────────────────
-- 1. page_content 테이블 (학원소개 / 커리큘럼)
-- ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS page_content (
  key TEXT PRIMARY KEY,
  value TEXT DEFAULT '',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE page_content ENABLE ROW LEVEL SECURITY;

CREATE POLICY "anon select page_content" ON page_content
  FOR SELECT TO anon USING (true);

CREATE POLICY "anon insert page_content" ON page_content
  FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "anon update page_content" ON page_content
  FOR UPDATE TO anon USING (true);

INSERT INTO page_content (key, value) VALUES
  ('about_greeting', ''),
  ('about_history', ''),
  ('about_features', ''),
  ('curriculum_elementary', ''),
  ('curriculum_middle', ''),
  ('curriculum_high', '')
ON CONFLICT (key) DO NOTHING;

-- ────────────────────────────────────────────
-- 2. faculty 테이블 (강사소개)
-- ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS faculty (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name TEXT NOT NULL,
  subject TEXT NOT NULL,
  motto TEXT DEFAULT '',
  image_url TEXT DEFAULT '',
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE faculty ENABLE ROW LEVEL SECURITY;

CREATE POLICY "anon select faculty" ON faculty
  FOR SELECT TO anon USING (true);

CREATE POLICY "anon insert faculty" ON faculty
  FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "anon update faculty" ON faculty
  FOR UPDATE TO anon USING (true);

CREATE POLICY "anon delete faculty" ON faculty
  FOR DELETE TO anon USING (true);

-- 기존 강사 데이터 이관
INSERT INTO faculty (name, subject, motto, image_url, sort_order) VALUES
  ('김경우', '수학', '포기하지 않는 학생 곁에 끝까지 함께합니다.', '/images/faculty/math-김경우.jpg', 1),
  ('김성환', '수학', '수학의 원리를 깨달으면 두려움이 사라집니다.', '/images/faculty/math-김성환.jpg', 2),
  ('나정환', '수학', '한 문제 한 문제가 실력이 됩니다.', '/images/faculty/math-나정환.jpg', 3),
  ('박명신', '수학', '작은 성취가 쌓여 큰 자신감이 됩니다.', '/images/faculty/math-박명신.jpg', 4),
  ('박주원', '수학', '기초부터 탄탄하게, 함께 올라가겠습니다.', '/images/faculty/math-박주원.jpg', 5),
  ('이재원', '수학', '틀린 문제에서 실력이 자랍니다.', '/images/faculty/math-이재원.jpg', 6),
  ('이희승', '수학', '이해 없는 암기는 없습니다.', '/images/faculty/math-이희승.jpg', 7),
  ('조해공', '수학', '정확한 개념이 최고의 무기입니다.', '/images/faculty/math-조해공.jpg', 8),
  ('함성훈', '수학', '꾸준함이 재능을 이깁니다.', '/images/faculty/math-함성훈.jpg', 9),
  ('허선영', '수학', '모든 학생에게 맞는 풀이법이 있습니다.', '/images/faculty/math-허선영.jpg', 10),
  ('양승경', '영어', '영어는 도구입니다. 자신있게 쓰게 합니다.', '/images/faculty/eng-양승경.jpg', 11),
  ('양윤정', '영어', '읽고 듣고 쓰는 힘을 함께 키웁니다.', '/images/faculty/eng-양윤정.jpg', 12),
  ('이소희', '영어', '점수도 실력도, 함께 올립니다.', '/images/faculty/eng-이소희.jpg', 13),
  ('이정헌', '영어', '문법의 틀 위에 독해를 쌓습니다.', '/images/faculty/eng-이정헌.jpg', 14),
  ('정다운', '영어', '영어가 편안해지는 그날까지.', '/images/faculty/eng-정다운.jpg', 15),
  ('조하늘', '영어', '즐겁게 배우면 오래 기억합니다.', '/images/faculty/eng-조하늘.jpg', 16),
  ('최용우', '영어', '시험에서 흔들리지 않는 실력을 만듭니다.', '/images/faculty/eng-최용우.jpg', 17),
  ('박채원', '영어', '학생의 가능성을 끝까지 믿습니다.', '/images/faculty/eng-박채원.jpg', 18),
  ('김응태', '과학', '왜 그런지 알면 과학이 쉬워집니다.', '/images/faculty/sci-김응태.jpg', 19),
  ('김현철', '과학', '원리를 이해하면 어떤 문제도 풀립니다.', '/images/faculty/sci-김현철.jpg', 20),
  ('고수민', '국어', '글을 읽는 힘이 모든 공부의 기초입니다.', '/images/faculty/kor-고수민.jpg', 21),
  ('석민지', '국어', '정확히 읽고 논리적으로 쓰게 합니다.', '/images/faculty/kor-석민지.jpg', 22),
  ('남명심', '탐독', '깊이 읽는 습관이 모든 학문의 시작입니다.', '/images/faculty/read-남명심.jpg', 23);

-- ────────────────────────────────────────────
-- 3. Storage 버킷 생성 (faculty-images)
-- Supabase Storage > New Bucket > "faculty-images" > Public 체크
-- SQL로는 불가 → 대시보드에서 직접 생성 필요
-- ────────────────────────────────────────────
