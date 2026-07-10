# 대치프라임 아카데미 사이트 - 프로젝트 문서

## 기술 스택
- **프레임워크**: Astro (SSG, ClientRouter로 SPA 전환 효과)
- **스타일**: Tailwind CSS v4 (`@tailwindcss/vite`)
- **DB/백엔드**: Supabase (PostgreSQL + Storage)
- **배포**: Cloudflare Pages (`dcprime.co.kr` 도메인 연결)
- **코드 저장소**: 
  - `origin` → `kimikimim/dcprime-academy`
  - `suo1250` → `suo1250-lab/dcprime-academy`
  - 푸시 시 항상 둘 다: `git push && git push suo1250 main`

---

## 프로젝트 구조

```
src/
├── pages/
│   ├── index.astro          # 메인 홈페이지
│   ├── about.astro          # 학원소개 (DB: page_content)
│   ├── curriculum.astro     # 커리큘럼 (DB: page_content)
│   ├── faculty.astro        # 강사소개 (DB: faculty)
│   ├── results.astro        # 명예의 전당 (DB: results)
│   ├── notice.astro         # 공지사항 목록 (DB: notices)
│   ├── notice/[id].astro    # 공지 상세
│   ├── inquiry.astro        # 상담 신청 (DB: inquiries)
│   ├── branches.astro       # 오시는 길
│   ├── directions.astro     # 지도
│   ├── privacy-policy.astro
│   ├── terms-of-service.astro
│   └── adminssh.astro       # 관리자 페이지 (비번: Prime0979!)
│
├── components/
│   ├── layout/
│   │   ├── Layout.astro     # 공통 레이아웃 (OG태그, sitemap, canonical 포함)
│   │   ├── Header.astro     # 헤더/네비게이션
│   │   └── Footer.astro     # 푸터 (개인정보처리방침, 이용약관 링크)
│   ├── sections/            # 메인페이지 섹션들
│   │   ├── HeroSection.astro
│   │   ├── ResultsSection.astro   # DB에서 최신 연도 합격자 수 자동 집계
│   │   ├── DifferentiationsSection.astro
│   │   └── ...
│   └── ui/
│       ├── SectionTitle.astro
│       └── Button.astro
│
└── lib/
    └── supabase.ts          # Supabase 클라이언트
```

---

## Supabase 설정

- **프로젝트 ID**: `smnakhjdtbqgwocwlluz`
- **URL**: `https://smnakhjdtbqgwocwlluz.supabase.co`
- **환경변수** (`.env`):
  - `PUBLIC_SUPABASE_URL`
  - `PUBLIC_SUPABASE_ANON_KEY`

### 테이블 목록

| 테이블 | 용도 |
|--------|------|
| `notices` | 공지사항 (id, title, content, views, created_at) |
| `inquiries` | 상담 신청 (student_name, student_phone, parent_name, parent_phone, school_name, track, grade, branch, agree_privacy, contacted) |
| `results` | 명예의 전당 (year, category, school, name, university, dept) |
| `admin_config` | 관리자 비밀번호 (`key='admin_password'`, `value='Prime0979!'`) |
| `page_content` | 학원소개/커리큘럼 편집 내용 (key, value) |
| `faculty` | 강사 정보 (name, subject, motto, image_url, sort_order, divisions[], role) |

### page_content 키 목록
- `about_greeting`, `about_history`, `about_features`
- `curriculum_elementary`, `curriculum_middle`, `curriculum_high`

### faculty 테이블 divisions 구조
- `divisions`: text[] 배열 (`초등부`, `중등부`, `고등부`, `입시와대치` 중복 가능)
- `role`: 입시와대치 직책 (원장/부원장/연구원)

### Storage 버킷
- `notice-images`: 공지사항 이미지
- `faculty-images`: 강사 프로필 사진

### RPC 함수
- `verify_admin_password(pw text)`: 관리자 로그인 검증

---

## 관리자 페이지 (`/adminssh`)

비밀번호: `Prime0979!`

탭 구성:
1. **공지사항 관리** - Quill 에디터로 작성/수정/삭제
2. **상담 신청 목록** - 연락완료 체크
3. **학원소개** - 인사말/학원연혁/학원특징 Quill 편집
4. **커리큘럼** - 초등/중등/고등 Quill 편집
5. **강사소개** - CRUD (divisions 체크박스, 사진 업로드)
6. **명예의 전당** - 연도별 합격자 추가/삭제

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
- 네이버 서치어드바이저 등록 예정

---

## 미완료 / 할 일

- [ ] 네이버 서치어드바이저 등록
- [ ] cronjob.org Supabase 활성화 유지 (7일 비활성 방지)
- [ ] 중등부/고등부 수학·영어 선생님 일부 사진 업로드
- [ ] SQL 마이그레이션 자동화 (현재 수동으로 Supabase SQL Editor 실행)

---

## SQL 파일 목록

| 파일 | 내용 |
|------|------|
| `supabase-setup.sql` | 초기 세팅 (notices, inquiries, admin, results) |
| `supabase-new-tables.sql` | page_content, faculty 테이블 생성 |
| `supabase-faculty-divisions.sql` | faculty divisions/role 설정 (완전 재설정 버전) |

> SQL 파일은 **Supabase SQL Editor에 붙여넣고 수동 실행** 필요

---

## 주요 명령어

```bash
npm run dev        # 개발 서버
npm run build      # 빌드
git push && git push suo1250 main  # 두 레포 동시 푸시
```
