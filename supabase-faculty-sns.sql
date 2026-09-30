-- ============================================================
-- 강사(faculty) 테이블에 SNS 링크 필드 추가 (인스타그램/블로그/유튜브)
-- ============================================================
-- Supabase SQL Editor에서 실행하세요. 재실행해도 안전합니다.
-- 강사소개 카드에서 링크가 채워진 강사만 아이콘이 노출됩니다.
-- ============================================================

ALTER TABLE faculty ADD COLUMN IF NOT EXISTS instagram_url text;
ALTER TABLE faculty ADD COLUMN IF NOT EXISTS blog_url text;
ALTER TABLE faculty ADD COLUMN IF NOT EXISTS youtube_url text;
