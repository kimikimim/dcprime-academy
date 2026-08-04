-- ============================================================
-- 공지사항 → "소식" 카테고리(설명회/평가/공지) 추가
-- ============================================================
-- Supabase SQL Editor에 붙여넣고 실행하세요 (MCP 원격 실행 불가한 프로젝트).
-- 재실행해도 안전합니다 (IF NOT EXISTS / 존재 체크 포함).
-- ============================================================

-- 1. category 컬럼 추가 (기본값 '공지')
ALTER TABLE notices ADD COLUMN IF NOT EXISTS category text NOT NULL DEFAULT '공지';

-- 2. 값 제한 (설명회 / 평가 / 공지 중 하나만 허용)
ALTER TABLE notices DROP CONSTRAINT IF EXISTS notices_category_check;
ALTER TABLE notices ADD CONSTRAINT notices_category_check CHECK (category IN ('설명회', '평가', '공지'));

-- 3. 기존 글 분류 (제목 기반으로 수동 분류, 필요시 adminssh에서 재수정 가능)
UPDATE notices SET category = '평가' WHERE id = 43;  -- 9모 대비 대성 더프리미엄 모의고사 안내
UPDATE notices SET category = '설명회' WHERE id = 42; -- 예비고1 하반기 고교선택 로드맵 & 설명회 안내
UPDATE notices SET category = '공지' WHERE id = 41;   -- 2026 여름방학 특강 안내
UPDATE notices SET category = '설명회' WHERE id = 40; -- 나랑국어 로드맵 학부모 간담회
UPDATE notices SET category = '평가' WHERE id = 38;   -- 1학기 자체 기말고사 공지사항
UPDATE notices SET category = '공지' WHERE id = 37;   -- 2026 여름방학 텐투텐 모집 안내
UPDATE notices SET category = '설명회' WHERE id = 36; -- 2026 여름방학 설명회
UPDATE notices SET category = '평가' WHERE id = 35;   -- 자체 기말고사 실시
UPDATE notices SET category = '공지' WHERE id = 4;    -- 2026 대입/고입 합격현황
UPDATE notices SET category = '공지' WHERE id = 5;    -- 개인정보 처리방침 안내
