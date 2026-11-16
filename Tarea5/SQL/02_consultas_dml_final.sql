-- TAREA 5 | CONSULTAS DML | Juan Jose Oquendo Sanchez
-- Ejecutar despues del DDL y los datos ficticios. PostgreSQL 16.

-- Consulta 1. Estudiantes con habilidades tecnologicas
-- CONSULTA 1: Estudiantes con habilidades tecnologicas.
-- Seleccionamos nombre, programa, habilidad y nivel de dominio.
SELECT
    u.nombre_completo AS estudiante,
    a.nombre_area AS programa,
    i.nombre AS habilidad,
    ui.nivel AS nivel_habilidad
-- Leemos los estudiantes de la red social.
FROM red_social_pascualina.usuario AS u
-- Vinculamos el estudiante con su programa.
INNER JOIN red_social_pascualina.area_estudio AS a
    ON u.id_area = a.id_area
-- Obtenemos la relacion usuario-interes.
INNER JOIN red_social_pascualina.usuario_interes AS ui
    ON u.id_usuario = ui.id_usuario
-- Recuperamos nombre y categoria de cada habilidad.
INNER JOIN red_social_pascualina.interes_habilidad AS i
    ON ui.id_interes = i.id_interes
-- Solo habilidades de categoria tecnologica.
WHERE i.categoria = 'tecnologica'
-- Ordenamos alfabeticamente para lectura consistente.
ORDER BY u.nombre_completo, i.nombre;

-- Consulta 2. Participacion por grupo
-- CONSULTA 2: Cantidad de integrantes por grupo.
-- Reportamos nombre del grupo e indicador agregado.
SELECT
    g.nombre_grupo AS grupo,
    -- Contamos usuarios asociados a membresias.
    COUNT(m.id_usuario) AS total_integrantes
-- Leemos todos los grupos, incluso si estan vacios.
FROM red_social_pascualina.grupo AS g
-- LEFT JOIN evita perder grupos sin integrantes.
LEFT JOIN red_social_pascualina.membresia_grupo AS m
    ON g.id_grupo = m.id_grupo
-- Agrupacion por identidad del grupo y nombre visible.
GROUP BY g.id_grupo, g.nombre_grupo
-- Priorizamos los grupos de mayor participacion.
ORDER BY total_integrantes DESC, g.nombre_grupo;

-- Consulta 3. Confirmaciones a eventos
-- CONSULTA 3: Participacion confirmada en eventos.
-- Identificamos cada evento y a su organizador.
SELECT
    e.nombre_evento AS evento,
    u.nombre_completo AS organizador,
    -- Contamos exclusivamente respuestas confirmadas.
    COUNT(a.id_usuario) AS total_confirmados
-- Partimos de todas las actividades registradas.
FROM red_social_pascualina.evento AS e
-- Recuperamos quien organiza el evento.
INNER JOIN red_social_pascualina.usuario AS u
    ON e.id_usuario_organizador = u.id_usuario
-- Se conservan eventos sin confirmaciones.
LEFT JOIN red_social_pascualina.asistencia_evento AS a
    ON e.id_evento = a.id_evento
    AND a.estado_asistencia = 'confirmado'
-- Agrupamos cada evento y su organizador.
GROUP BY e.id_evento, e.nombre_evento, u.nombre_completo
-- Primero los eventos mas confirmados.
ORDER BY total_confirmados DESC, e.nombre_evento;

-- Consulta 4. Interacciones de publicaciones
-- CONSULTA 4: Publicaciones con mayor interaccion.
-- Recuperamos el ID, autor, tipo y resumen del contenido.
SELECT
    p.id_publicacion,
    u.nombre_completo AS autor,
    p.tipo AS tipo_publicacion,
    LEFT(p.contenido, 60) AS contenido_resumen,
    -- Subconsulta: comentarios por publicacion.
    (SELECT COUNT(*)
     FROM red_social_pascualina.comentario AS c
     WHERE c.id_publicacion = p.id_publicacion) AS total_comentarios,
    -- Subconsulta: reacciones por publicacion.
    (SELECT COUNT(*)
     FROM red_social_pascualina.reaccion AS r
     WHERE r.id_publicacion = p.id_publicacion) AS total_reacciones,
    -- Sumamos ambos conteos sin sobrecontar combinaciones.
    (SELECT COUNT(*)
     FROM red_social_pascualina.comentario AS c
     WHERE c.id_publicacion = p.id_publicacion)
    +
    (SELECT COUNT(*)
     FROM red_social_pascualina.reaccion AS r
     WHERE r.id_publicacion = p.id_publicacion) AS total_interacciones
-- Consultamos publicaciones y sus autores.
FROM red_social_pascualina.publicacion AS p
INNER JOIN red_social_pascualina.usuario AS u
    ON p.id_usuario = u.id_usuario
-- Mostramos primero la actividad mas alta.
ORDER BY total_interacciones DESC, p.id_publicacion;

-- Consulta 5. Candidatos a mentorias
-- CONSULTA 5: Identificacion de posibles mentores.
-- Recuperamos el perfil y programa de cada candidato.
SELECT
    u.nombre_completo AS posible_mentor,
    a.nombre_area AS programa_academico,
    -- Numero de habilidades tecnologicas avanzadas unicas.
    COUNT(DISTINCT i.id_interes) AS habilidades_avanzadas,
    -- Agrupacion legible de especialidades en una sola fila.
    STRING_AGG(i.nombre, ', ' ORDER BY i.nombre) AS especialidades
-- Comenzamos por los estudiantes.
FROM red_social_pascualina.usuario AS u
INNER JOIN red_social_pascualina.area_estudio AS a
    ON u.id_area = a.id_area
-- Vinculamos las competencias declaradas.
INNER JOIN red_social_pascualina.usuario_interes AS ui
    ON u.id_usuario = ui.id_usuario
INNER JOIN red_social_pascualina.interes_habilidad AS i
    ON ui.id_interes = i.id_interes
-- Criterios: tecnologica y avanzada.
WHERE i.categoria = 'tecnologica'
  AND ui.nivel = 'avanzado'
-- Una fila por estudiante y programa.
GROUP BY u.id_usuario, u.nombre_completo, a.nombre_area
-- Priorizamos cantidad de especialidades.
ORDER BY habilidades_avanzadas DESC, posible_mentor ASC;
