// ============================================
// websocket.js — Sincronización en tiempo real
// Importar en todas las páginas que muestren datos
// ============================================

let socket;

/**
 * Iniciar conexión WebSocket con reconexión automática
 * @param {Function} onRefresh - Función a ejecutar cuando llegue "refresh_data"
 */
function iniciarWebSocket(onRefresh) {
  socket = new WebSocket('ws://localhost:8000/ws');

  socket.onopen = () => {
    console.log('WebSocket conectado ✅');
    actualizarEstadoWS(true);
  };

  socket.onmessage = (event) => {
    if (event.data === 'refresh_data') {
      console.log('Cambio en la DB detectado — actualizando vista...');
      onRefresh();
    }
  };

  socket.onclose = () => {
    console.warn('WebSocket cerrado. Reintentando en 5s...');
    actualizarEstadoWS(false);
    setTimeout(() => iniciarWebSocket(onRefresh), 5000);
  };

  socket.onerror = (error) => {
    console.error('Error en WebSocket:', error);
    actualizarEstadoWS(false);
  };
}

/**
 * Actualiza el indicador visual de conexión en el header
 * Solo aplica si el elemento existe en la página
 */
function actualizarEstadoWS(conectado) {
  const dot   = document.getElementById('ws-dot');
  const label = document.getElementById('ws-label');
  const badge = document.getElementById('ws-status');

  if (!dot || !label || !badge) return;

  if (conectado) {
    dot.className   = 'w-2 h-2 bg-green-500 rounded-full animate-pulse';
    label.textContent = 'En línea';
    badge.className = 'flex items-center space-x-2 bg-green-50 text-green-600 px-3 py-1.5 rounded-full text-xs font-semibold';
  } else {
    dot.className   = 'w-2 h-2 bg-red-400 rounded-full';
    label.textContent = 'Reconectando...';
    badge.className = 'flex items-center space-x-2 bg-red-50 text-red-500 px-3 py-1.5 rounded-full text-xs font-semibold';
  }
}