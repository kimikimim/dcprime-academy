# 대치프라임 아카데미 사이트 - 프로젝트 문서

## 기술 스택
- **프레임워크**: Astro 6 (SSG, `ClientRouter`로 SPA 전환 효과) + React 19 (일부 인터랙티브 컴포넌트)
- **스타일**: Tailwind CSS v4 (`@tailwindcss/vite`)
- **DB/백엔드**: Supabase (PostgreSQL + Storage), 클라이언트에서 anon key로 직접 읽고 씀 (서버 API 없음)
- **배포**: Cloudflare Pages (`dcprime.co.kr` 도메인 연결) — 빌드 명령 `npm run build`, 출력 폴더 `dist` (별도 어댑터/설정 파일 없이 정적 빌드 그대로 배포)
- **코드 저장소**:
  - `origin` → `kimikimim/dcprime-academy`
  - `suo1250` → `suo1250-lab/dcprime-academy`
  - 푸시 시 항상 둘 다: `git push && git push suo1250 main`

---

## 환경변수 (`.env`)
- `PUBLIC_SUPABASE_URL`
- `PUBLIC_SUPABASE_ANON_KEY`
- `PUBLIC_KAKAO_MAP_KEY` (directions.astro 카카오맵 표시용)

---

## 프로젝트 구조

```
src/
├── pages/
│   ├── index.astro          # 메인 홈페이지
│   ├── about.astro           # 학원소개 (탭: 학원특징/HISTORY/SPACE/학원생활 관리규정)
│   ├── curriculum.astro      # 커리큘럼 (2×3 그리드 탭: 국어/영어/수학/과학/탐독/입시와 대치)
│   ├── faculty.astro         # 강사소개 (탭: 초등부/중등부/고등부/입시와대치)
│   ├── results.astro         # 명예의 전당 (DB에서 연도별 합격자 집계)
│   ├── notice.astro          # 공지사항 목록
│   ├── notice/[id].astro     # 공지 상세
│   ├── inquiry.astro         # 상담 신청
│   ├── branches.astro        # 오시는 길 안내 (능곡관/장곡관)
│   ├── directions.astro      # 지도 (카카오맵)
│   ├── in_house_exam.astro   # 자체 진단 평가 분석 리포트 + 기말고사 스케치 (헤더 메뉴에는 없음, 링크 직접 공유)
│   ├── high3.astro           # 고3 전용 7월 대입 로드맵 상담 신청 랜딩 (헤더 메뉴에는 없음)
│   ├── ques.astro            # 대입 전략 진단 퀴즈 (React `Diagnosis.jsx` 렌더, high3와 연계)
│   ├── seminar.astro         # 설명회 신청 랜딩 (연락처 중복 신청 방지 로직 포함)
│   ├── tamdoq.astro          # 탐독(자기주도학습 시스템) 소개 페이지
│   ├── privacy-policy.astro
│   ├── terms-of-service.astro
│   └── adminssh.astro        # 관리자 페이지 (비번: `Prime0979!`)
│
├── components/
│   ├── Diagnosis.jsx          # 대입 전략 진단 퀴즈 로직 (React, ques.astro에서 사용)
│   ├── forms/
│   │   └── InquiryForm.astro
│   ├── layout/
│   │   ├── Layout.astro       # 공통 레이아웃 (OG태그, sitemap, canonical 포함)
│   │   ├── Header.astro       # 헤더/네비게이션 (대치프라임/커리큘럼/강사소개/명예의 전당/공지사항/상담 신청)
│   │   └── Footer.astro
│   ├── sections/              # 메인페이지 섹션들
│   │   ├── HeroSection.astro       # DB(hero_slides) 없으면 기본 배너
│   │   ├── PainPointsSection.astro
│   │   ├── DifferentiationsSection.astro
│   │   ├── CurriculumOverviewSection.astro
│   │   ├── ResultsSection.astro    # DB에서 최신 연도 합격자 수 자동 집계
│   │   ├── FacultyPreviewSection.astro
│   │   ├── TestimonialsSection.astro
│   │   ├── BranchPreviewSection.astro
│   │   └── FinalCTABanner.astro
│   └── ui/
│       ├── SectionTitle.astro
│       └── Button.astro
│
└── lib/
    └── supabase.ts           # Supabase 클라이언트 (env 없으면 콘솔에 에러 로그)
```

---

## Supabase 설정

