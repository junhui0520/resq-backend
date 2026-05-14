const pool = require('../db/db');
const crypto = require('crypto');

// POST /api/users/:userId/qr-profile - QR 프로필 등록/수정
const upsertQrProfile = async (req, res) => {
  try {
    const { userId } = req.params;
    const { name, gender, age, blood_type, nationality } = req.body;

    if (!name) {
      return res.status(400).json({ error: 'name은 필수입니다.' });
    }

    const [existing] = await pool.query(
      `SELECT id, qr_token FROM qr_profiles WHERE user_id = ?`,
      [userId]
    );

    let qr_token;

    if (existing.length > 0) {
      qr_token = existing[0].qr_token;
      await pool.query(
        `UPDATE qr_profiles 
         SET name = ?, gender = ?, age = ?, blood_type = ?, nationality = ?
         WHERE user_id = ?`,
        [name, gender, age, blood_type, nationality, userId]
      );
    } else {
      qr_token = crypto.randomUUID();
      await pool.query(
        `INSERT INTO qr_profiles (user_id, qr_token, name, gender, age, blood_type, nationality)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [userId, qr_token, name, gender, age, blood_type, nationality]
      );
    }

    const qr_url = `${process.env.BASE_URL || 'http://localhost:3000'}/api/qr/${qr_token}`;
    res.status(201).json({ qr_token, qr_url });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '서버 오류가 발생했습니다.' });
  }
};

// GET /api/users/:userId/qr-profile - 내 정보 조회
const getMyProfile = async (req, res) => {
  try {
    const { userId } = req.params;

    const [profiles] = await pool.query(
      `SELECT name, gender, age, blood_type, nationality
       FROM qr_profiles
       WHERE user_id = ? AND is_active = TRUE`,
      [userId]
    );

    if (profiles.length === 0) {
      return res.status(404).json({ error: '등록된 프로필이 없습니다.' });
    }

    const [contacts] = await pool.query(
      `SELECT id, name, relationship, phone, priority
       FROM emergency_contacts
       WHERE user_id = ?
       ORDER BY priority ASC`,
      [userId]
    );

    const [medicals] = await pool.query(
      `SELECT id, category, value
       FROM medical_infos
       WHERE user_id = ?`,
      [userId]
    );

    res.json({
      ...profiles[0],
      emergency_contacts: contacts,
      medical_infos: medicals
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '서버 오류가 발생했습니다.' });
  }
};

// GET /api/qr/:qrToken - QR 스캔 결과 조회
const getQrProfile = async (req, res) => {
  try {
    const { qrToken } = req.params;

    const [profiles] = await pool.query(
      `SELECT qp.user_id, qp.name, qp.gender, qp.age, qp.blood_type, qp.nationality
       FROM qr_profiles qp
       WHERE qp.qr_token = ? AND qp.is_active = TRUE`,
      [qrToken]
    );

    if (profiles.length === 0) {
      return res.status(404).json({ error: 'QR 정보를 찾을 수 없습니다.' });
    }

    const profile = profiles[0];

    const [contacts] = await pool.query(
      `SELECT name, relationship, phone
       FROM emergency_contacts
       WHERE user_id = ?
       ORDER BY priority ASC`,
      [profile.user_id]
    );

    const [medicals] = await pool.query(
      `SELECT category, value
       FROM medical_infos
       WHERE user_id = ?`,
      [profile.user_id]
    );

    res.json({
      name: profile.name,
      gender: profile.gender,
      age: profile.age,
      blood_type: profile.blood_type,
      nationality: profile.nationality,
      emergency_contacts: contacts,
      medical_infos: medicals
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '서버 오류가 발생했습니다.' });
  }
};

// POST /api/users/:userId/emergency-contacts - 긴급 연락처 추가
const addEmergencyContact = async (req, res) => {
  try {
    const { userId } = req.params;
    const { name, relationship, phone, priority } = req.body;

    if (!name || !phone) {
      return res.status(400).json({ error: 'name과 phone은 필수입니다.' });
    }

    const [result] = await pool.query(
      `INSERT INTO emergency_contacts (user_id, name, relationship, phone, priority)
       VALUES (?, ?, ?, ?, ?)`,
      [userId, name, relationship, phone, priority || 1]
    );

    res.status(201).json({ id: result.insertId, name, phone });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '서버 오류가 발생했습니다.' });
  }
};

// PUT /api/users/:userId/emergency-contacts/:id - 긴급 연락처 수정
const updateEmergencyContact = async (req, res) => {
  try {
    const { userId, id } = req.params;
    const { name, relationship, phone, priority } = req.body;

    const [result] = await pool.query(
      `UPDATE emergency_contacts
       SET name = COALESCE(?, name),
           relationship = COALESCE(?, relationship),
           phone = COALESCE(?, phone),
           priority = COALESCE(?, priority)
       WHERE id = ? AND user_id = ?`,
      [name, relationship, phone, priority, id, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: '연락처를 찾을 수 없습니다.' });
    }

    res.json({ updated: true });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '서버 오류가 발생했습니다.' });
  }
};

// DELETE /api/users/:userId/emergency-contacts/:id - 긴급 연락처 삭제
const deleteEmergencyContact = async (req, res) => {
  try {
    const { userId, id } = req.params;

    const [result] = await pool.query(
      `DELETE FROM emergency_contacts WHERE id = ? AND user_id = ?`,
      [id, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: '연락처를 찾을 수 없습니다.' });
    }

    res.json({ deleted: true });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '서버 오류가 발생했습니다.' });
  }
};

// POST /api/users/:userId/medical-infos - 의료 정보 추가
const addMedicalInfo = async (req, res) => {
  try {
    const { userId } = req.params;
    const { category, value } = req.body;

    if (!category || !value) {
      return res.status(400).json({ error: 'category와 value는 필수입니다.' });
    }

    const [result] = await pool.query(
      `INSERT INTO medical_infos (user_id, category, value) VALUES (?, ?, ?)`,
      [userId, category, value]
    );

    res.status(201).json({ id: result.insertId, category, value });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '서버 오류가 발생했습니다.' });
  }
};

// DELETE /api/users/:userId/medical-infos/:id - 의료 정보 삭제
const deleteMedicalInfo = async (req, res) => {
  try {
    const { userId, id } = req.params;

    const [result] = await pool.query(
      `DELETE FROM medical_infos WHERE id = ? AND user_id = ?`,
      [id, userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: '의료 정보를 찾을 수 없습니다.' });
    }

    res.json({ deleted: true });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: '서버 오류가 발생했습니다.' });
  }
};

module.exports = {
  upsertQrProfile,
  getMyProfile,
  getQrProfile,
  addEmergencyContact,
  updateEmergencyContact,
  deleteEmergencyContact,
  addMedicalInfo,
  deleteMedicalInfo
};