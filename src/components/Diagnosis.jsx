import { useState } from 'react';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  import.meta.env.PUBLIC_SUPABASE_URL,
  import.meta.env.PUBLIC_SUPABASE_ANON_KEY
);

const qDict = {
  gpa: {
    id: 'gpa',
    title: "현재 학교 내신 성적은 어느 구간에 속합니까?",
    subtitle: "수시 지원의 기준점이 되는 가장 중요한 1차 지표입니다.",
    options: [
      { label: "1.0 ~ 2.5 (인서울 및 수도권 상위 교과 사정권)", value: 'high' },
      { label: "2.6 ~ 4.5 (수도권 교과 및 지거국, 약술논술 주력 구간)", value: 'mid' },
      { label: "4.6 이상 (내신 실질 반영률이 낮은 특화 전형 타겟)", value: 'low' },
    ],
  },
  mock: {
    id: 'mock',
    title: "현재 모의고사 성적을 객관적으로 판단한다면?",
    subtitle: "수능은 수시를 뚫어내는 무기이거나, 극상위권의 정시 카드입니다.",
    options: [
      { label: "내신보다 모의고사가 압도적으로 높다 (전과목 평균 1~2등급대)", value: 'unicorn' },
      { label: "특정 1~2과목에 집중하면 수능 최저(2합 6 또는 1개 3)는 맞출 수 있다", value: 'choijeo' },
      { label: "현재 수능/모의고사는 전과목 4등급 이하로 최저 달성이 벅차다", value: 'none' },
    ],
  },
  record: {
    id: 'record',
    title: "학교생활기록부(세특, 진로활동 등)의 완성도는 어떠합니까?",
    subtitle: "단순 활동 나열이 아닌, 전공에 대한 깊이 있는 탐구 여부를 묻습니다.",
    options: [
      { label: "희망 전공이 뚜렷하고, 교과와 연계된 깊이 있는 탐구 기록이 있다", value: 'strong' },
      { label: "진로가 불명확하거나, 학교 기본 프로그램 위주의 평이한 기록이다", value: 'weak' },
    ],
  },
  interview: {
    id: 'interview',
    title: "[학종 세부 진단] 본인의 생각을 표현하는 방식 중 어느 쪽이 편합니까?",
    subtitle: "우수한 생기부를 면접형으로 풀 것인지, 서류형으로 굳힐 것인지 결정합니다.",
    options: [
      { label: "구두로 논리정연하게 설명하고 압박 질문을 방어하는 데 자신 있다", value: 'yes' },
      { label: "말하기보다는 글이나 서류 자체의 완성도로 증명하는 것이 좋다", value: 'no' },
    ],
  },
  yaksul_subject: {
    id: 'yaksul_subject',
    title: "[약술 세부 진단] 국어와 수학 중, 학습 거부감이 덜한 과목은 무엇입니까?",
    subtitle: "약술논술 지원 시 대학별 문항 수 비율과 유불리를 결정하는 기준입니다.",
    options: [
      { label: "수학 (수식 전개와 단답/서술형 논리 풀이에 강점)", value: 'math' },
      { label: "국어 (EBS 연계 문학/독서 지문 분석 및 암기에 강점)", value: 'korean' },
    ],
  },
};

