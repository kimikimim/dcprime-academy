-- ============================================================
-- faculty divisions 완전 재설정 (기존 SQL 대체)
-- Supabase SQL Editor에서 실행
-- ============================================================

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

-- ── 전체 초기화 ──
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
