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
    v_dias_ventana INT := 60;
    v_limite_veces INT := 3;
BEGIN
    SELECT paciente_id INTO v_paciente_id 
    FROM consultas 
    WHERE id = NEW.consulta_id;

    SELECT COUNT(*) INTO v_conteo
    FROM tratamientos t
    JOIN consultas c ON t.consulta_id = c.id
    WHERE c.paciente_id = v_paciente_id
      AND t.medicamento = NEW.medicamento
      AND c.fecha >= (CURRENT_DATE - (v_dias_ventana || ' days')::interval);

    IF v_conteo >= v_limite_veces THEN
        RAISE EXCEPTION '⚠️ ALERTA CLÍNICA: El paciente ha recibido [%] % veces en los últimos % días. Evaluar efectividad o posible resistencia.',
            NEW.medicamento, v_conteo, v_dias_ventana;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- El trigger evalúa CADA tratamiento nuevo que se intente guardar
CREATE TRIGGER tr_analizar_tratamiento
BEFORE INSERT ON tratamientos  -- ✅ evalúa antes de insertar
FOR EACH ROW
EXECUTE FUNCTION fn_evaluar_tratamiento();