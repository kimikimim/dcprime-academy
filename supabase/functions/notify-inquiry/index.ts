import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY') ?? '';
const TO_EMAIL = 'suo1250@gmail.com';
const FROM_EMAIL = 'onboarding@resend.dev'; // Resend 도메인 인증 전 기본값

serve(async (req) => {
  try {
    const payload = await req.json();

    // Supabase DB Webhook은 { type, table, record, old_record } 형태로 전달
    const record = payload.record;
    if (!record) {
      return new Response('no record', { status: 400 });
    }

    const {
      student_name,
      student_phone,
      parent_name,
      parent_phone,
      school_name,
      track,
      grade,
      branch,
      created_at,
    } = record;

    const branchLabel = branch === 'neunggok' ? '능곡관' : branch === 'jangkok' ? '장곡관' : branch ?? '-';
    const createdAt = created_at
      ? new Date(created_at).toLocaleString('ko-KR', { timeZone: 'Asia/Seoul' })
      : '-';

    const html = `
      <h2 style="color:#1a1a1a;">📋 새 상담 신청이 접수되었습니다</h2>
      <table style="border-collapse:collapse;width:100%;max-width:480px;font-size:14px;">
        <tr><td style="padding:8px 12px;background:#f5f5f5;font-weight:600;width:120px;">학생 이름</td><td style="padding:8px 12px;border-bottom:1px solid #eee;">${student_name ?? '-'}</td></tr>
        <tr><td style="padding:8px 12px;background:#f5f5f5;font-weight:600;">학생 연락처</td><td style="padding:8px 12px;border-bottom:1px solid #eee;">${student_phone ?? '-'}</td></tr>
        <tr><td style="padding:8px 12px;background:#f5f5f5;font-weight:600;">학부모 이름</td><td style="padding:8px 12px;border-bottom:1px solid #eee;">${parent_name ?? '-'}</td></tr>
        <tr><td style="padding:8px 12px;background:#f5f5f5;font-weight:600;">학부모 연락처</td><td style="padding:8px 12px;border-bottom:1px solid #eee;">${parent_phone ?? '-'}</td></tr>
        <tr><td style="padding:8px 12px;background:#f5f5f5;font-weight:600;">학교</td><td style="padding:8px 12px;border-bottom:1px solid #eee;">${school_name ?? '-'}</td></tr>
        <tr><td style="padding:8px 12px;background:#f5f5f5;font-weight:600;">학년</td><td style="padding:8px 12px;border-bottom:1px solid #eee;">${grade ?? '-'}</td></tr>
        <tr><td style="padding:8px 12px;background:#f5f5f5;font-weight:600;">트랙</td><td style="padding:8px 12px;border-bottom:1px solid #eee;">${track ?? '-'}</td></tr>
        <tr><td style="padding:8px 12px;background:#f5f5f5;font-weight:600;">희망 캠퍼스</td><td style="padding:8px 12px;border-bottom:1px solid #eee;">${branchLabel}</td></tr>
        <tr><td style="padding:8px 12px;background:#f5f5f5;font-weight:600;">신청 시각</td><td style="padding:8px 12px;">${createdAt}</td></tr>
      </table>
      <p style="margin-top:20px;font-size:13px;color:#888;">대치프라임 관리자 페이지에서 확인 후 연락 완료 처리해 주세요.</p>
    `;

    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: FROM_EMAIL,
        to: TO_EMAIL,
        subject: `[대치프라임] 상담 신청 - ${student_name ?? '이름없음'} (${branchLabel})`,
        html,
      }),
    });

    if (!res.ok) {
      const err = await res.text();
      console.error('Resend error:', err);
      return new Response(err, { status: 500 });
    }

    return new Response('ok', { status: 200 });
  } catch (e) {
    console.error(e);
    return new Response(String(e), { status: 500 });
  }
});