- **프로젝트 ID**: `smnakhjdtbqgwocwlluz`
- **URL**: `https://smnakhjdtbqgwocwlluz.supabase.co`
- 이 프로젝트는 Claude Code에 연결된 Supabase MCP 계정 소유가 아니므로, SQL은 **Supabase SQL Editor에 직접 붙여넣어 수동 실행**해야 함 (MCP로 원격 실행 불가)

### 테이블 목록

| 테이블 | 용도 |
|--------|------|
| `notices` | 공지사항 (title, content, views, created_at) |
| `inquiries` | 상담 신청 (student_name, student_phone, parent_name, parent_phone, school, track, grade, branch[], subjects[], other_detail, agree_privacy, agree_marketing, status, assigned_to, admin_note, contacted_at) |
| `results` | 명예의 전당 (year, category, school, name, university, dept) |
| `admin_config` | 관리자 비밀번호 (`key='admin_password'`, `value='Prime0979!'`), RLS로 anon 직접 조회 불가 (RPC로만 검증) |
| `page_content` | Quill 에디터로 편집하는 텍스트 콘텐츠 (key, value) — 아래 키 목록 참고 |
| `faculty` | 강사 정보 (name, subject, motto, image_url, sort_order, divisions[], role) |
| `hero_slides` | 메인 배너 슬라이드 (image_url, eyebrow, title, subtitle, cta_text, cta_link, sort_order, is_active) |
| `space_photos` | 학원소개 SPACE 탭 교육환경 사진 (campus, caption, sort_order, is_active, image_url) |
| `exam_reports` | in_house_exam 진단 평가 분석 리포트 (grade, subject, exam_date, total, difficulty_level, scope, overview, sections jsonb, parent_guide) — `(grade, subject)` unique, admin에서 upsert |
| `seminar_bookings` | 설명회 신청 (campus, name, grade, phone, memo, agree_privacy, status) — phone 기준 중복 신청 방지 |
| `high3_consults` | 고3 로드맵 상담 신청 (name, phone, school, interest_program, memo, diagnostic_result, agree_privacy) |
| `diagnosis_logs` | 대입 전략 진단 퀴즈 로그 (path jsonb: `{answers, history}`, result_tag) |

### page_content 키 목록
- `about_features`, `about_history`, `about_rules` (about.astro — SPACE 탭은 `space_photos` 테이블 사용)
- `curriculum_korean`, `curriculum_english`, `curriculum_math`, `curriculum_science`, `curriculum_tamdoq`, `curriculum_entrance`
- `in_house_exam_notice` — in_house_exam.astro 상단 안내 한 줄 (관리자 "출제 경향" 탭에서 편집)

### faculty 테이블 divisions 구조
- `divisions`: text[] 배열 (`초등부`, `중등부`, `고등부`, `입시와대치` 중복 가능)
- `role`: 입시와대치 직책 (원장/부원장/연구원)

### exam_reports 테이블 sections(jsonb) 구조
각 항목은 `type`에 따라 필드가 다른 카드 하나를 나타냄. in_house_exam.astro의 `renderSection()`이 타입별로 렌더링:
- `list` — `{ title, type: 'list', items: string[] }`
- `difficulty` — `{ title, type: 'difficulty', rows: [{ level, color, items, desc }] }`
- `keypoints` — `{ title, type: 'keypoints', items: [{ num, title, desc }] }`
- `area-table` — `{ title, type: 'area-table', rows: [{ area, count, pct, key, width }] }`
- `key-items` — `{ title, type: 'key-items', rows: [{ num, stars, concept, cause }] }`
- `capability` — `{ title, type: 'capability', rows: [{ name, stars, desc }] }`
- `mistake-rank` — `{ title, type: 'mistake-rank', rows: [{ rank, type, cause }] }`
- `prescription` — `{ title, type: 'prescription', items: [{ unit, rx }] }`

관리자는 이 JSON을 "출제 경향" 탭 텍스트박스에 직접 입력/수정함 (구조화 폼 아님).

### Storage 버킷
- `notice-images`: Quill 에디터 이미지 삽입 기본 버킷 (공지사항, 학원소개, 커리큘럼 등에서 공용 사용)
- `faculty-images`: 강사 프로필 사진
- `hero-images`: 메인 배너 이미지
- `space-images`: 학원소개 SPACE 탭 교육환경 사진
- `exam-sketch`: in_house_exam.astro 자체 기말고사 스케치 사진 — 학기 구분 없이 계속 누적, 관리자에서 개별 삭제만 가능 (전체 초기화 버튼 없음)

