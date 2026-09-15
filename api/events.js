export default function handler(req, res) {
  if (req.method === 'GET') {
    return res.status(200).json({
      ok: true,
      source: 'simulation',
      events: [
        { payment_id: 'pay_demo_001', amount: 1250.5, payment_method: 'PIX', status: 'APPROVED', risk: 'LOW' },
        { payment_id: 'pay_demo_002', amount: 4850, payment_method: 'CREDIT_CARD', status: 'PENDING', risk: 'MEDIUM' }
      ]
    });
  }

  if (req.method === 'POST') {
    const event = req.body || {};
    return res.status(202).json({
      ok: true,
      accepted: true,
      event: {
        payment_id: event.payment_id || `pay_${Date.now()}`,
        amount: Number(event.amount || 0),
        payment_method: event.payment_method || 'UNKNOWN',
        status: event.status || 'APPROVED',
        risk: event.risk || 'LOW'
      }
    });
  }

  res.setHeader('Allow', ['GET', 'POST']);
  return res.status(405).json({ ok: false, error: 'Method not allowed' });
}
