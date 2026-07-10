-- ============================================================
-- exam_reports 테이블 생성 + 기존 진단 평가 데이터 이관
-- Supabase SQL Editor에 붙여넣고 실행
-- ============================================================

CREATE TABLE IF NOT EXISTS exam_reports (
  id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  grade text NOT NULL,
  subject text NOT NULL,
  exam_date text,
  total text,
  difficulty_level text,
  scope text,
  overview text,
  sections jsonb DEFAULT '[]'::jsonb,
  parent_guide text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE (grade, subject)
);
ALTER TABLE exam_reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon select exam_reports" ON exam_reports;
DROP POLICY IF EXISTS "anon insert exam_reports" ON exam_reports;
DROP POLICY IF EXISTS "anon update exam_reports" ON exam_reports;
DROP POLICY IF EXISTS "anon delete exam_reports" ON exam_reports;

CREATE POLICY "anon select exam_reports" ON exam_reports FOR SELECT TO anon USING (true);
CREATE POLICY "anon insert exam_reports" ON exam_reports FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon update exam_reports" ON exam_reports FOR UPDATE TO anon USING (true);
CREATE POLICY "anon delete exam_reports" ON exam_reports FOR DELETE TO anon USING (true);

-- 기존 데이터 이관 (초5/초6/중1 수학의 미완성분은 제외)
INSERT INTO exam_reports (grade, subject, exam_date, total, difficulty_level, scope, overview, sections, parent_guide)
VALUES (
  '초5', '영어',
  $q$2026. 7. 3.$q$,
  $q$34문항 (45분)$q$,
  $q$중상 (3단계 구성)$q$,
  $q$1학기 기말고사$q$,
  $q$문법 24문항, 독해 4문항, 서술형 영작 6문항으로 구성되어 단순 암기를 넘어 문법 개념을 문장 속에서 실제로 적용할 수 있는지를 정밀하게 평가하도록 설계되었습니다. 인칭대명사의 격 변화, 셀 수 없는 명사의 수량 표현, 형용사·부사의 자리 구분 등 실전 문제에서 실수하기 쉬운 영역을 집중 배치하였습니다. 이번 시험은 알고 있는 문법을 정확히 적용하는 능력과 조건을 빠짐없이 충족하는 꼼꼼함을 함께 평가하였으며, 이는 향후 중학교 내신 시험과 직결되는 역량입니다.$q$,
  $j$[{"title": "문법 출제 범위", "type": "list", "items": ["be동사 과거형(Was/Were) 의문문과 응답", "감각동사(feel, taste) + 형용사 보어", "형용사·부사 동형 어휘(late 등)", "인칭대명사(주격·목적격·소유격·소유대명사)", "be동사 현재형 수일치", "부정대명사(-thing, -body, -one) 후치 수식", "관사(a/an, the)", "셀 수 있는 명사와 셀 수 없는 명사, 수량 단위 표현", "There is/are 구문과 수일치", "빈도부사의 위치", "일반동사 과거·현재 부정문", "3인칭 단수 현재형 규칙 변화", "어순 배열 및 조건 영작"]}, {"title": "독해 출제 범위", "type": "list", "items": ["인터뷰문 (암스테르담 자전거 낚시꾼) — 내용 일치 파악", "설명문 (멕시코 망자의 날) — 글의 분위기 파악", "설명문 (우주비행사의 우주복) — 내용 일치 파악", "안내문 (무인 자동결제 상점) — 글의 목적 파악"]}, {"title": "문항별 난이도 분석", "type": "difficulty", "rows": [{"level": "상", "color": "red", "items": "6, 13, 21, 22, 27, 30, 31번", "desc": "복수 조건 동시 판단, 조건 영작, 독해 오답 함정 문항 — 상위권 변별 핵심 문항군"}, {"level": "중", "color": "yellow", "items": "2, 3, 4, 5, 8~11, 14, 15, 17, 18, 20, 23~26, 28, 29, 32, 33번", "desc": "핵심 문법 개념의 문장 적용 능력 확인 — 개념 암기를 넘어 문장 내 적용 훈련 필요"}, {"level": "하", "color": "green", "items": "1, 7, 12, 16, 19, 34번", "desc": "be동사 과거형, 기본 명사 구분, 글의 목적 파악 — 수업 충실 참여 시 무난히 해결 가능"}]}, {"title": "핵심 학습 포인트 및 향후 방향", "type": "keypoints", "items": [{"title": "대명사의 격 변화", "desc": "주격·목적격·소유격·소유대명사를 문장 속 자리(주어/목적어/명사 수식/단독 사용)에 따라 정확히 구별 — 4, 5, 22번 반복 출제", "num": "01"}, {"title": "셀 수 없는 명사와 수량 표현", "desc": "a slice of, a piece of, a glass of 등 단위 표현과 There is/are 수일치 — 9, 11, 13, 17, 23번에 걸쳐 출제", "num": "02"}, {"title": "형용사·부사의 자리와 형태", "desc": "감각동사 뒤 형용사 보어, late처럼 형용사·부사 동형 단어 구분 — 2, 3, 10, 14, 24, 25, 28번", "num": "03"}, {"title": "조건에 맞는 영작(서술형)", "desc": "단어 수 제한·특정 어휘 포함·어순 등 복합 조건 서술형 — 26~30번, 철자와 부호까지 정확히 요구", "num": "04"}]}]$j$::jsonb,
  $q$문법 규칙을 암기할 때 예외 사항을 반드시 함께 정리하는 학습 습관이 중요합니다. 다양한 예문 속에서 배운 규칙을 적용해보는 반복 연습과 함께, 서술형 문항 대비를 위해 정확한 철자와 시제 변화형을 손으로 직접 써보는 훈련을 병행하시길 권해드립니다.$q$
)
ON CONFLICT (grade, subject) DO UPDATE SET
  exam_date = EXCLUDED.exam_date,
  total = EXCLUDED.total,
  difficulty_level = EXCLUDED.difficulty_level,
  scope = EXCLUDED.scope,
  overview = EXCLUDED.overview,
  sections = EXCLUDED.sections,
  parent_guide = EXCLUDED.parent_guide,
  updated_at = now();

