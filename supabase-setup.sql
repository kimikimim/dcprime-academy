-- ============================================================
-- 대치프라임 Supabase 전체 셋업 SQL
-- Supabase SQL Editor에 전체 붙여넣고 한 번에 실행
-- ============================================================

-- ────────────────────────────────────────────
-- 1. notices 테이블 추가 정책 (이미 테이블 있음)
-- ────────────────────────────────────────────
CREATE POLICY "anon insert notices" ON notices
  FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "anon update notices" ON notices
  FOR UPDATE TO anon USING (true);

CREATE POLICY "anon delete notices" ON notices
  FOR DELETE TO anon USING (true);

-- ────────────────────────────────────────────
-- 2. inquiries 테이블 컬럼 추가 + 정책
-- ────────────────────────────────────────────
ALTER TABLE inquiries
  ADD COLUMN IF NOT EXISTS student_name text,
  ADD COLUMN IF NOT EXISTS student_phone text,
  ADD COLUMN IF NOT EXISTS parent_name text,
  ADD COLUMN IF NOT EXISTS parent_phone text,
  ADD COLUMN IF NOT EXISTS school_name text,
  ADD COLUMN IF NOT EXISTS track text,
  ADD COLUMN IF NOT EXISTS grade text,
  ADD COLUMN IF NOT EXISTS branch text,
  ADD COLUMN IF NOT EXISTS agree_privacy boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS agree_marketing boolean DEFAULT false;

CREATE POLICY "anon select inquiries" ON inquiries
  FOR SELECT TO anon USING (true);

CREATE POLICY "anon insert inquiries" ON inquiries
  FOR INSERT TO anon WITH CHECK (true);

-- ────────────────────────────────────────────
-- 3. 관리자 설정 테이블 + 비밀번호 검증 함수
-- ────────────────────────────────────────────
CREATE TABLE admin_config (
  key text PRIMARY KEY,
  value text NOT NULL
);
ALTER TABLE admin_config ENABLE ROW LEVEL SECURITY;
-- 정책 없음 = anon 직접 조회 불가

INSERT INTO admin_config (key, value) VALUES ('admin_password', 'Prime0979!');

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
-- 4. results 테이블 생성 + RLS
-- ────────────────────────────────────────────
CREATE TABLE results (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  year text NOT NULL,
  category text NOT NULL, -- '대입' or '고입'
  school text,            -- 대입: 출신고교 / 고입: 합격고교
  name text NOT NULL,
  university text NOT NULL, -- 대입: 대학교 / 고입: 출신중학교
  dept text,              -- 대입: 학과 / 고입: NULL
  created_at timestamptz DEFAULT now()
);
ALTER TABLE results ENABLE ROW LEVEL SECURITY;
CREATE POLICY "anon select results" ON results FOR SELECT TO anon USING (true);
CREATE POLICY "anon insert results" ON results FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon delete results" ON results FOR DELETE TO anon USING (true);

