const state = { running: true, burst: 1, total: 128430, suspicious: 37, events: [] };
const methods = ['PIX', 'CREDIT_CARD', 'DEBIT_CARD', 'BANK_TRANSFER'];
const statuses = ['APPROVED', 'APPROVED', 'APPROVED', 'PENDING'];

const $ = (selector) => document.querySelector(selector);
const money = () => (Math.random() * 4800 + 35).toFixed(2);

function createEvent() {
  const riskRoll = Math.random();
  const risk = riskRoll < 0.10 ? 'HIGH' : riskRoll < 0.32 ? 'MEDIUM' : 'LOW';
  return {
    id: `pay_${Math.floor(100000 + Math.random() * 899999)}`,
    amount: money(),
    method: methods[Math.floor(Math.random() * methods.length)],
    status: statuses[Math.floor(Math.random() * statuses.length)],
    risk,
    latency: Math.round(20 + Math.random() * 180)
  };
}

function renderEvents() {
  $('#rows').innerHTML = state.events.slice(0, 8).map((event) => `
    <tr>
      <td>${event.id}</td>
      <td class="amount">R$ ${event.amount}</td>
      <td>${event.method}</td>
      <td>${event.status}</td>
      <td class="risk-${event.risk.toLowerCase()}">${event.risk}</td>
      <td>${event.latency} ms</td>
    </tr>`).join('');
}

function pushEvent() {
  const event = createEvent();
  state.events.unshift(event);
  state.events = state.events.slice(0, 30);
  state.total += state.burst;
  if (event.risk === 'HIGH') state.suspicious++;

  $('#events').textContent = state.total.toLocaleString('pt-BR');
  $('#suspicious').textContent = state.suspicious.toLocaleString('pt-BR');
  $('#throughput').textContent = Math.round((380 + Math.random() * 110) * state.burst).toLocaleString('pt-BR');
  $('#latency').textContent = Math.round(62 + Math.random() * 50);
  renderEvents();
  renderChart();
}

function renderChart() {
  const chart = $('#chart');
  chart.innerHTML = '';
  for (let i = 0; i < 60; i++) {
    const bar = document.createElement('div');
    bar.className = 'bar';
    bar.style.height = `${22 + Math.random() * 75}%`;
    chart.appendChild(bar);
  }
}

function renderAlerts() {
  const alerts = [
    ['HIGH', 'Valor acima do limite', 'pay_098421'],
    ['MEDIUM', 'Repetição em janela curta', 'pay_098417'],
    ['HIGH', 'Frequência incompatível', 'pay_098409']
  ];
  $('#alerts').innerHTML = alerts.map(([level, title, id]) => `
    <div class="alert">
      <div class="alert-row"><strong>${title}</strong><span class="pill ${level === 'HIGH' ? 'danger' : 'warn'}">${level}</span></div>
      <div class="muted" style="margin-top:4px">${id} · regra de suspeita</div>
    </div>`).join('');
}

function openPayloadEditor() {
  $('#payloadModal').classList.add('open');
}

function closePayloadEditor() {
  $('#payloadModal').classList.remove('open');
}

function sendPayload() {
  try {
    const payload = JSON.parse($('#payload').value);
    state.events.unshift({
      id: payload.payment_id || `pay_${Date.now()}`,
      amount: Number(payload.amount || 0).toFixed(2),
      method: payload.payment_method || 'CUSTOM',
      status: payload.status || 'APPROVED',
      risk: payload.risk || 'LOW',
      latency: Math.round(20 + Math.random() * 180)
    });
    state.events = state.events.slice(0, 30);
    state.total++;
    $('#events').textContent = state.total.toLocaleString('pt-BR');
    renderEvents();
    closePayloadEditor();
  } catch {
    $('#payloadError').textContent = 'JSON inválido. Corrija o payload antes de enviar.';
  }
}

$('#pause').onclick = () => {
  state.running = !state.running;
  $('#pause').textContent = state.running ? 'Pausar simulação' : 'Retomar simulação';
};

$('#burst').onclick = () => {
  state.burst = state.burst === 1 ? 4 : 1;
  $('#burst').textContent = state.burst === 1 ? 'Gerar carga' : 'Carga alta ativa';
};

$('#openPayload').onclick = openPayloadEditor;
$('#closePayload').onclick = closePayloadEditor;
$('#sendPayload').onclick = sendPayload;
$('#payloadModal').addEventListener('click', (event) => {
  if (event.target.id === 'payloadModal') closePayloadEditor();
});

for (let i = 0; i < 8; i++) state.events.push(createEvent());
renderEvents();
renderAlerts();
renderChart();

setInterval(() => {
  if (state.running) pushEvent();
}, 1800);
