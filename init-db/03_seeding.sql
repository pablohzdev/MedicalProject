-- =============================================
-- INSERCIÓN DE MÉDICOS (2 registros)
-- =============================================
INSERT INTO medicos (id, nombre, especialidad) VALUES
(1, 'Dr. Carlos Mendoza', 'Medicina General'),
(2, 'Dra. Laura Sánchez', 'Pediatría y Medicina Interna');

-- =============================================
-- INSERCIÓN DE PACIENTES (6 registros)
-- =============================================
INSERT INTO pacientes (id, nombre, genero, fecha_nacimiento, grupo_sanguineo, antecedentes, creado_en) VALUES
(1, 'Juan Pérez', 'Masculino', '1985-06-12', 'O+', 'Hipertensión leve', NOW()),
(2, 'María Gómez', 'Femenino', '1992-03-25', 'A-', 'Ninguno', NOW()),
(3, 'Luis Rodríguez', 'Masculino', '1978-11-08', 'B+', 'Diabetes tipo 2', NOW()),
(4, 'Ana Martínez', 'Femenino', '2001-07-15', 'AB+', 'Asma', NOW()),
(5, 'Roberto Sánchez', 'Masculino', '1965-01-30', 'O-', 'Artritis', NOW()),
(6, 'Elena Vargas', 'Femenino', '1998-09-05', 'A+', 'Ninguno', NOW());

-- =============================================
-- INSERCIÓN DE CONSULTAS (24 registros)
-- Fechas distribuidas entre febrero y mayo 2026
-- =============================================
INSERT INTO consultas (id, paciente_id, medico_id, fecha, motivo_consulta, diagnostico) VALUES
-- Juan Pérez (caso trigger)
(1, 1, 1, '2026-04-01 09:30:00', 'Dolor de cabeza y fiebre', 'Infección viral'),
(2, 1, 1, '2026-04-15 10:15:00', 'Dolor muscular', 'Mialgia'),
(3, 1, 1, '2026-05-05 08:45:00', 'Fiebre persistente', 'Infección respiratoria'),

-- María Gómez (caso límite)
(4, 2, 1, '2026-03-01 11:00:00', 'Dolor intenso', 'Contractura muscular'),
(5, 2, 1, '2026-03-15 09:20:00', 'Dolor lumbar', 'Lumbalgia'),
(6, 2, 1, '2026-05-20 10:30:00', 'Dolor de espalda', 'Lumbago crónico'),

-- Caso Limpio
(7, 3, 2, '2026-01-20 08:00:00', 'Infección de garganta', 'Faringoamigdalitis'),
(8, 3, 1, '2026-03-10 09:45:00', 'Alergia estacional', 'Rinitis alérgica'),

-- Resto de consultas (relleno realista)
(9, 4, 1, '2026-02-05 10:00:00', 'Dolor abdominal', 'Gastritis'),
(10, 4, 2, '2026-04-12 11:30:00', 'Control pediátrico', 'Control rutinario'),
(11, 5, 1, '2026-02-18 08:30:00', 'Dolor articular', 'Artrosis'),
(12, 5, 1, '2026-03-22 09:10:00', 'Revisión', 'Seguimiento'),
(13, 6, 2, '2026-02-28 10:45:00', 'Chequeo general', 'Control preventivo'),
(14, 1, 1, '2026-02-10 09:00:00', 'Resfriado común', 'Infección respiratoria alta'),
(15, 2, 1, '2026-04-08 10:20:00', 'Dolor de cabeza', 'Cefalea tensional'),
(16, 3, 2, '2026-03-05 08:15:00', 'Tos persistente', 'Bronquitis'),
(17, 4, 1, '2026-05-02 11:00:00', 'Dolor de oídos', 'Otitis media'),
(18, 5, 1, '2026-04-25 09:30:00', 'Hipertensión', 'Seguimiento'),
(19, 6, 2, '2026-03-18 10:00:00', 'Fatiga', 'Anemia leve'),
(20, 1, 1, '2026-05-15 08:50:00', 'Control general', 'Seguimiento'),
(21, 2, 1, '2026-05-10 09:40:00', 'Revisión', 'Control'),
(22, 3, 1, '2026-04-28 10:30:00', 'Dolor de rodilla', 'Lesión ligamentosa'),
(23, 4, 2, '2026-05-12 11:15:00', 'Alergia', 'Dermatitis'),
(24, 6, 1, '2026-04-18 09:20:00', 'Infección urinaria', 'Cistitis');

-- =============================================
-- INSERCIÓN DE TRATAMIENTOS (38 registros)
-- =============================================
ALTER TABLE tratamientos DISABLE TRIGGER tr_analizar_tratamiento;

INSERT INTO tratamientos (id, consulta_id, medicamento, dosis, duracion_dias, motivo_tratamiento, fecha_registro) VALUES
-- === CASO TRIGGER - Juan Pérez (Paracetamol) ===
(1, 1, 'Paracetamol', '500mg cada 8 horas', 5, 'Control de fiebre y dolor', '2026-04-01 09:35:00'),
(2, 2, 'Paracetamol', '500mg cada 8 horas', 7, 'Dolor muscular', '2026-04-15 10:20:00'),
(3, 3, 'Paracetamol', '500mg cada 6 horas', 5, 'Fiebre persistente', '2026-05-05 08:50:00'),