-- ────────────────────────────────────────────
-- 5. 2026 대입 합격자
-- ────────────────────────────────────────────
INSERT INTO results (year, category, school, name, university, dept) VALUES
('2026', '대입', '함현고', '이○현', '서울대학교', '산림과학부'),
('2026', '대입', '함현고', '이○현', '연세대학교', '식품영양학과'),
('2026', '대입', '능곡고', '장○우', '연세대학교', '불어불문학과'),
('2026', '대입', '시흥고', '나○재', '성균관대학교', '전자전기공학부'),
('2026', '대입', '능곡고', '장○우', '성균관대학교', '글로벌리더학부'),
('2026', '대입', '능곡고', '이○원', '한양대학교', '정치외교학과'),
('2026', '대입', '능곡고', '장○우', '한양대학교', '파이낸스경영학과'),
('2026', '대입', '능곡고', '홍○준', '한양대학교', '경영학부'),
('2026', '대입', '능곡고', '이○원', '중앙대학교', '공공인재학부'),
('2026', '대입', '능곡고', '이○원', '경희대학교', '행정학과'),
('2026', '대입', '능곡고', '이○원', '이화여자대학교', '국제사무학과'),
('2026', '대입', '능곡고', '이○원', '서울시립대학교', '도시행정학과'),
('2026', '대입', '시흥고', '나○재', '서울시립대학교', '전자전기컴퓨터공학부'),
('2026', '대입', '능곡고', '이○원', '건국대학교', '사회과학대학 융합전공학부'),
('2026', '대입', '시흥고', '임○을', '서울과학기술대학교', '미래에너지융합과'),
('2026', '대입', '능곡고', '박○진', '한국외국어대학교', '국제금융학과'),
('2026', '대입', '소래고', '신○찬', '숭실대학교', '벤처중소기업학과'),
('2026', '대입', '능곡고', '박○현', '한국항공대학교', '공과대학'),
('2026', '대입', '능곡고', '조○빈', '인하대학교', '국제통상학과'),
('2026', '대입', '능곡고', '박○현', '인하대학교', '물리학과'),
('2026', '대입', '시흥고', '임○을', '부산대학교', '대기환경과학과'),
('2026', '대입', '시흥고', '임○정', '단국대학교', '정치외교학과'),
('2026', '대입', '소래고', '신○찬', '단국대학교', '경영학부'),
('2026', '대입', '능곡고', '조○빈', '인천대학교', '글로벌트레이드&서비스 학부'),
('2026', '대입', '능곡고', '이○우', '인천대학교', '일본지역문화학과'),
('2026', '대입', '능곡고', '이○빈', '덕성여자대학교', '글로벌융합대학 인문사회'),
('2026', '대입', '능곡고', '이○빈', '가천대학교', '자유전공'),
('2026', '대입', '능곡고', '이○우', '명지대학교', '중어중문학과'),
('2026', '대입', '능곡고', '박○현', '명지대학교', '기계시스템공학부'),
('2026', '대입', '능곡고', '박○진', '경기대학교', '무역학과'),
('2026', '대입', '능곡고', '박○경', '경기대학교', '법학과'),
('2026', '대입', '능곡고', '박○우', '경기대학교', '공공안전학부'),
('2026', '대입', '능곡고', '이○연', '을지대학교', '치위생학과'),
('2026', '대입', '능곡고', '신○후', '을지대학교', '간호학과'),
('2026', '대입', '능곡고', '김○희', '강원대학교', '자유전공학부'),
('2026', '대입', '능곡고', '박○진', '순천향대학교', '국제통상학과'),
('2026', '대입', '능곡고', '김○효', '순천향대학교', '환경보건학과'),
('2026', '대입', '', '하○호', '한국체육대학교', '사회체육학과'),
('2026', '대입', '', '하○호', '서원대학교', '체육교육과');

-- ────────────────────────────────────────────
-- 6. 2026 고입 합격자
-- ────────────────────────────────────────────
INSERT INTO results (year, category, school, name, university, dept) VALUES
('2026', '고입', '디지털미디어고등학교', '김○훈', '가온중3', NULL),
('2026', '고입', '디지털미디어고등학교', '염○찬', '가온중3', NULL),
('2026', '고입', '디지털미디어고등학교', '윤○인', '가온중3', NULL),
('2026', '고입', '안산동산고등학교', '이○아', '능곡중3', NULL),
('2026', '고입', '경기예술고등학교', '이○지', '능곡중3', NULL),
('2026', '고입', '김천고등학교', '김○진', '능곡중3', NULL),
('2026', '고입', '수원외국어고등학교', '김○규', '능곡중3', NULL),
('2026', '고입', '수원외국어고등학교', '이○은', '가온중3', NULL),
('2026', '고입', '수원외국어고등학교', '정○윤', '가온중3', NULL),
('2026', '고입', '수원하이텍고등학교', '이○빈', '능곡중3', NULL),
('2026', '고입', '안법고등학교', '유○영', '능곡중3', NULL),
('2026', '고입', '천안북일고등학교', '이○진', '가온중3', NULL),
('2026', '고입', '안양예술고등학교 문예창작 영재학급', '유○은', '능곡중2', NULL);

