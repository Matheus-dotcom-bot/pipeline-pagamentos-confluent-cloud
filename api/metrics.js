export default function handler(req, res) {
  if (req.method !== 'GET') {
    res.setHeader('Allow', 'GET');
    return res.status(405).json({ ok: false, error: 'Method not allowed' });
  }

  const now = Date.now();
  return res.status(200).json({
    ok: true,
    source: 'simulation',
    timestamp: new Date(now).toISOString(),
    metrics: {
      events_processed: 128430 + Math.floor(Math.random() * 500),
      throughput_msg_s: 380 + Math.floor(Math.random() * 110),
      latency_p95_ms: 62 + Math.floor(Math.random() * 50),
      suspicious_transactions: 37 + Math.floor(Math.random() * 4)
    },
    pipeline: {
      postgres: 'online',
      debezium: 'online',
      kafka: 'online',
      flink: 'online',
      consumer: 'online'
    }
  });
}
