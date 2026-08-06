-- ============================================================
-- 성적우수자 이름 명단에 학교/과목/등급 필드 추가
-- ============================================================
-- Supabase SQL Editor에서 실행하세요. 재실행해도 안전합니다.
-- ============================================================

ALTER TABLE top_scorers ADD COLUMN IF NOT EXISTS school text;   -- 예: 장곡고3
ALTER TABLE top_scorers ADD COLUMN IF NOT EXISTS subject text;  -- 예: 영어
ALTER TABLE top_scorers ADD COLUMN IF NOT EXISTS grade text;    -- 예: 전교 1등 / 100점