const results = {
  susi_top: {
    tag: "수시 최상위 포트폴리오",
    title: "교과 안정 + 학종/최저 상향의 정공법",
    desc: "우수한 내신을 바탕으로 학생부 교과 전형을 안정 카드로 깔고, 수능 최저학력기준을 무기로 인서울 상위권 대학에 상향 지원하는 가장 정석적인 전략입니다. 어설픈 논술 준비보다는 내신 마무리와 1~2과목 수능 최저 확보에 사활을 걸어야 합니다.",
    action1: "수시지원전략컨설팅", action1_desc: "내신 산출식 기반 교과 안정 대학 선별 및 학종 상향 라인 구축",
    action2: "수능최저준비반(국/영/수)", action2_desc: "탐독 시스템을 통한 2합 5~6 목표 달성 훈련",
  },
  hakjong_interview: {
    tag: "학종 면접 특화",
    title: "탄탄한 생기부와 표현력을 무기로 한 학종 면접형",
    desc: "내신의 불리함을 뚜렷한 진로 탐구(생기부)와 면접으로 뒤집을 수 있는 조건입니다. 1단계 서류 통과 후, 교수진 앞에서도 본인의 학업적 자생력을 논리적으로 증명하는 훈련이 당락을 좌우합니다.",
    action1: "수시지원전략컨설팅", action1_desc: "생기부 정밀 진단 및 3학년 1학기 세특 마감 디자인",
    action2: "학종 면접대비반", action2_desc: "제시문/서류 기반 모의면접 및 답변 구조화 집중 훈련",
  },
  hakjong_doc: {
    tag: "학종 서류 특화",
    title: "서류의 밀도로 승부하는 학종 서류형",
    desc: "면접의 변수를 없애고 오직 3년간 누적된 생기부의 기록으로 승부합니다. 내신 등급을 상쇄할 만한 세특의 깊이가 요구되므로, 마지막 학기 수행평가와 보고서에 모든 학업 역량을 쏟아부어야 합니다.",
    action1: "수시지원전략컨설팅", action1_desc: "서류형 평가 기준에 맞춘 전공적합성 포트폴리오 완성",
    action2: "수능최저준비반", action2_desc: "학종 서류형 중 최저를 요구하는 상위 대학 병행 준비",
  },
  yaksul_choijeo: {
    tag: "약술논술 최상위 타겟",
    title: "수능 최저 탑재, 가천대·국민대 약술 정조준",
    desc: "수시 교과나 학종으로 돌파하기 어려운 내신/생기부를 가졌지만, 특정 과목의 수능 최저(1개 3 또는 2합 6)를 맞출 수 있다면 실질 경쟁률을 절반으로 떨어뜨릴 수 있습니다. 내신 0% 반영 대학인 가천대와 국민대에 약술논술로 승부를 거십시오.",
    action1: "약술논술대비반", action1_desc: "EBS 연계 지문 해체 및 단답/서술형 감점 방어 훈련",
    action2: "수능최저준비반", action2_desc: "약술논술 대학의 수능 최저 달성을 위한 핀셋 학습",
  },
  yaksul_nochoijeo: {
    tag: "무최저 약술논술 올인",
    title: "한국공학대·서경대 등 무최저 약술 핀셋 공략",
    desc: "현재 수능 최저 달성이 어렵고 내신도 불리한 상황입니다. 수능에 대한 미련을 버리고, 수능 최저가 없고 내신 실질 감점이 적은 서경대, 한국공학대, 수원대 약술논술에 100% 집중해야 합니다. 학생의 강점 과목(국/수)에 맞춰 지원 대학의 가중치를 분석합니다.",
    action1: "약술논술대비반", action1_desc: "수능형 문풀을 배제한 약술논술 전용 커리큘럼",
    action2: "수시지원전략컨설팅", action2_desc: "지역적 이점(시흥권 등) 및 내신 무력화 대학 조합 설계",
  },
  jeongsi_fighter: {
    tag: "정시 특화 (예외적)",
    title: "압도적 모의고사를 바탕으로 한 정시 정면돌파",
    desc: "지역 내에서 매우 드문 케이스입니다. 내신의 한계를 넘어설 만큼 수능 모의고사 지표가 탁월합니다. 어설픈 수시 하향 지원(수시 납치)을 극도로 경계하고, 학업적 자생력을 바탕으로 인서울 상위권 정시에 올인하십시오.",
    action1: "정시대비반", action1_desc: "타협 없는 고밀도 수능 훈련 (탐독 시스템)",
    action2: "수시지원전략컨설팅", action2_desc: "정시 성적을 기준으로 한 수시 납치 방지 상향 원서 설계",
  },
};

async function saveDiagnosisLog(answers, history, resultTag) {
  await supabase.from('diagnosis_logs').insert({
    path: { answers, history },
    result_tag: resultTag,
  });
}

function getNextStep(qId, value, answers) {
  if (qId === 'gpa') return 'mock';

  if (qId === 'mock') {
    if (value === 'unicorn') return 'result';
    return 'record';
  }

  if (qId === 'record') {
    if (value === 'strong') return 'interview';
    if (answers.gpa === 'high') return 'result';
    return 'yaksul_subject';
  }

  if (qId === 'interview') return 'result';
  if (qId === 'yaksul_subject') return 'result';

  return 'result';
}

function computeResult(finalAnswers) {
  const { gpa, mock, record, interview } = finalAnswers;

  if (mock === 'unicorn') return results.jeongsi_fighter;

  if (gpa === 'high') {
    if (record === 'strong') return interview === 'yes' ? results.hakjong_interview : results.susi_top;
    return results.susi_top;
  }

  if (gpa === 'mid' || gpa === 'low') {
    if (record === 'strong') return interview === 'yes' ? results.hakjong_interview : results.hakjong_doc;
    if (mock === 'choijeo') return results.yaksul_choijeo;
    if (mock === 'none') return results.yaksul_nochoijeo;
  }

  return results.yaksul_nochoijeo;
}

