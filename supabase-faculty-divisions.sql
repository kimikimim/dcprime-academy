-- ============================================================
-- faculty 테이블 divisions / role 컬럼 추가
-- Supabase SQL Editor에서 실행
-- ============================================================

ALTER TABLE faculty ADD COLUMN IF NOT EXISTS divisions text[] DEFAULT ARRAY[]::text[];
ALTER TABLE faculty ADD COLUMN IF NOT EXISTS role text DEFAULT '';

-- ── 초등부 ──
UPDATE faculty SET divisions = array_append(COALESCE(divisions, ARRAY[]::text[]), '초등부')
WHERE name IN ('허선영', '김경우', '함성훈', '조해공', '이재원') AND subject = '수학';

UPDATE faculty SET divisions = array_append(COALESCE(divisions, ARRAY[]::text[]), '초등부')
WHERE name IN ('양윤정', '박채원', '조하늘', '이소희') AND subject = '영어';

UPDATE faculty SET divisions = array_append(COALESCE(divisions, ARRAY[]::text[]), '초등부')
WHERE name = '석민지';

UPDATE faculty SET divisions = array_append(COALESCE(divisions, ARRAY[]::text[]), '초등부')
WHERE name = '남명심';

-- ── 중등부 ──
UPDATE faculty SET divisions = array_append(COALESCE(divisions, ARRAY[]::text[]), '중등부')
WHERE name = '석민지';

UPDATE faculty SET divisions = array_append(COALESCE(divisions, ARRAY[]::text[]), '중등부')
WHERE name = '남명심';

UPDATE faculty SET divisions = array_append(COALESCE(divisions, ARRAY[]::text[]), '중등부')
WHERE name IN ('김응태', '김현철');

-- ── 고등부 ──
UPDATE faculty SET divisions = array_append(COALESCE(divisions, ARRAY[]::text[]), '고등부')
WHERE name IN ('고수민', '남명심');

UPDATE faculty SET divisions = array_append(COALESCE(divisions, ARRAY[]::text[]), '고등부')
WHERE name IN ('김응태', '김현철', '박명신');

-- ── 입시와대치 ──
UPDATE faculty SET
  divisions = array_append(COALESCE(divisions, ARRAY[]::text[]), '입시와대치'),
  role = '부원장'
WHERE name = '박주원';

UPDATE faculty SET
  divisions = array_append(COALESCE(divisions, ARRAY[]::text[]), '입시와대치'),
  role = '연구원'
WHERE name IN ('이정헌', '남명심', '허선영', '정다운');

-- ── 신규 선생님 추가 ──
INSERT INTO faculty (name, subject, motto, image_url, sort_order, divisions)
VALUES
  ('신주빈', '국어', '', '', 50, ARRAY['중등부']),
  ('강보민', '국어', '', '', 51, ARRAY['중등부', '고등부']),
  ('신성호', '원장', '', '', 0,  ARRAY['입시와대치'])
ON CONFLICT DO NOTHING;

UPDATE faculty SET role = '원장', sort_order = 0 WHERE name = '신성호';
