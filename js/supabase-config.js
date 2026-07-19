// ============================================================
// Supabase 프로젝트 연결 설정
// SETUP.md의 안내에 따라 아래 두 값을 본인의 Supabase 프로젝트 값으로 교체하세요.
// (Project Settings > API 에서 확인할 수 있는 "Project URL"과 "anon public" 키입니다.
//  anon 키는 공개 클라이언트에 노출되어도 되는 키이며, 실제 접근 권한은 schema.sql의
//  RLS 정책으로 제어됩니다.)
// ============================================================
const SUPABASE_URL = "https://YOUR-PROJECT-REF.supabase.co";
const SUPABASE_ANON_KEY = "YOUR-ANON-PUBLIC-KEY";

const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