INSERT INTO exam_reports (grade, subject, exam_date, total, difficulty_level, scope, overview, sections, parent_guide)
VALUES (
  '초6', '영어',
  $q$2026. 7. 3.$q$,
  $q$32문항 (문법 20문항 / 독해 12문항, 100점)$q$,
  $q$중상(中上)$q$,
  $q$1학기 기말고사$q$,
  $q$이번 7월 진단 평가는 단순 암기를 넘어 문법 규칙의 문맥적 적용력을 묻는 데 초점을 맞추었습니다. 유사한 형태의 오답을 배치하여 예외 규칙까지 정확히 숙지했는지 변별하는 문항과, 문법 오류를 스스로 찾아 교정하는 능력, 영작 능력까지 출제하여 실질적인 활용 능력을 평가하였습니다. 기본 개념을 성실히 학습한 학생이라면 무난히 접근할 수 있으나 예외적 문법 사항과 서술형 문항에서 점수 차가 뚜렷하게 나타날 수 있도록 구성되었습니다.$q$,
  $j$[{"title": "출제 범위", "type": "list", "items": ["【문법】 동사의 시제와 형태 — 일반동사 과거형·현재분사형(ing형), be동사 인칭/수 일치, 현재진행형과 미래형(be going to) 문맥적 구분", "【문법】 대명사 — 인칭대명사·소유대명사·지시대명사의 문맥별 구분", "【문법】 비교구문 — 비교급·최상급의 규칙 및 불규칙 변화, 원급·비교급·최상급 형태의 정확한 활용", "【문법】 전치사 — 다양한 전치사(in, on 등)의 정확한 활용", "【독해】 설명문·정보전달문 등 4개 지문 — 주제 파악, 세부 내용 확인, 추론적 사고, 지시대명사가 가리키는 대상 파악"]}, {"title": "문항별 난이도 분석", "type": "difficulty", "rows": [{"level": "상", "color": "red", "items": "9, 10, 17, 18번", "desc": "비교급·최상급 어법 정오 판단 / 대화문 속 시제 오류 세 곳 동시 교정(서술형) / 비교구문 속 be동사 의미 / 시제와 수 일치 복합 판단"}, {"level": "중", "color": "yellow", "items": "4~6, 14~16, 22번", "desc": "두 가지 문법 요소를 동시에 판단하는 빈칸 짝짓기 / 전치사 구분 / 지문 세부 정보 기반 추론"}, {"level": "하", "color": "green", "items": "나머지 문항", "desc": "동사 변화형과 지시대명사 기본 활용, 지문 주제 및 세부 내용 직접 확인 등 교과서 수준 필수 학습 사항"}]}, {"title": "핵심 학습 포인트 및 향후 방향", "type": "keypoints", "items": [{"title": "단서를 통한 정확한 시제 판단력", "desc": "문장 속 시간 부사구(yesterday, then, every day 등)를 근거로 시제를 대입 — 과거형 불규칙 변화와 인칭·수 일치는 예외 규칙까지 정리 필요 (4, 9, 18번)", "num": "01"}, {"title": "대명사·비교급의 예외 규칙까지 정리", "desc": "인칭대명사·소유대명사·지시대명사를 문맥에 따라 구분 + 비교급·최상급 불규칙 변화(more, most 등) 정확히 문장에 적용 (5, 7, 8, 12, 17번)", "num": "02"}]}]$j$::jsonb,
  $q$문법 규칙을 암기할 때 예외 사항을 반드시 함께 정리하는 학습 습관을 들이는 것이 중요하며, 서술형 문항에 대비하여 정확한 철자와 시제 변화형을 손으로 직접 써보는 훈련을 병행하시길 권해드립니다. 독해 영역에서는 지문을 읽을 때 핵심 문장을 표시하고 지시대명사가 가리키는 대상을 짚어보는 습관을 들이면 안정적인 정답률을 기대할 수 있습니다.$q$
)
ON CONFLICT (grade, subject) DO UPDATE SET
  exam_date = EXCLUDED.exam_date,
  total = EXCLUDED.total,
  difficulty_level = EXCLUDED.difficulty_level,
  scope = EXCLUDED.scope,
  overview = EXCLUDED.overview,
  sections = EXCLUDED.sections,
  parent_guide = EXCLUDED.parent_guide,
  updated_at = now();

