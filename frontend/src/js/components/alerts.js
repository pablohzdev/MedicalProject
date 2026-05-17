// ============================================
// alerts.js — Modal de alertas médicas
// Importar en todas las páginas que usen POST
// Requiere el HTML del modal en la página
// ============================================

/**
 * Muestra el modal de alerta médica con el mensaje del Trigger
 * @param {string} mensaje - Texto que viene en result.detail del servidor
 */
function mostrarAlertaMedica(mensaje) {
  const modal = document.getElementById('modal-alerta');
  const texto = document.getElementById('modal-alerta-texto');

  if (!modal || !texto) {
    console.error('Modal de alerta no encontrado en el DOM');
    return;
  }

  texto.textContent = mensaje;
  modal.classList.remove('hidden');
}

/**
 * Cierra el modal de alerta médica
 */
function cerrarAlerta() {
  const modal = document.getElementById('modal-alerta');
  if (modal) modal.classList.add('hidden');
}

// Cerrar modal al hacer clic fuera de él
document.addEventListener('click', (e) => {
  const modal = document.getElementById('modal-alerta');
  if (modal && e.target === modal) {
    cerrarAlerta();
  }
});

// Cerrar modal con tecla Escape
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') cerrarAlerta();
});