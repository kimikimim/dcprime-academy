-- ============================================================
-- 강사(faculty) 테이블에 약력(bio) 필드 추가 + 임원진 3명 약력 반영
-- ============================================================
-- Supabase SQL Editor에서 실행하세요. 재실행해도 안전합니다.
-- 세 분 모두 이미 임원진 division·role로 태깅되어 있어서, 여기서는 약력만 추가합니다.
-- ============================================================

ALTER TABLE faculty ADD COLUMN IF NOT EXISTS bio text DEFAULT '';

-- 임원진 탭은 sort_order 그대로 사용(수동 배치) → 신성호-김응태-박주원 순으로 가운데 배치
-- 신성호 (원장)
UPDATE faculty
SET bio = '- 대치프라임 능곡관, 장곡관 원장
- 입시컨설턴트
- 학원 전략 책임자',
    sort_order = 1
WHERE id = 26;

-- 김응태 (총원장) — 임원진 탭 가운데 배치
UPDATE faculty
SET role = '총원장',
    bio = '- 대치프라임 총원장
- 현 송도 이명학원 과학원장
- 현 목동 에듀41 과학대표강사',
    sort_order = 2
WHERE id = 19;

-- 박주원 (부원장)
UPDATE faculty
SET bio = '- 대치프라임 능곡관, 장곡관 부원장
- 중등 최상위 수학 / 고등 수학',
    sort_order = 3
WHERE id = 5;