-- ────────────────────────────────────────────
-- 7. 2025 대입 합격자
-- ────────────────────────────────────────────
INSERT INTO results (year, category, school, name, university, dept) VALUES
('2025', '대입', '능곡고', '김○혁', '가천대학교', '컴퓨터공학'),
('2025', '대입', '시흥고', '양○준', '가천대학교', '자유전공'),
('2025', '대입', '능곡고', '임○원', '가천대학교', 'AI인문'),
('2025', '대입', '능곡고', '권○비', '경기대학교', '경영학부'),
('2025', '대입', '목감고', '김○준', '경기대학교', '산업경영공학'),
('2025', '대입', '시흥고', '김○현', '경기대학교', '사회에너지시스템공학'),
('2025', '대입', '시흥고', '이○진', '경기대학교', '스마트시티공학'),
('2025', '대입', '능곡고', '최○원', '경기대학교', '기계시스템공학'),
('2025', '대입', '능곡고', '김○규', '경희대학교', '자유전공'),
('2025', '대입', '시흥고', '김○솔', '경희대학교', '정치외교학과'),
('2025', '대입', '함현고', '이○현', '경희대학교', '유전생명공학'),
('2025', '대입', '시흥고', '이○희', '광운대학교', '전자공학'),
('2025', '대입', '능곡고', '원○영', '국민대학교', '미디어광고학부'),
('2025', '대입', '능곡고', '정○훈', '국민대학교', '건설시스템공학'),
('2025', '대입', '목감고', '김○준', '단국대학교', '물리학'),
('2025', '대입', '능곡고', '원○영', '동국대학교', '광고홍보학'),
('2025', '대입', '함현고', '이○현', 'DGIST(디지스트)', '기초학부'),
('2025', '대입', '능곡고', '김○규', '서울과학기술대학교', '기계시스템디자인'),
('2025', '대입', '능곡고', '권○송', '서울시립대학교', '전자전기컴퓨터공학'),
('2025', '대입', '능곡고', '어○은', '서울여자간호대학교', '간호학과'),
('2025', '대입', '시흥고', '안○빈', '서원대학교', '수학교육과'),
('2025', '대입', '장곡고', '정○윤', '서원대학교', '음악교육과'),
('2025', '대입', '시흥고', '우○범', '숭실대학교', '신소재공학'),
('2025', '대입', '능곡고', '원○영', '숭실대학교', '광고홍보학'),
('2025', '대입', '능곡고', '정○훈', '숭실대학교', '건축학'),
('2025', '대입', '시흥고', '우○범', '아주대학교', '신소재공학'),
('2025', '대입', '함현고', '이○현', 'UNIST(유니스트)', '이공계열'),
('2025', '대입', '능곡고', '박○영', '을지대학교', '치위생학'),
('2025', '대입', '능곡고', '권○비', '인천대학교', '경영학부'),
('2025', '대입', '능곡고', '김○혁', '인천대학교', '정보통신공학과'),
('2025', '대입', '시흥고', '양○준', '인천대학교', '에너지화학공학'),
('2025', '대입', '능곡고', '임○원', '인천대학교', '국어국문학'),
('2025', '대입', '능곡고', '홍○아', '인천대학교', '도시공학과'),
('2025', '대입', '시흥고', '김○준', '인하대학교', '컴퓨터공학'),
('2025', '대입', '시흥고', '우○범', '인하대학교', '신소재공학'),
('2025', '대입', '시흥고', '이○희', '인하대학교', '전기전자공학'),
('2025', '대입', '능곡고', '임○원', '인하대학교', '한국어문학'),
('2025', '대입', '능곡고', '정○훈', '인하대학교', '사회인프라공학'),
('2025', '대입', '능곡고', '조○슬', '충남대학교', '천문우주과학'),
('2025', '대입', '능곡고', '조○영', '충북대학교', '자유전공'),
('2025', '대입', '능곡고', '김○혁', '한양대학교', '컴퓨터학부'),
('2025', '대입', '능곡고', '남○은', '한양대학교', '미디어학과'),
('2025', '대입', '능곡고', '원○영', '한양대학교', '광고홍보학과'),
('2025', '대입', '함현고', '이○현', '한양대학교', '바이오메디컬공학'),
('2025', '대입', '능곡고', '최○원', '한국항공대학교', '공과대학');

