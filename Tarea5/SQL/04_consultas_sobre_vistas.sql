-- TAREA 5 | CONSULTAS DE LAS TRES VISTAS | PostgreSQL 16

-- Vista 1. Perfiles e intereses
-- Consultar la vista 1: habilidades avanzadas.
SELECT estudiante, area_academica, interes_habilidad, nivel_interes
FROM red_social_pascualina.vw_perfiles_intereses
WHERE nivel_interes = 'avanzado'
ORDER BY area_academica, estudiante;

-- Vista 2. Indicadores de grupos
-- Consultar la vista 2: actividad de comunidades.
SELECT nombre_grupo, total_miembros, total_publicaciones, total_eventos
FROM red_social_pascualina.vw_indicadores_grupos
ORDER BY total_miembros DESC, nombre_grupo;

-- Vista 3. Indicadores de asistencia
-- Consultar la vista 3: asistencia y estados.
SELECT evento, organizador, total_confirmados,
       total_interesados, total_no_asisten, total_respuestas
FROM red_social_pascualina.vw_asistencia_eventos
ORDER BY total_confirmados DESC, evento;