INSERT INTO exam_reports (grade, subject, exam_date, total, difficulty_level, scope, overview, sections, parent_guide)
VALUES (
  '초6', '수학',
  $q$2026년 1학기$q$,
  $q$24문항$q$,
  $q$중상 (상위권 변별형)$q$,
  $q$두 수 비교하기 ~ 부피의 단위(1m³)$q$,
  $q$이번 시험은 특정 단원에 치우치지 않고 전 단원을 균형 있게 평가하였습니다. 단순 반복형 연산력만으로는 절대 고득점을 얻기 어려웠으며, 다단계 텍스트 문장을 완벽히 식으로 구조화하는 수학적 문해력이 상위권을 결정하는 핵심 요소였습니다.$q$,
  $j$[{"title": "영역별 출제 비중", "type": "area-table", "rows": [{"area": "비와 비율", "count": "6문항", "pct": "25%", "key": "두 수의 비교, 기준량과 비교하는 양 식별, 백분율 변환", "width": 25}, {"area": "여러 가지 그래프", "count": "6문항", "pct": "25%", "key": "원·띠그래프 자료 해석, 백분율 데이터의 실제 값 환산 및 역산", "width": 25}, {"area": "직육면체·정육면체", "count": "5문항", "pct": "21%", "key": "겨냥도 및 전개도 분석, 3차원 공간 모형의 기하학적 특징 추론", "width": 21}, {"area": "겉넓이·부피", "count": "7문항", "pct": "29%", "key": "입체도형 부피·겉넓이 공식 변형 응용, 부피 단위 환산", "width": 29}]}, {"title": "문항별 난이도 분석", "type": "difficulty", "rows": [{"level": "상", "color": "red", "items": "15, 17, 22, 24번", "desc": "추론·공간지각·복합 사고 변별 — 공간지각력과 논리적 추론 능력 평가"}, {"level": "중", "color": "yellow", "items": "9, 10, 11, 12, 13, 14, 16, 18, 19, 20, 21, 23번", "desc": "개념 응용 및 자료 해석 — 비율 계산 수식화, 그래프 해석"}, {"level": "하", "color": "green", "items": "1, 2, 3, 4, 5, 6, 7, 8번", "desc": "기본 개념 및 계산 역량 확인"}]}, {"title": "대표 변별 문항", "type": "key-items", "rows": [{"num": "13번", "stars": 5, "concept": "백분율 역산", "cause": "서로 다른 두 집단의 기준량 혼동"}, {"num": "14번", "stars": 4, "concept": "그래프 해석", "cause": "비율 계산 수식화 과정의 연산 오류"}, {"num": "15번", "stars": 5, "concept": "입체도형 단면 모서리 추론", "cause": "겨냥도 상에서 대응하는 모서리 관계 이해 부족"}, {"num": "17번", "stars": 5, "concept": "공간추론 및 부피", "cause": "입체도형 내부 숨겨진 부분의 계산 누락"}, {"num": "22번", "stars": 4, "concept": "복합 조건 결합", "cause": "문장 속 복합 힌트를 단계별로 해석하는 논리력 부족"}, {"num": "24번", "stars": 5, "concept": "최종 사고력", "cause": "문장제 조건의 수식화 및 논리적 추론 부족"}]}, {"title": "핵심 역량 지표", "type": "capability", "rows": [{"name": "개념 이해도", "stars": 5, "desc": "공식 암기가 아닌 수학적 원리의 체화 요구"}, {"name": "자료 해석력", "stars": 5, "desc": "그래프의 백분율 데이터를 실제 수량으로 치환하는 능력"}, {"name": "공간 지각력", "stars": 4, "desc": "3차원 입체도형의 단면 및 전개도를 머릿속으로 구상하는 능력"}, {"name": "논리적 추론 능력", "stars": 5, "desc": "주어진 단서들을 유기적으로 연결하여 해법을 유도하는 역량"}, {"name": "계산의 정확성", "stars": 4, "desc": "다단계 연산 및 단위 환산 과정에서의 실수 방지"}]}, {"title": "학생들이 가장 많이 실수하는 유형", "type": "mistake-rank", "rows": [{"rank": "1위", "type": "비와 비율 오류", "cause": "기준량과 비교하는 양의 위치를 뒤바꿔 식을 세움"}, {"rank": "2위", "type": "그래프 해석 한계", "cause": "백분율 숫자 자체에 매몰되어 실제 값으로 환산하지 못함"}, {"rank": "3위", "type": "공간 기하 오류", "cause": "입체도형 보이지 않는 면이나 단면을 고려하지 않음"}, {"rank": "4위", "type": "부피 단위 변환", "cause": "m³ ↔ cm³ 단위 변환 시 0의 개수를 틀리는 실수"}, {"rank": "5위", "type": "응용문제 조건 간과", "cause": "최고난도 문장제에서 뒤쪽에 숨겨진 제한 조건을 읽지 않음"}]}, {"title": "단원별 마스터 처방전", "type": "prescription", "items": [{"unit": "비와 비율", "rx": "문장제 문제를 만나면 식을 세우기 전 반드시 기준량과 비교하는 양을 명시적으로 적어 정리하는 습관이 필요합니다."}, {"unit": "여러 가지 그래프", "rx": "그래프 문항 해결 시 백분율 옆에 반드시 전체 수량에 근거한 실제 수치를 즉각적으로 구해 적는 훈련이 필수적입니다."}, {"unit": "직육면체 및 공간 도형", "rx": "전개도와 겨냥도를 직접 오답 노트에 그리고 손으로 짚어가며 3차원 입체 모델의 이면을 추론하는 연습을 병행해야 합니다."}, {"unit": "겉넓이와 부피", "rx": "부피의 변화나 단면 절단 등 문제 상황의 메커니즘을 먼저 분석한 뒤 수식을 맞춤형으로 변형·적용해야 합니다."}]}]$j$::jsonb,
  $q$이번 평가는 기본 개념에서 응용, 최상위 사고력까지 단계적으로 평가한 시험입니다. 특히 15번, 17번, 22번, 24번은 향후 중학교 1학년 과정의 핵심인 일차방정식의 활용 및 입체도형의 성질 단원과 직결됩니다. 중등 수학의 안정적인 최상위권 안착을 위해 비와 비율의 개념적 이해와 3차원 도형 추론 능력을 철저히 심화 지도로 다지겠습니다.$q$
)
ON CONFLICT (grade, subject) DO UPDATE SET
  exam_date = EXCLUDED.exam_date,
  total = EXCLUDED.total,
  difficulty_level = EXCLUDED.difficulty_level,
  scope = EXCLUDED.scope,
  overview = EXCLUDED.overview,
  sections = EXCLUDED.sections,
  parent_guide = EXCLUDED.parent_guide,
  updated_at = now();

