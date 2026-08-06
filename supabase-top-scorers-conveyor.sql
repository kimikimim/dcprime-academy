-- ============================================================
-- 성적우수자 탭 "컨베이어 벨트" 세팅
-- ============================================================
-- Supabase SQL Editor에서 실행하세요. 재실행해도 안전합니다.
--
-- 1) top_scorers.year 제약을 "4자리 숫자면 OK"로 완화합니다.
--    (기존엔 연도를 IN ('2023','2024',...) 식으로 하드코딩해서 매년 SQL을
--    새로 돌려야 했는데, 이제 몇 년이 지나도 이 작업이 필요 없습니다.)
-- 2) page_content에 top_scorers_latest_semester 키를 추가합니다.
--    /top-scorers 페이지 탭 중 "가장 최근(맨 왼쪽)" 학기를 저장하는 값이고,
--    여기서부터 과거 6개 학기가 자동으로 탭에 노출됩니다.
--    adminssh "성적우수자" 탭 상단에서 이 값을 바꿀 수 있습니다.
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
  CHECK (year ~ '^[0-9]{4}$');

INSERT INTO page_content (key, value)
VALUES ('top_scorers_latest_semester', '2026,1학기')
ON CONFLICT (key) DO NOTHING;
