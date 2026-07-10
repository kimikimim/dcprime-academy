-- ============================================================
-- exam-sketch 스토리지 버킷 생성 + anon 업로드/삭제 정책
-- Supabase SQL Editor에 붙여넣고 실행
-- (버킷이 이미 있다면 정책만 추가됩니다)
-- ============================================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('exam-sketch', 'exam-sketch', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "public read exam-sketch" ON storage.objects;
DROP POLICY IF EXISTS "anon insert exam-sketch" ON storage.objects;
DROP POLICY IF EXISTS "anon update exam-sketch" ON storage.objects;
DROP POLICY IF EXISTS "anon delete exam-sketch" ON storage.objects;

CREATE POLICY "public read exam-sketch" ON storage.objects
  FOR SELECT TO public USING (bucket_id = 'exam-sketch');

CREATE POLICY "anon insert exam-sketch" ON storage.objects
  FOR INSERT TO anon WITH CHECK (bucket_id = 'exam-sketch');

CREATE POLICY "anon update exam-sketch" ON storage.objects
  FOR UPDATE TO anon USING (bucket_id = 'exam-sketch');

CREATE POLICY "anon delete exam-sketch" ON storage.objects
  FOR DELETE TO anon USING (bucket_id = 'exam-sketch');