INSERT INTO exam_reports (grade, subject, exam_date, total, difficulty_level, scope, overview, sections, parent_guide)
VALUES (
  '중1', '영어',
  $q$2026. 7. 3.$q$,
  $q$32문항 (문법 20문항 / 독해 12문항)$q$,
  $q$합리적 난이도 (기본기 기반 고득점 가능)$q$,
  $q$중학교 1학년 1학기 진단 평가$q$,
  $q$초등 과정에서 다져온 기본 문법 개념을 중학교 수준으로 확장하여 점검하는 데 중점을 두었습니다. 특히 상태동사의 진행형 제한과 같이 초등 과정에서 다루지 않았던 세밀한 문법 규칙을 포함하여, 단순 암기가 아닌 규칙의 원리를 이해하고 있는지를 변별하고자 하였습니다. 독해 영역에서는 단순한 사실 확인을 넘어, 지문에 제시된 정보를 종합하여 추론하고 필자의 의도를 파악하는 능력을 요구하는 문항이 다수 포함되었습니다.$q$,
  $j$[{"title": "출제 범위", "type": "list", "items": ["【문법】 동사의 시제와 형태 — 현재/과거/미래 시제, 동사 규칙·불규칙 변화형, 상태동사의 진행형 제한(중학 신규 강조)", "【문법】 대명사 — 인칭대명사·소유격·지시대명사 등의 격 변화와 문맥에 맞는 쓰임", "【문법】 비교구문 — 원급, 비교급, 최상급 표현의 형태 변화와 문맥상 적절한 활용", "【문법】 전치사 — 시간, 장소, 방향 뿐 아니라 다양한 전치사의 정확한 쓰임", "【독해】 정보 전달형 지문 — 동물의 생태(악어의 눈물), 과학 실험(시리얼 속 철분과 자석 실험), 사회 캠페인(Earth Hour) 등 다양한 소재의 세부 정보 파악 및 추론"]}, {"title": "문항별 난이도 분석", "type": "difficulty", "rows": [{"level": "상", "color": "red", "items": "8, 11, 18, 22, 30, 31번", "desc": "상태동사의 진행형 제한(8번) / be going to의 현재진행형·미래형 구분(11번) / 대화문 속 오류를 찾아 고치기(18번) / 지시대명사가 가리키는 내용 서술하기(22, 30, 31번)"}, {"level": "중", "color": "yellow", "items": "4, 9, 10, 14, 17, 19, 21, 23~29, 32번", "desc": "비교 표현/be동사의 의미(10, 14, 17, 19번) / 시제 및 수 일치(4, 9번) / 빈칸 추론(21, 25, 29, 32번) / 세부 내용 파악(24, 27번) / 지문의 주제·제목 파악"}, {"level": "하", "color": "green", "items": "나머지 문항", "desc": "대명사(5, 6, 7, 12, 13번) / 동사의 과거형·-ing형 변화(1, 2번) / 비교급·최상급의 기본 형태(3번) / 다양한 전치사 기본 쓰임(15, 16번) / 현재진행형 영작(20번)"}]}, {"title": "핵심 학습 포인트 및 향후 방향", "type": "keypoints", "items": [{"title": "동사의 활용 (상태동사 진행형 제한)", "desc": "감각·인지·소유를 나타내는 동사는 진행형으로 쓰이지 않는다는 규칙은 중학교 문법의 핵심 개념 — 각 동사가 가지는 의미와 특성을 이해하고 문맥에 활용하는 학습 필요", "num": "01"}, {"title": "비교구문의 문맥적 활용", "desc": "원급, 비교급, 최상급의 형태를 아는 것에서 나아가 실제 문장 속에서 어떤 표현이 적절한지 판단하는 연습 필요", "num": "02"}, {"title": "정보 전달형 지문 독해력", "desc": "과학적 원리나 사회적 이슈를 다루는 지문에서 핵심 정보를 정확히 파악하고, 이를 바탕으로 필자의 의도나 다음 내용을 추론하는 훈련 필요", "num": "03"}]}]$j$::jsonb,
  $q$앞으로는 중학교 문법 체계에서 자주 다뤄지는 세부 규칙을 개념 중심으로 정리하고, 다양한 소재의 지문을 꾸준히 접하며 추론적 독해 능력을 함께 길러나가는 학습이 필요합니다. 자녀가 문법 규칙을 단순히 암기하기보다 그 원리를 이해하고 있는지 확인해 주시고, 다양한 주제의 영어 지문을 접할 기회를 늘려 독해에 대한 자신감을 키워주시기를 권장드립니다.$q$
)
ON CONFLICT (grade, subject) DO UPDATE SET
  exam_date = EXCLUDED.exam_date,
  total = EXCLUDED.total,
  difficulty_level = EXCLUDED.difficulty_level,
  scope = EXCLUDED.scope,
  overview = EXCLUDED.overview,
  sections = EXCLUDED.sections,
  parent_guide = EXCLUDED.parent_guide,
  updated_at = now();