-- === CASO LÍMITE - María Gómez (Ketorolaco) ===
(4, 4, 'Ketorolaco', '10mg cada 8 horas', 5, 'Dolor intenso', '2026-03-01 11:05:00'),
(5, 5, 'Ketorolaco', '10mg cada 8 horas', 5, 'Lumbalgia', '2026-03-15 09:25:00'),
(6, 6, 'Ketorolaco', '10mg cada 8 horas', 5, 'Lumbago', '2026-05-20 10:35:00'),

-- === CASO LIMPIO ===
(7, 7, 'Amoxicilina', '500mg cada 8 horas', 7, 'Infección bacteriana', '2026-01-20 08:05:00'),
(8, 8, 'Loratadina', '10mg cada 24 horas', 14, 'Rinitis alérgica', '2026-03-10 09:50:00'),

-- Resto de tratamientos (relleno realista)
(9, 9, 'Omeprazol', '20mg cada 24 horas', 14, 'Gastritis', '2026-02-05 10:05:00'),
(10, 9, 'Hioscina', '10mg cada 8 horas', 5, 'Espasmos abdominales', '2026-02-05 10:06:00'),
(11, 10, 'Vitamina D', '2000 UI diarias', 30, 'Suplementación', '2026-04-12 11:35:00'),
(12, 11, 'Ibuprofeno', '400mg cada 8 horas', 7, 'Dolor articular', '2026-02-18 08:35:00'),
(13, 12, 'Losartán', '50mg cada 24 horas', 30, 'Hipertensión', '2026-03-22 09:15:00'),
(14, 13, 'Multivitamínico', '1 tableta diaria', 30, 'Suplemento', '2026-02-28 10:50:00'),
(15, 14, 'Amoxicilina', '875mg cada 12 horas', 7, 'Infección respiratoria', '2026-02-10 09:05:00'),
(16, 15, 'Paracetamol', '500mg cada 6 horas', 3, 'Cefalea', '2026-04-08 10:25:00'),
(17, 16, 'Azitromicina', '500mg día 1, luego 250mg', 5, 'Bronquitis', '2026-03-05 08:20:00'),
(18, 17, 'Amoxicilina + Clavulánico', '875mg cada 12 horas', 7, 'Otitis media', '2026-05-02 11:05:00'),
(19, 18, 'Losartán', '50mg cada 24 horas', 30, 'Control de presión', '2026-04-25 09:35:00'),
(20, 19, 'Hierro', '100mg cada 24 horas', 30, 'Anemia', '2026-03-18 10:05:00'),
(21, 20, 'Multivitamínico', '1 diaria', 30, 'Control general', '2026-05-15 08:55:00'),
(22, 21, 'Paracetamol', '500mg según necesidad', 5, 'Dolor', '2026-05-10 09:45:00'),
(23, 22, 'Diclofenaco', '50mg cada 8 horas', 7, 'Dolor de rodilla', '2026-04-28 10:35:00'),
(24, 23, 'Loratadina', '10mg diaria', 14, 'Dermatitis alérgica', '2026-05-12 11:20:00'),
(25, 24, 'Nitrofurantoína', '100mg cada 6 horas', 7, 'Infección urinaria', '2026-04-18 09:25:00'),

-- Tratamientos adicionales para llegar a ~38
(26, 1, 'Ibuprofeno', '400mg cada 8 horas', 5, 'Antiinflamatorio', '2026-04-01 09:36:00'),
(27, 4, 'Relajante muscular', '1 tableta cada 12 horas', 5, 'Contractura', '2026-03-01 11:06:00'),
(28, 8, 'Desloratadina', '5mg diaria', 10, 'Alergia', '2026-03-10 09:51:00'),
(29, 11, 'Colchicina', '0.5mg cada 12 horas', 7, 'Artritis', '2026-02-18 08:36:00'),
(30, 16, 'Mucolítico', '10ml cada 8 horas', 5, 'Tos', '2026-03-05 08:21:00'),
(31, 17, 'Gotas óticas', '3 gotas cada 8 horas', 7, 'Otitis', '2026-05-02 11:06:00'),
(32, 22, 'Omeprazol', '20mg diaria', 14, 'Protección gástrica', '2026-04-28 10:36:00'),
(33, 3, 'Loratadina', '10mg diaria', 7, 'Componente alérgico', '2026-05-05 08:51:00'),
(34, 6, 'Ibuprofeno', '400mg cada 8 horas', 5, 'Antiinflamatorio', '2026-05-20 10:36:00'),
(35, 12, 'Metformina', '500mg cada 12 horas', 30, 'Diabetes', '2026-03-22 09:16:00'),
(36, 18, 'Amlodipino', '5mg diaria', 30, 'Hipertensión', '2026-04-25 09:36:00'),
(37, 23, 'Crema de hidrocortisona', 'Aplicar 2 veces al día', 10, 'Dermatitis', '2026-05-12 11:21:00'),
(38, 24, 'Fenazopiridina', '200mg cada 8 horas', 3, 'Alivio de síntomas urinarios', '2026-04-18 09:26:00');

ALTER TABLE tratamientos ENABLE TRIGGER tr_analizar_tratamiento;


-- Sincronizar secuencias para que el siguiente ID sea correcto
SELECT setval('consultas_id_seq', (SELECT MAX(id) FROM consultas));
SELECT setval('tratamientos_id_seq', (SELECT MAX(id) FROM tratamientos));
SELECT setval('pacientes_id_seq', (SELECT MAX(id) FROM pacientes));
SELECT setval('medicos_id_seq', (SELECT MAX(id) FROM medicos));