# ETR 사이트 설정 가이드 (Supabase 연동)

이 사이트는 여전히 서버 없는 정적 HTML 사이트입니다. 신청 폼 저장, 갤러리/일정 관리자
기능은 [Supabase](https://supabase.com) (무료 플랜으로 충분) 를 백엔드로 사용합니다.
아래 순서대로 한 번만 설정하면 바로 사용할 수 있습니다.

## 0. 새로 생긴 파일들

| 파일 | 역할 |
|---|---|
| `apply.html` | 구글폼을 대체하는 자체 신청 폼 (신청 시 Supabase `applications` 테이블에 저장) |
| `admin.html` | 관리자 페이지 — 신청자 명단/통계, 갤러리 사진 추가·삭제, 일정 추가·삭제 |
| `gallery.html` | 이제 Supabase `gallery_photos`에 등록된 사진이 있으면 자동으로 그걸 보여주고, 없으면 기존 5장을 그대로 보여줍니다 |
| `etr-touch-rugby-blackorange.html` | 홈페이지 스코어보드가 Supabase `schedule`의 가장 가까운 일정을 자동으로 보여줍니다 (없으면 기존 값 유지) |
| `supabase/schema.sql` | 테이블 + 보안 정책(RLS) + 갤러리용 storage 버킷을 한 번에 만드는 SQL |
| `js/supabase-config.js` | Supabase 프로젝트 URL/API 키를 넣는 설정 파일 (딱 이 파일 하나만 수정하면 됩니다) |

## 1. Supabase 프로젝트 만들기

1. [supabase.com](https://supabase.com) 가입 후 **New Project** 클릭
2. 이름은 자유롭게 (예: `etr-touch-rugby`), 리전은 **Northeast Asia (Seoul)** 또는 가까운 지역 선택
3. DB 비밀번호는 아무거나 안전하게 설정하고 기록해두기 (직접 쓸 일은 거의 없습니다)
4. 프로젝트가 생성될 때까지 1~2분 대기

## 2. 테이블/정책/스토리지 한 번에 생성

1. Supabase 대시보드 왼쪽 메뉴에서 **SQL Editor** 클릭 → **New query**
2. 이 저장소의 `supabase/schema.sql` 파일 내용을 전체 복사해서 붙여넣기
3. **Run** 클릭

이 한 번의 실행으로 다음이 모두 만들어집니다.
- `applications` 테이블 (신청자, 누구나 제출 가능 / 조회·삭제는 로그인한 관리자만)
- `gallery_photos` 테이블 (갤러리 사진 메타데이터, 조회는 공개 / 추가·삭제는 관리자만)
- `schedule` 테이블 (훈련·웰컴데이 일정, 조회는 공개 / 추가·삭제는 관리자만)
- `gallery` storage 버킷 (사진 파일 저장용, 공개 읽기 / 업로드는 관리자만)
- 홈페이지 스코어보드용 기본 일정 1건 시드

## 3. 관리자 계정 만들기

1. 대시보드 왼쪽 메뉴 **Authentication** → **Users** → **Add user**
2. 관리자로 쓸 이메일/비밀번호 입력
3. **Auto Confirm User** 체크박스를 켜고 저장 (이메일 인증 없이 바로 로그인 가능해집니다)

이 계정이 `admin.html`에 로그인할 때 쓰는 유일한 계정입니다. 필요하면 나중에 여기서 추가로 만들 수 있습니다.

## 4. API 키를 사이트에 연결

1. 대시보드 좌측 메뉴 **Project Settings** → **API**
2. **Project URL**과 **anon public** 키를 복사
3. 이 저장소의 `js/supabase-config.js` 파일을 열어 두 값을 교체:

```js
const SUPABASE_URL = "https://xxxxxxxxxxxx.supabase.co";   // 여기에 Project URL
const SUPABASE_ANON_KEY = "eyJhbGciOi...";                    // 여기에 anon public 키
```

> `anon` 키는 브라우저에 노출되어도 안전하도록 설계된 공개 키입니다. 실제 접근 권한은
> `schema.sql`에서 설정한 RLS(Row Level Security) 정책이 지켜줍니다. **`service_role` 키는
> 절대 이 파일이나 어떤 프론트엔드 코드에도 넣지 마세요.**

이 파일 하나만 고치면 `apply.html`, `admin.html`, `gallery.html`, 홈페이지가 전부 같은
Supabase 프로젝트를 바라보게 됩니다.

## 5. 기존 갤러리 사진 5장 다시 올리기 (선택)

지난 작업에서 넣어둔 `images/gallery-01.jpg` ~ `gallery-05.jpg` 5장은 지금은 정적 fallback으로만
쓰입니다. Supabase로 옮기고 싶다면:

1. `admin.html`을 브라우저로 열고 3번에서 만든 계정으로 로그인
2. **갤러리 관리** 탭에서 사진 파일을 하나씩 선택 → 제목/영문 제목/메타 입력 → 업로드
   (업로드 시 자동으로 리사이즈·압축됩니다)

| 파일 | 제목 | 영문 제목 | 메타 |
|---|---|---|---|
| gallery-05.jpg | 정기 훈련 · 잠원한강공원 | Weekly Training · Jamwon Hangang Park | Training · 2026.06 |
| gallery-02.jpg | 서울 터치럭비 대회 · 단체사진 | Seoul Touch Tournament · All Teams | Tournament · 2026.05 |
| gallery-01.jpg | 대회 참가 · ETR 팀 기념사진 | Tournament Day · ETR Team Photo | Tournament · 2026.05 |
| gallery-04.jpg | 팀 허들 · 경기 전 작전 타임 | Team Huddle · Before Kickoff | Tournament · 2026.05 |
| gallery-03.jpg | 경기 대기 · 사이드라인에서 | On the Sideline · Waiting to Play | Tournament · 2026.05 |

한 장이라도 업로드하면 `gallery.html`은 자동으로 Supabase 쪽 사진을 우선 보여줍니다.

## 6. 배포

이 사이트는 여전히 순수 정적 HTML이라 GitHub Pages, Netlify, Vercel, Cloudflare Pages 등
아무 정적 호스팅에나 그대로 올리면 됩니다. 저장소 루트를 그대로 배포하세요 (별도 빌드 과정 없음).

## 7. 인스타그램 링크 미리보기(OG 태그) 마무리

배포 후 실제 도메인이 정해지면, 아래 3개 파일에서 `SITE_URL`이라고 써 있는 부분을
전부 실제 도메인으로 바꿔주세요 (끝에 슬래시 없이).

- `etr-touch-rugby-blackorange.html`
- `gallery.html`
- `apply.html`

터미널에서 한 번에 바꾸려면 (도메인이 `https://etr-touchrugby.com`인 경우 예시):

```bash
sed -i 's|SITE_URL|https://etr-touchrugby.com|g' etr-touch-rugby-blackorange.html gallery.html apply.html
```

바꾼 뒤에는 아래 도구로 실제로 어떻게 보이는지 확인할 수 있습니다.
- 카카오톡: [카카오 디버거](https://developers.kakao.com/tool/debugger/sharing)
- 페이스북/인스타그램 계열: [Facebook Sharing Debugger](https://developers.facebook.com/tools/debug/)
- 범용: [opengraph.xyz](https://www.opengraph.xyz/)

공유 플랫폼들은 미리보기를 캐싱하므로, 한 번 확인한 URL을 다시 확인하려면 위 디버거에서
"다시 스크래핑"을 눌러야 최신 이미지/문구가 반영됩니다.

## 8. 마케팅 데이터 확인하기

`admin.html` 로그인 후 **신청자** 탭에서 확인할 수 있는 것들:
- 총 신청자 수 / 오늘 신청 / 최근 7일 / 경험자 비율 (요약 카드)
- 유입 경로(utm_source)별 신청자 수 막대그래프
- 전체 신청자 목록 (엑셀에서 바로 열리는 CSV로 내보내기 가능)

유입 경로를 정확히 잡으려면 인스타그램 등에 올리는 링크에 UTM 파라미터를 붙이면 됩니다.

```
https://etr-touchrugby.com/apply.html?utm_source=instagram&utm_medium=bio_link&utm_campaign=2026_welcomeday
```

파라미터가 없어도 `document.referrer`(어디서 넘어왔는지)는 자동으로 함께 기록됩니다.

## 문제 해결

- **폼 제출이 안 돼요 / "제출 중 문제가 발생했습니다"**: `js/supabase-config.js`의 URL/키가
  올바른지, `schema.sql`을 정말 실행했는지 확인하세요. 브라우저 콘솔(F12)에 자세한 에러가 찍힙니다.
- **관리자 로그인이 안 돼요**: Authentication > Users에서 계정이 "Confirmed" 상태인지 확인하세요.
  Auto Confirm 없이 만들었다면 이메일 인증 메일을 확인해야 합니다.
- **갤러리 사진이 안 보여요**: Storage > gallery 버킷이 `public`으로 생성됐는지 확인하세요
  (`schema.sql`이 정상 실행됐다면 자동으로 public입니다).
- **CSV를 열었더니 한글이 깨져요**: 엑셀에서 "데이터 > 텍스트/CSV 가져오기"로 열면 인코딩을
  선택할 수 있습니다 (UTF-8). 대부분의 최신 엑셀은 자동으로 잘 열립니다.
