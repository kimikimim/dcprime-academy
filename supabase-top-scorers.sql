-- ============================================================
-- 성적우수자 페이지 (년도/학기별 사진 갤러리)
-- ============================================================
-- Supabase SQL Editor에 붙여넣고 실행하세요 (MCP 원격 실행 불가한 프로젝트).
-- 재실행해도 안전합니다.
-- ============================================================

CREATE TABLE IF NOT EXISTS top_scorers (
  id         bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  year       text NOT NULL,              -- '2024' | '2025' | '2026'
  semester   text NOT NULL,              -- '1학기' | '2학기'
  name       text,                       -- 사진 아래 표시할 이름/문구 (선택)
  image_url  text NOT NULL,
  sort_order integer DEFAULT 0,
  is_active  boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  CHECK (year IN ('2024', '2025', '2026')),
  CHECK (semester IN ('1학기', '2학기'))
);

ALTER TABLE top_scorers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon select top_scorers" ON top_scorers;
DROP POLICY IF EXISTS "anon insert top_scorers" ON top_scorers;
DROP POLICY IF EXISTS "anon update top_scorers" ON top_scorers;
DROP POLICY IF EXISTS "anon delete top_scorers" ON top_scorers;

CREATE POLICY "anon select top_scorers" ON top_scorers FOR SELECT TO anon USING (true);
CREATE POLICY "anon insert top_scorers" ON top_scorers FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon update top_scorers" ON top_scorers FOR UPDATE TO anon USING (true);
CREATE POLICY "anon delete top_scorers" ON top_scorers FOR DELETE TO anon USING (true);

-- 조회 성능을 위한 인덱스 (년도+학기별 필터링이 주 쿼리 패턴)
CREATE INDEX IF NOT EXISTS idx_top_scorers_year_semester ON top_scorers (year, semester, sort_order);

-- Storage 버킷
INSERT INTO storage.buckets (id, name, public) VALUES ('top-scorers-images', 'top-scorers-images', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "public read top-scorers-images" ON storage.objects;
DROP POLICY IF EXISTS "anon insert top-scorers-images" ON storage.objects;
DROP POLICY IF EXISTS "anon update top-scorers-images" ON storage.objects;
DROP POLICY IF EXISTS "anon delete top-scorers-images" ON storage.objects;

CREATE POLICY "public read top-scorers-images" ON storage.objects FOR SELECT TO public USING (bucket_id = 'top-scorers-images');
CREATE POLICY "anon insert top-scorers-images" ON storage.objects FOR INSERT TO anon WITH CHECK (bucket_id = 'top-scorers-images');
CREATE POLICY "anon update top-scorers-images" ON storage.objects FOR UPDATE TO anon USING (bucket_id = 'top-scorers-images');
CREATE POLICY "anon delete top-scorers-images" ON storage.objects FOR DELETE TO anon USING (bucket_id = 'top-scorers-images');
