-- ============================================================
-- 성적우수자: 사진 4명(2x2) + 나머지는 이름만(마스킹 표시) 방식으로 변경
-- ============================================================
-- Supabase SQL Editor에 붙여넣고 실행하세요. 재실행해도 안전합니다.
-- ============================================================

-- type 컬럼 추가: 'photo'(사진, 최대 4명 노출) | 'text'(이름만, 마스킹 표시)
ALTER TABLE top_scorers ADD COLUMN IF NOT EXISTS type text NOT NULL DEFAULT 'photo';

ALTER TABLE top_scorers DROP CONSTRAINT IF EXISTS top_scorers_type_check;
ALTER TABLE top_scorers ADD CONSTRAINT top_scorers_type_check CHECK (type IN ('photo', 'text'));

-- text 타입은 사진이 없으므로 image_url을 nullable로 변경
ALTER TABLE top_scorers ALTER COLUMN image_url DROP NOT NULL;

-- 기존에 올라간 사진들은 전부 photo 타입 (기본값이라 자동 반영되지만 명시적으로 한번 더)
UPDATE top_scorers SET type = 'photo' WHERE image_url IS NOT NULL;
