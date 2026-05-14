-- 1. Médicos (Identificación para el sistema)
CREATE TABLE medicos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    especialidad VARCHAR(100) DEFAULT 'General'
);

-- 2. Pacientes
CREATE TABLE pacientes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    genero VARCHAR(20),
    fecha_nacimiento DATE NOT NULL,
    grupo_sanguineo VARCHAR(3),
    antecedentes TEXT, -- Antes historial_clinico_global (Opcional)
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Consultas (El evento clínico)
CREATE TABLE consultas (
    id SERIAL PRIMARY KEY,
    paciente_id INT NOT NULL REFERENCES pacientes(id) ON DELETE CASCADE,
    medico_id INT REFERENCES medicos(id) ON DELETE SET NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    motivo_consulta TEXT NOT NULL,
    diagnostico TEXT NOT NULL
);

-- 4. Tratamientos (Aquí se unifica la información para evitar circularidad)
-- Se eliminó la tabla 'medicamento' separada porque causaba redundancia y errores de FK.
CREATE TABLE tratamientos (
    id SERIAL PRIMARY KEY,
    consulta_id INT NOT NULL REFERENCES consultas(id) ON DELETE CASCADE,
    medicamento VARCHAR(150) NOT NULL, -- Nombre del fármaco (clave para el Trigger)
    dosis VARCHAR(100) NOT NULL,
    duracion_dias INT NOT NULL,
    motivo_tratamiento TEXT, -- Por qué se receta este medicamento específico
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Registro de Alertas (Historial de avisos del sistema)
CREATE TABLE alertas_log (
    id SERIAL PRIMARY KEY,
    paciente_id INT NOT NULL REFERENCES pacientes(id) ON DELETE CASCADE,
    consulta_id INT NOT NULL REFERENCES consultas(id) ON DELETE CASCADE,
    mensaje TEXT NOT NULL,
    fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- OPTIMIZACIÓN E ÍNDICES
-- ==========================================
-- Índice crucial para que el Trigger busque rápido por medicamento y paciente
CREATE INDEX idx_busqueda_alertas ON tratamientos(medicamento);
CREATE INDEX idx_consultas_paciente ON consultas(paciente_id);