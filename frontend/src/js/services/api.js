// ============================================
// api.js — Comunicación con la API
// Importar en todas las páginas que usen fetch
// ============================================
const API_URL = "http://localhost:8000";

/**
 * GET — Obtener datos del servidor
 * @param {string} endpoint - Ej: '/pacientes' o '/pacientes/5/historial'
 * @returns {Promise<any>}
 */
async function fetchData(endpoint) {
  const response = await fetch(`${API_URL}${endpoint}`);
  if (!response.ok) {
    throw new Error(`Error ${response.status} al obtener ${endpoint}`);
  }
  return await response.json();
}

/**
 * POST — Enviar datos al servidor
 * @param {string} endpoint - Ej: '/tratamientos'
 * @param {object} data - Objeto con los datos a enviar
 * @returns {Promise<any|null>} null si hubo alerta médica (400)
 */
async function postData(endpoint, data) {
  const response = await fetch(`${API_URL}${endpoint}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data),
  });
  const result = await response.json();
  if (response.status === 400) {
    mostrarAlertaMedica(result.detail);
    return null;
  }
  if (!response.ok) {
    throw new Error(`Error inesperado ${response.status}`);
  }
  return result;
}