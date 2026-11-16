-- TAREA 5 | CREACION DE VISTAS | PostgreSQL 16
-- CREATE VIEW pertenece a DDL; las consultas SELECT son DML.

-- Vista 1. Perfiles e intereses
-- VISTA 1: Perfiles e intereses estudiantiles.
-- Creamos una vista no materializada reutilizable.
CREATE OR REPLACE VIEW red_social_pascualina.vw_perfiles_intereses AS
SELECT
    u.id_usuario,
    u.nombre_completo AS estudiante,
    a.nombre_area AS area_academica,
    i.nombre AS interes_habilidad,
    i.categoria AS categoria_interes,
    ui.nivel AS nivel_interes
-- Estudiantes y su area academica obligatoria.
FROM red_social_pascualina.usuario AS u
INNER JOIN red_social_pascualina.area_estudio AS a
    ON a.id_area = u.id_area
-- LEFT JOIN mantiene perfiles aun sin intereses.
LEFT JOIN red_social_pascualina.usuario_interes AS ui
    ON ui.id_usuario = u.id_usuario
LEFT JOIN red_social_pascualina.interes_habilidad AS i
    ON i.id_interes = ui.id_interes;

-- Vista 2. Indicadores de grupos
-- VISTA 2: Indicadores de actividad de grupos.
-- Separamos las metricas para evitar sobreconteos.
CREATE OR REPLACE VIEW red_social_pascualina.vw_indicadores_grupos AS
WITH miembros AS (
    -- Total de estudiantes por grupo.
    SELECT id_grupo, COUNT(*) AS total_miembros
    FROM red_social_pascualina.membresia_grupo
    GROUP BY id_grupo
),
posts AS (
    -- Total de publicaciones por grupo.
    SELECT id_grupo, COUNT(*) AS total_publicaciones
    FROM red_social_pascualina.publicacion
    WHERE id_grupo IS NOT NULL
    GROUP BY id_grupo
),
agenda AS (
    -- Total de eventos asociados a un grupo.
    SELECT id_grupo, COUNT(*) AS total_eventos
    FROM red_social_pascualina.evento
    WHERE id_grupo IS NOT NULL
    GROUP BY id_grupo
)
-- Consolidamos una fila por grupo.
SELECT
    g.id_grupo,
    g.nombre_grupo,
    g.tipo_grupo,
    COALESCE(m.total_miembros, 0) AS total_miembros,
    COALESCE(p.total_publicaciones, 0) AS total_publicaciones,
    COALESCE(a.total_eventos, 0) AS total_eventos
FROM red_social_pascualina.grupo AS g
LEFT JOIN miembros AS m ON m.id_grupo = g.id_grupo
LEFT JOIN posts AS p ON p.id_grupo = g.id_grupo
LEFT JOIN agenda AS a ON a.id_grupo = g.id_grupo;

-- Vista 3. Indicadores de asistencia
-- VISTA 3: Indicadores de asistencia a eventos.
-- Permite analizar respuestas por estado en una sola vista.
CREATE OR REPLACE VIEW red_social_pascualina.vw_asistencia_eventos AS
SELECT
    e.id_evento,
    e.nombre_evento AS evento,
    u.nombre_completo AS organizador,
    e.fecha_hora_inicio AS fecha_evento,
    -- FILTER cuenta solo confirmaciones.
    COUNT(a.id_usuario) FILTER (
        WHERE a.estado_asistencia = 'confirmado'
    ) AS total_confirmados,
    -- Respuestas de interesados.
    COUNT(a.id_usuario) FILTER (
        WHERE a.estado_asistencia = 'interesado'
    ) AS total_interesados,
    -- Respuestas de quienes no asistiran.
    COUNT(a.id_usuario) FILTER (
        WHERE a.estado_asistencia = 'no_asiste'
    ) AS total_no_asisten,
    -- Cantidad total de respuestas registradas.
    COUNT(a.id_usuario) AS total_respuestas
FROM red_social_pascualina.evento AS e
-- Cada evento tiene un organizador responsable.
INNER JOIN red_social_pascualina.usuario AS u
    ON e.id_usuario_organizador = u.id_usuario
-- Conservamos eventos incluso sin respuestas.
LEFT JOIN red_social_pascualina.asistencia_evento AS a
    ON e.id_evento = a.id_evento
-- Agrupamos por evento y organizador.
GROUP BY e.id_evento, e.nombre_evento, u.nombre_completo,
         e.fecha_hora_inicio;
