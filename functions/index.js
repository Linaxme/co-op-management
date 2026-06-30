const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();
const MEMBER_DOMAIN = 'members.ssf.local';

function normalizePhone(phone) {
  if (!phone) return null;
  let digits = String(phone).replace(/\D/g, '');
  if (digits.startsWith('880')) digits = digits.substring(3);
  if (digits.length === 10 && digits.startsWith('1')) digits = '0' + digits;
  if (digits.length === 11 && digits.startsWith('01')) return digits;
  return null;
}

function memberEmail(phoneNormalized) {
  return `${phoneNormalized}@${MEMBER_DOMAIN}`;
}

async function getAdminCoopId(uid) {
  const doc = await db.collection('users').doc(uid).get();
  if (!doc.exists || doc.data().role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'Admin only');
  }
  const coopId = doc.data().coopId;
  if (!coopId) {
    throw new functions.https.HttpsError('failed-precondition', 'Cooperative not linked');
  }
  return coopId;
}

async function assertAdmin(context) {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Sign in required');
  }
  await getAdminCoopId(context.auth.uid);
}

async function sendFcm(token, title, body, data = {}) {
  const payload = {
    token,
    notification: { title, body },
    data: Object.fromEntries(
      Object.entries(data).map(([key, value]) => [key, String(value)]),
    ),
    android: { priority: 'high' },
  };
  await admin.messaging().send(payload);
}

async function findMemberUser(coopId, memberUuid) {
  const snap = await db
    .collection('users')
    .where('memberUuid', '==', memberUuid)
    .where('coopId', '==', coopId)
    .where('role', '==', 'member')
    .limit(1)
    .get();
  if (snap.empty) return null;
  return snap.docs[0];
}

exports.createMemberAuth = functions.https.onCall(async (data, context) => {
  await assertAdmin(context);

  const memberUuid = data.memberUuid;
  const phone = normalizePhone(data.phone);
  const password = data.password ? String(data.password) : '';

  if (!memberUuid || !phone || password.length < 6) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid input');
  }

  const email = memberEmail(phone);
  let uid;

  try {
    const existing = await admin.auth().getUserByEmail(email);
    uid = existing.uid;
    await admin.auth().updateUser(uid, { password, disabled: false });
  } catch (err) {
    if (err.code === 'auth/user-not-found') {
      const created = await admin.auth().createUser({
        email,
        password,
        emailVerified: true,
      });
      uid = created.uid;
    } else {
      throw err;
    }
  }

  const adminDoc = await db.collection('users').doc(context.auth.uid).get();
  const coopId = adminDoc.data()?.coopId;

  const userPayload = {
    role: 'member',
    memberUuid,
    phoneNormalized: phone,
    email,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  if (coopId) userPayload.coopId = coopId;

  await db.collection('users').doc(uid).set(userPayload, { merge: true });

  const memberSnap = await db
    .collection('members')
    .where('uuid', '==', memberUuid)
    .limit(1)
    .get();

  if (!memberSnap.empty) {
    await memberSnap.docs[0].ref.update({
      phoneNormalized: phone,
      phone: phone,
      updatedAt: new Date().toISOString(),
    });
  }

  return { uid };
});

exports.resetMemberPassword = functions.https.onCall(async (data, context) => {
  await assertAdmin(context);

  const memberUuid = data.memberUuid;
  const password = data.password ? String(data.password) : '';

  if (!memberUuid || password.length < 6) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid input');
  }

  const userSnap = await db
    .collection('users')
    .where('memberUuid', '==', memberUuid)
    .where('role', '==', 'member')
    .limit(1)
    .get();

  if (userSnap.empty) {
    throw new functions.https.HttpsError('not-found', 'Member login not found');
  }

  const uid = userSnap.docs[0].id;
  await admin.auth().updateUser(uid, { password });

  return { success: true };
});

/** Push to member when a deposit document is created in Firestore. */
exports.onCoopDepositCreated = functions.firestore
  .document('cooperatives/{coopId}/deposits/{depositId}')
  .onCreate(async (snap, context) => {
    const deposit = snap.data();
    const memberUuid = deposit.memberUuid;
    if (!memberUuid) return null;

    const userDoc = await findMemberUser(context.params.coopId, memberUuid);
    if (!userDoc) return null;

    const token = userDoc.data().fcmToken;
    if (!token) return null;

    const amount = deposit.amount ?? 0;
    const receipt = deposit.receiptSerial ?? '';
    const title = 'জমা রেকর্ড হয়েছে';
    const body = `পরিমাণ: ${amount} টাকা · রসিদ #${receipt}`;

    try {
      await sendFcm(token, title, body, {
        type: 'deposit',
        coopId: context.params.coopId,
        depositUuid: deposit.uuid || snap.id,
        memberUuid,
      });
    } catch (err) {
      functions.logger.warn('Deposit FCM failed', err);
    }
    return null;
  });

/** Admin broadcasts a message to all members in the cooperative. */
exports.sendCoopAnnouncement = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Sign in required');
  }

  const coopId = await getAdminCoopId(context.auth.uid);
  const title = String(data.title || '').trim();
  const body = String(data.body || '').trim();

  if (!title || !body) {
    throw new functions.https.HttpsError('invalid-argument', 'Title and body are required');
  }

  const membersSnap = await db
    .collection('users')
    .where('coopId', '==', coopId)
    .where('role', '==', 'member')
    .get();

  let sent = 0;
  let failed = 0;

  for (const doc of membersSnap.docs) {
    const token = doc.data().fcmToken;
    if (!token) continue;
    try {
      await sendFcm(token, title, body, {
        type: 'announcement',
        coopId,
      });
      sent += 1;
    } catch (err) {
      failed += 1;
      functions.logger.warn(`Announcement FCM failed for ${doc.id}`, err);
    }
  }

  await db.collection('cooperatives').doc(coopId).collection('announcements').add({
    title,
    body,
    sentBy: context.auth.uid,
    sent,
    failed,
    memberCount: membersSnap.size,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { sent, failed, total: membersSnap.size };
});
