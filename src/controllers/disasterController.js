const axios = require('axios');
const cron = require('node-cron');
const db = require('../db/db');

// 재난문자 내용 키워드 → category_code 매핑
const categoryMap = [
  { keywords: ['지진'], category: 'EARTHQUAKE' },
  { keywords: ['호우', '폭우', '강수', '태풍', '강풍', '바람'], category: 'RAIN/TYPHOON' },
  { keywords: ['홍수', '침수'], category: 'FLOOD' },
  { keywords: ['산사태', '토사'], category: 'LANDSLIDE' },
  { keywords: ['화재', '산불'], category: 'FIRE' },
  { keywords: ['대설', '눈'], category: 'SNOW' },
];

// 재난문자 내용 키워드 → severity_code 매핑
const severityMap = [
  { keywords: ['경보', '위기', '긴급'], severity: 'CRITICAL' },
  { keywords: ['주의보', '경계'], severity: 'HIGH' },
  { keywords: ['주의'], severity: 'MEDIUM' },
];

// 재난문자 발령 지역명 → region_code 매핑
const regionMap = [
  { keywords: ['천안'], region: 'CHEONAN' },
  { keywords: ['충남', '충청남도'], region: 'CHUNGNAM' },
  { keywords: ['충북', '충청북도'], region: 'CHUNGBUK' },
  { keywords: ['강원'], region: 'GANGWON' },
  { keywords: ['경북', '경상북도'], region: 'GYEONGBUK' },
  { keywords: ['경남', '경상남도'], region: 'GYEONGNAM' },
  { keywords: ['경기'], region: 'GYEONGGI' },
  { keywords: ['제주'], region: 'JEJU' },
  { keywords: ['서울'], region: 'SEOUL' },
  { keywords: ['부산'], region: 'BUSAN' },
  { keywords: ['대구'], region: 'DAEGU' },
  { keywords: ['인천'], region: 'INCHEON' },
  { keywords: ['광주'], region: 'GWANGJU' },
  { keywords: ['대전'], region: 'DAEJEON' },
  { keywords: ['울산'], region: 'ULSAN' },
  { keywords: ['세종'], region: 'SEJONG' },
  { keywords: ['전북', '전라북도'], region: 'JEONBUK' },
  { keywords: ['전남', '전라남도'], region: 'JEONNAM' },
];

// ✅ 추가: 재난 관련 키워드 목록 (이 키워드 없으면 저장 안 함)
const disasterKeywords = [
  '지진', '호우', '폭우', '강수', '태풍', '강풍', '바람',
  '홍수', '침수', '산사태', '토사', '화재', '산불', '대설', '눈',
  '재난', '경보', '주의보', '대피', '긴급재난'
];

// ✅ 추가: 재난 관련 키워드 포함 여부 체크
function isDisasterMessage(message) {
  return disasterKeywords.some(keyword => message.includes(keyword));
}

function classifyCategory(message) {
  for (const item of categoryMap) {
    for (const keyword of item.keywords) {
      if (message.includes(keyword)) return item.category;
    }
  }
  return 'OTHER';
}

function classifySeverity(message) {
  for (const item of severityMap) {
    for (const keyword of item.keywords) {
      if (message.includes(keyword)) return item.severity;
    }
  }
  return 'LOW';
}

function classifyRegion(regionName) {
  for (const item of regionMap) {
    for (const keyword of item.keywords) {
      if (regionName.includes(keyword)) return item.region;
    }
  }
  return 'KR';
}

async function fetchAndSaveDisasterAlerts() {
  try {
    const apiKey = process.env.DISASTER_API_KEY;
    const url = `https://www.safetydata.go.kr/V2/api/DSSP-IF-00247`;

    const response = await axios.get(url, {
      params: {
        serviceKey: apiKey,
        returnType: 'json',
        pageNo: 1,
        numOfRows: 20,
      },
    });

    const items = response.data?.body || [];

    if (!Array.isArray(items) || items.length === 0) {
      console.log('[재난문자] 새로운 데이터 없음');
      return;
    }

    let savedCount = 0;

    for (const item of items) {
      const msgContent = item.MSG_CN || '';
      const regionName = item.RCPTN_RGN_NM || '전국';
      const sentAt = item.CRT_DT || new Date();

      // ✅ 추가: 재난 관련 키워드 없으면 저장 스킵
      if (!isDisasterMessage(msgContent)) {
        continue;
      }

      const categoryCode = classifyCategory(msgContent);
      const severityCode = classifySeverity(msgContent);
      const regionCode = classifyRegion(regionName);

      // 중복 방지: 같은 내용 + 같은 시간이면 스킵
      const [existing] = await db.query(
        `SELECT id FROM alerts WHERE issued_at = ? AND region_code = ?`,
        [sentAt, regionCode]
      );
      if (existing.length > 0) continue;

      // alerts 테이블에 저장
      const [result] = await db.query(
        `INSERT INTO alerts (region_code, category_code, severity_code, status, issued_at)
         VALUES (?, ?, ?, 'ACTIVE', ?)`,
        [regionCode, categoryCode, severityCode, sentAt]
      );

      const alertId = result.insertId;

      // alert_translations 테이블에 영어로 저장
      await db.query(
        `INSERT INTO alert_translations (alert_id, language_code, title, content, action_guide)
         VALUES (?, 'en', ?, ?, '')`,
        [alertId, msgContent.substring(0, 100), msgContent]
      );

      savedCount++;
    }

    console.log(`[재난문자] ${savedCount}건 저장 완료`);
  } catch (error) {
    console.error('[재난문자] API 호출 실패:', error.message);
  }
}

function startDisasterScheduler() {
  console.log('[재난문자] 스케줄러 시작 - 5분마다 실행');
  cron.schedule('*/5 * * * *', () => {
    console.log('[재난문자] API 호출 중...');
    fetchAndSaveDisasterAlerts();
  });
}

module.exports = { fetchAndSaveDisasterAlerts, startDisasterScheduler };