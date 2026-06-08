const pool = require('../db/db');

// GET /api/alerts
const getAlerts = async (req, res) => {
  try {
    const { region_code, category_code, status, lang = 'en' } = req.query;

    let query = `
      SELECT 
        a.id,
        a.region_code,
        r.name_en AS region_name,
        a.category_code,
        ac.label_en AS category_label,
        ac.color_hex,
        a.severity_code,
        sl.label_en AS severity_label,
        at.title,
        at.content,
        at.action_guide,
        a.status,
        a.issued_at,
        a.resolved_at
      FROM alerts a
      JOIN regions r ON a.region_code = r.code
      JOIN alert_categories ac ON a.category_code = ac.code
      JOIN severity_levels sl ON a.severity_code = sl.code
      LEFT JOIN alert_translations at ON a.id = at.alert_id AND at.language_code = ?
      WHERE 1=1
    `;

    const params = [lang];

    if (region_code) {
      query += ` AND a.region_code = ?`;
      params.push(region_code);
    }
    if (category_code) {
      query += ` AND a.category_code = ?`;
      params.push(category_code);
    }
    if (status) {
      query += ` AND a.status = ?`;
      params.push(status);
    }

    query += ` ORDER BY a.issued_at DESC`;

    const [rows] = await pool.query(query, params);
    res.json({ alerts: rows });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '서버 오류가 발생했습니다.' });
  }
};

// GET /api/alerts/categories
const getCategories = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT code, label_en, label_ko, color_hex FROM alert_categories`
    );
    res.json({ categories: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '서버 오류가 발생했습니다.' });
  }
};

// GET /api/alerts/:id
const getAlertById = async (req, res) => {
  try {
    const { id } = req.params;
    const { lang = 'en' } = req.query;

    const [rows] = await pool.query(
      `SELECT 
        a.id,
        a.region_code,
        r.name_en AS region_name,
        a.category_code,
        ac.label_en AS category_label,
        ac.color_hex,
        a.severity_code,
        sl.label_en AS severity_label,
        at.title,
        at.content,
        at.action_guide,
        a.status,
        a.issued_at,
        a.resolved_at
      FROM alerts a
      JOIN regions r ON a.region_code = r.code
      JOIN alert_categories ac ON a.category_code = ac.code
      JOIN severity_levels sl ON a.severity_code = sl.code
      LEFT JOIN alert_translations at ON a.id = at.alert_id AND at.language_code = ?
      WHERE a.id = ?`,
      [lang, id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: '알림을 찾을 수 없습니다.' });
    }

    res.json(rows[0]);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '서버 오류가 발생했습니다.' });
  }
};
// GET /api/alerts/recent
const getRecentAlerts = async (req, res) => {
  try {
    const { lang = 'en', limit = 5 } = req.query;

    const [rows] = await pool.query(
      `SELECT 
        a.id,
        a.region_code,
        r.name_en AS region_name,
        a.category_code,
        ac.label_en AS category_label,
        ac.color_hex,
        a.severity_code,
        sl.label_en AS severity_label,
        at.title,
        at.content,
        a.status,
        a.issued_at
      FROM alerts a
      JOIN regions r ON a.region_code = r.code
      JOIN alert_categories ac ON a.category_code = ac.code
      JOIN severity_levels sl ON a.severity_code = sl.code
      LEFT JOIN alert_translations at ON a.id = at.alert_id AND at.language_code = ?
      WHERE a.status = 'ACTIVE'
      ORDER BY a.issued_at DESC
      LIMIT ?`,
      [lang, parseInt(limit)]
    );

    res.json({ alerts: rows });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '서버 오류가 발생했습니다.' });
  }
};

module.exports = { getAlerts, getCategories, getAlertById, getRecentAlerts };