-- ────────────────────────────────────────────
-- 8. 2025 고입 합격자
-- ────────────────────────────────────────────
INSERT INTO results (year, category, school, name, university, dept) VALUES
('2025', '고입', '동산고', '손○준', '능곡중', NULL),
('2025', '고입', '성남외고', '손○윤', '능곡중', NULL),
('2025', '고입', '세마고', '김○현', '가온중', NULL),
('2025', '고입', '양서고', '양○우', '가온중', NULL),
('2025', '고입', '화성고', '김○주', '능곡중', NULL);

-- ────────────────────────────────────────────
-- 9. faculty divisions 재설정
-- ────────────────────────────────────────────

-- 컬럼 추가 (이미 있으면 무시)
ALTER TABLE faculty ADD COLUMN IF NOT EXISTS divisions text[] DEFAULT ARRAY[]::text[];
ALTER TABLE faculty ADD COLUMN IF NOT EXISTS role text DEFAULT '';

-- 신규 선생님 추가 (없으면 INSERT)
INSERT INTO faculty (name, subject, motto, image_url, sort_order, divisions, role)
VALUES
  ('신주빈', '국어', '', '', 50, ARRAY[]::text[], ''),
  ('강보민', '국어', '', '', 51, ARRAY[]::text[], ''),
  ('신성호', '원장', '', '', 0,  ARRAY[]::text[], '원장')
ON CONFLICT DO NOTHING;

-- 전체 초기화
UPDATE faculty SET divisions = ARRAY[]::text[], role = '';

-- ── 초등부 ──
UPDATE faculty SET divisions = array_append(divisions, '초등부')
WHERE name IN (
  '허선영', '김경우', '함성훈', '조해공', '이재원',  -- 수학
  '양윤정', '박채원', '조하늘', '이소희',             -- 영어
  '석민지',                                           -- 국어
  '남명심'                                            -- 탐독
);

-- ── 중등부 ──
UPDATE faculty SET divisions = array_append(divisions, '중등부')
WHERE name IN (
  '이재원', '함성훈', '조해공', '허선영', '김경우', '나정환',  -- 수학
  '양윤정', '조하늘', '이소희', '박채원',                      -- 영어
  '석민지', '신주빈', '강보민',                                 -- 국어
  '김응태', '김현철',                                           -- 과학
  '남명심'                                                      -- 탐독
);

-- ── 고등부 ──
UPDATE faculty SET divisions = array_append(divisions, '고등부')
WHERE name IN (
  '이희승', '박명신', '김경우', '이재원', '김성환', '나정환', '허선영', '박주원',  -- 수학
  '이정헌', '정다운', '최용우', '양승경',                                          -- 영어
  '고수민', '강보민',                                                              -- 국어
  '남명심',                                                                        -- 입시
  '김응태', '김현철'                                                               -- 과학
);

-- ── 입시와대치 ──
UPDATE faculty SET divisions = array_append(divisions, '입시와대치'), role = '원장'
WHERE name = '신성호';

UPDATE faculty SET divisions = array_append(divisions, '입시와대치'), role = '부원장'
WHERE name = '박주원';

UPDATE faculty SET divisions = array_append(divisions, '입시와대치'), role = '연구원'
WHERE name IN ('이정헌', '남명심', '허선영', '정다운');


-- ────────────────────────────────────────────
-- 10. diagnosis_logs 테이블 생성
-- ────────────────────────────────────────────

-- path JSONB 구조:
-- { "history": ["gpa", "mock", "record", "yaksul_subject"],
--   "answers": { "gpa": "mid", "mock": "none", "record": "weak", "yaksul_subject": "math" } }

CREATE TABLE IF NOT EXISTS diagnosis_logs (
  id         uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  path       jsonb       NOT NULL,
  result_tag text        NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE diagnosis_logs ENABLE ROW LEVEL SECURITY;

-- 비로그인 사용자도 INSERT 가능 (식별 정보 없음)
CREATE POLICY "allow_anon_insert" ON diagnosis_logs
  FOR INSERT TO anon WITH CHECK (true);
