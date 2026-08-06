-- ============================================================
-- 성적우수자 연도 범위에 2023 추가 (탭이 2023 2학기까지 확장됨)
-- ============================================================
-- Supabase SQL Editor에서 실행하세요. 재실행해도 안전합니다.
-- year 컬럼에 이름 없이 걸려있던 기존 CHECK 제약을 찾아 지우고
-- 2023을 포함한 새 제약으로 교체합니다.
-- ============================================================

DO $$
DECLARE
  con record;
BEGIN
  FOR con IN
    SELECT conname FROM pg_constraint
    WHERE conrelid = 'top_scorers'::regclass
      AND contype = 'c'
      AND pg_get_constraintdef(oid) ILIKE '%year%'
  LOOP
    EXECUTE format('ALTER TABLE top_scorers DROP CONSTRAINT %I', con.conname);
  END LOOP;
END $$;

ALTER TABLE top_scorers ADD CONSTRAINT top_scorers_year_check
  CHECK (year IN ('2023', '2024', '2025', '2026'));
