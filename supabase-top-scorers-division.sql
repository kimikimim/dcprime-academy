-- ============================================================
-- 성적우수자 이름 명단에 구분(중등부/고등부) 필드 추가
-- ============================================================
-- Supabase SQL Editor에서 실행하세요. 재실행해도 안전합니다.
-- 페이지에서 이름 명단을 "구분 → 과목" 순서로 섹션을 나눠 보여주기 위한 필드입니다.
-- (초등부는 성적우수자 명단 대상에서 제외)
-- ============================================================

ALTER TABLE top_scorers ADD COLUMN IF NOT EXISTS division text;  -- 중등부 | 고등부

ALTER TABLE top_scorers DROP CONSTRAINT IF EXISTS top_scorers_division_check;
ALTER TABLE top_scorers ADD CONSTRAINT top_scorers_division_check
  CHECK (division IS NULL OR division IN ('중등부', '고등부'));
