-- ==========================================
-- LÓGICA DE BASE DE DATOS: TRIGGERS Y FUNCIONES
-- ==========================================

-- --------------------------------------------------------
-- PARTE 1: ESCUCHA ACTIVA PARA WEBSOCKETS (Frontend en tiempo real)
-- --------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_notificar_cambio()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify('cambios_clinica', 'refresh_data');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_ws_pacientes AFTER INSERT OR UPDATE OR DELETE ON pacientes FOR EACH ROW EXECUTE FUNCTION fn_notificar_cambio();
CREATE TRIGGER tr_ws_consultas AFTER INSERT OR UPDATE OR DELETE ON consultas FOR EACH ROW EXECUTE FUNCTION fn_notificar_cambio();
CREATE TRIGGER tr_ws_tratamientos AFTER INSERT OR UPDATE OR DELETE ON tratamientos FOR EACH ROW EXECUTE FUNCTION fn_notificar_cambio();

-- --------------------------------------------------------
-- PARTE 2: MOTOR DE ALERTAS MÉDICAS (MVP)
-- --------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_evaluar_tratamiento()
RETURNS TRIGGER AS $$
DECLARE
    v_paciente_id INT;
    v_conteo INT;
    v_dias_ventana INT := 60; -- Límite de tiempo: últimos 60 días
    v_limite_veces INT := 3;  -- Umbral: alerta a partir de la 3ra vez
BEGIN
    -- 1. Obtenemos el ID del paciente a partir del consulta_id del tratamiento
    SELECT paciente_id INTO v_paciente_id 
    FROM consultas 
    WHERE id = NEW.consulta_id;

    -- 2. Contamos cuántas veces se le ha recetado este MISMO medicamento 
    -- a este paciente en la ventana de tiempo definida (60 días).
    SELECT COUNT(*) INTO v_conteo
    FROM tratamientos t
    JOIN consultas c ON t.consulta_id = c.id
    WHERE c.paciente_id = v_paciente_id
      AND t.medicamento = NEW.medicamento
      AND c.fecha >= (CURRENT_DATE - (v_dias_ventana || ' days')::interval);

    -- 3. Si el conteo (incluyendo la inserción actual) llega a 3 (o más), 
    -- disparamos la alerta silenciosa.
    IF v_conteo >= v_limite_veces THEN
        INSERT INTO alertas_log (paciente_id, consulta_id, mensaje)
        VALUES (
            v_paciente_id, 
            NEW.consulta_id, 
            '⚠️ ALERTA CLINICA: El paciente ha recibido [' || NEW.medicamento || '] ' || v_conteo || ' veces en los últimos ' || v_dias_ventana || ' días. Evaluar efectividad o posible resistencia.'
        );
    END IF;

    -- Dejamos que el tratamiento se guarde normalmente
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- El trigger evalúa CADA tratamiento nuevo que se intente guardar
CREATE TRIGGER tr_analizar_tratamiento
AFTER INSERT ON tratamientos
FOR EACH ROW
EXECUTE FUNCTION fn_evaluar_tratamiento();