### RPC 함수
- `verify_admin_password(pw text)`: 관리자 로그인 검증

---

## 관리자 페이지 (`/adminssh`)

비밀번호: `Prime0979!`

탭 구성:
1. **메인페이지 관리** - 히어로 배너 슬라이드 CRUD (`hero_slides`)
2. **공지사항 관리** - Quill 에디터로 작성/수정/삭제
3. **상담 신청 목록** - 상태/담당자/메모 관리, 필터(상태·분원·학년·과목·고가치)
4. **대치프라임** - 학원특징/HISTORY/SPACE(사진 CRUD)/학원생활 관리규정 Quill 편집
5. **커리큘럼** - 국어/영어/수학/과학/탐독/입시와 대치 Quill 편집
6. **강사소개** - CRUD (divisions 체크박스, 사진 업로드)
7. **명예의 전당** - 연도별 합격자 추가/삭제
8. **출제 경향** - `in_house_exam.astro` 관리
   - 페이지 안내 문구 편집 (`page_content.in_house_exam_notice`)
   - 학년×과목별 리포트 CRUD (`exam_reports`, sections는 JSON 텍스트로 직접 입력)
   - 서브탭 "기말고사 스케치" - 사진 업로드/삭제 (`exam-sketch` 버킷)

**신청 목록 다운받기** (헤더 버튼, 엑셀 .xlsx): `high3_consults`(고3 상담), `diagnosis_logs`(대입 전략 진단), `seminar_bookings`(설명회 신청, "초기화" 전체 삭제 버튼 있음)

---

## 과목 선택 자동 노출 로직 (in_house_exam.astro)

학년을 선택하면 `exam_reports`에 실제 데이터가 있는 과목 버튼만 표시됨 (없는 과목은 버튼 자체가 숨겨짐, "준비 중" placeholder 없음). 국어 포함 4과목(국어/영어/수학/과학) 모두 동일 로직 — 별도 수동 노출 설정 없음. 리포트를 추가하면 다음 로드부터 자동으로 버튼이 나타남.

---

## 강사소개 페이지

탭: 초등부 / 중등부 / 고등부 / 입시와대치

- **필터**: `divisions` 배열에 해당 학부 포함 여부
- **정렬**: 일반 탭은 ㄱㄴ순, 입시와대치는 원장>부원장>연구원 순
- **입시와대치 카드**: subject 대신 role 표시

---

## SEO 설정

- `sitemap-index.xml` 자동 생성 (`@astrojs/sitemap`)
- OG 태그, canonical URL, robots 설정 완료
- Google Search Console 등록 완료 (TXT 레코드 인증)

---

## 미완료 / 할 일

- [ ] 네이버 서치어드바이저 등록
- [ ] cronjob.org Supabase 활성화 유지 (7일 비활성 방지, 5일 간격 핑)
- [ ] 중등부/고등부 수학·영어 선생님 일부 사진 업로드
- [ ] SQL 마이그레이션 자동화 (현재 수동으로 Supabase SQL Editor 실행)
- [ ] exam_reports 관리 UI를 구조화 폼으로 개선 (현재는 JSON 텍스트 직접 입력이라 비개발자에게 어려움)

---

## SQL 파일 목록

| 파일 | 내용 |
|------|------|
| `supabase-setup.sql` | 초기 세팅 (notices, inquiries, admin, results) |
| `supabase-new-tables.sql` | page_content, faculty 테이블 생성 |
| `supabase-faculty-divisions.sql` | faculty divisions/role 설정 (완전 재설정 버전) |
| `supabase-results-2019-2023.sql` | 과거 연도 합격자 데이터 이관 |
| `supabase-exam-reports.sql` | exam_reports 테이블 생성 + 초기 데이터 (초5 영어, 초6 영어/수학, 중1 영어) |
| `supabase-exam-reports-batch2.sql` | exam_reports 추가분 (초5 수학, 중1 영어) |
| `supabase-exam-reports-batch3.sql` | exam_reports 추가분 (중1 과학) |
| `supabase-exam-reports-batch4.sql` | exam_reports 추가분 (중1 수학) |
| `supabase-exam-sketch-bucket.sql` | exam-sketch 스토리지 버킷 + anon 업로드/삭제 정책 |

> SQL 파일은 **Supabase SQL Editor에 붙여넣고 수동 실행** 필요

---

## 주요 명령어

```bash
npm run dev        # 개발 서버
npm run build      # 빌드
git push && git push suo1250 main  # 두 레포 동시 푸시
```
