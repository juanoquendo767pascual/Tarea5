-- Tarea 5 | Borrador individual previo a la versión final.
-- Estudiante: Juan José Oquendo Sánchez.
-- Hipótesis de mejora: evitar doble conteo al unir dos tablas de actividad 1:N.
-- Borrador consulta A: el conteo se hace con un único conjunto de miembros.
SELECT g.nombre_grupo, COUNT(m.id_usuario) AS miembros
FROM red_social_pascualina.grupo AS g
LEFT JOIN red_social_pascualina.membresia_grupo AS m ON m.id_grupo = g.id_grupo
GROUP BY g.id_grupo, g.nombre_grupo;

-- Borrador consulta B: intereses de cada estudiante; puede devolver varias filas por estudiante.
SELECT u.nombre_completo, i.nombre AS interes
FROM red_social_pascualina.usuario AS u
JOIN red_social_pascualina.usuario_interes AS ui ON ui.id_usuario = u.id_usuario
JOIN red_social_pascualina.interes_habilidad AS i ON i.id_interes = ui.id_interes;

-- En versión final se ampliaron estas consultas para segmentación, cálculos y métricas coherentes.