export default function Diagnosis() {
  const [answers, setAnswers] = useState({});
  const [history, setHistory] = useState(['gpa']);
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [finalResult, setFinalResult] = useState(null);

  const currentQId = history[history.length - 1];
  const currentQ = qDict[currentQId];

  const handleAnswer = (value) => {
    const newAnswers = { ...answers, [currentQId]: value };
    const nextStep = getNextStep(currentQId, value, newAnswers);
    setAnswers(newAnswers);

    if (nextStep === 'result') {
      setIsAnalyzing(true);
      setTimeout(() => {
        const result = computeResult(newAnswers);
        setIsAnalyzing(false);
        setFinalResult(result);
        saveDiagnosisLog(newAnswers, [...history, currentQId], result.tag);
      }, 1500);
    } else {
      setHistory([...history, nextStep]);
    }
  };

  const goBack = () => {
    const newHistory = history.slice(0, -1);
    const prevQId = newHistory[newHistory.length - 1];
    const newAnswers = { ...answers };
    delete newAnswers[prevQId];
    setHistory(newHistory);
    setAnswers(newAnswers);
  };

  const restart = () => {
    setAnswers({});
    setHistory(['gpa']);
    setFinalResult(null);
  };

  if (finalResult) {
    return (
      <div className="fade-in bg-white rounded-2xl shadow-xl overflow-hidden border border-slate-200 w-full">
        <div className="bg-slate-900 px-6 py-10 text-center">
          <span className="inline-block py-1 px-4 rounded-full bg-slate-800 border border-slate-700 text-blue-400 text-xs font-bold mb-4">
            {finalResult.tag}
          </span>
          <h2 className="text-2xl font-extrabold text-white leading-tight break-keep">{finalResult.title}</h2>
        </div>

        <div className="p-8">
          <p className="text-slate-600 leading-relaxed mb-8 text-[15px] text-justify break-keep">
            {finalResult.desc}
          </p>

          <div className="border-t border-slate-100 pt-6">
            <h4 className="text-sm font-bold text-slate-800 mb-4">대치프라임 제안 솔루션</h4>
            <div className="space-y-3">
              <div className="bg-blue-50 border border-blue-100 rounded-xl p-4">
                <div className="font-bold text-blue-800 text-base">{finalResult.action1}</div>
                <div className="text-blue-600 text-xs mt-1">{finalResult.action1_desc}</div>
              </div>
              <div className="bg-slate-50 border border-slate-200 rounded-xl p-4">
                <div className="font-bold text-slate-800 text-base">{finalResult.action2}</div>
                <div className="text-slate-600 text-xs mt-1">{finalResult.action2_desc}</div>
              </div>
            </div>
          </div>

          <button
            onClick={restart}
            className="mt-8 w-full py-3 rounded-xl bg-slate-100 text-slate-600 text-sm font-bold hover:bg-slate-200 transition-colors"
          >
            초기화 후 다시 진단하기
          </button>
        </div>
      </div>
    );
  }

  if (isAnalyzing) {
    return (
      <div className="fade-in bg-white rounded-2xl shadow-xl p-12 text-center border border-slate-200 w-full min-h-[400px] flex flex-col justify-center items-center">
        <div className="w-12 h-12 border-4 border-slate-100 border-t-slate-800 rounded-full animate-spin mb-6"></div>
        <h3 className="text-lg font-bold text-slate-800 mb-2">입시 아키텍처 설계 중...</h3>
        <p className="text-slate-500 text-sm">입력된 조건에 맞춰 최적의 솔루션을 계산하고 있습니다.</p>
      </div>
    );
  }

  return (
    <div className="fade-in bg-white rounded-2xl shadow-xl overflow-hidden border border-slate-200 w-full">
      <div className="bg-slate-900 px-6 py-5">
        <span className="text-blue-400 font-bold text-xs tracking-widest">STEP {history.length}</span>
      </div>

      <div className="p-6 sm:p-8">
        <h2 className="text-xl font-bold text-slate-800 mb-2 leading-snug break-keep">
          {currentQ.title}
        </h2>
        <p className="text-slate-500 text-sm mb-6 break-keep">
          {currentQ.subtitle}
        </p>

        <div className="space-y-3">
          {currentQ.options.map((opt, idx) => (
            <button
              key={idx}
              onClick={() => handleAnswer(opt.value)}
              className="w-full text-left px-5 py-4 rounded-xl border border-slate-200 hover:border-slate-800 hover:bg-slate-50 transition-all duration-200 group flex items-center justify-between"
            >
              <span className="font-semibold text-slate-700 group-hover:text-slate-900 text-[15px]">{opt.label}</span>
              <svg className="w-4 h-4 text-slate-300 group-hover:text-slate-800 transform group-hover:translate-x-1 transition-all" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 5l7 7-7 7" />
              </svg>
            </button>
          ))}
        </div>

        {history.length > 1 && (
          <button onClick={goBack} className="mt-6 text-sm text-slate-400 hover:text-slate-600 underline underline-offset-2">
            이전 단계로
          </button>
        )}
      </div>
    </div>
  );
}
