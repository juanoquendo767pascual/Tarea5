-- Tarea 5 | DATOS TOTALMENTE FICTICIOS para un entorno de aprendizaje PostgreSQL.
-- No ejecutar en servidores reales de MiEslabon ni sobre bases con información productiva.
-- Ejecutar una sola vez en BD nueva luego de 01_modelo_fisico_postgresql.sql.
BEGIN;
SET LOCAL search_path TO red_social_pascualina, public;

-- Catálogo de programas.
INSERT INTO area_estudio (nombre_area, facultad) VALUES
    ('Desarrollo de Software', 'Facultad de Ingenieria'),
    ('Ingenieria Electronica', 'Facultad de Ingenieria'),
    ('Diseno Grafico', 'Facultad de Produccion y Diseno'),
    ('Tecnologia en Sistemas', 'Facultad de Ingenieria');

-- Usuarios ficticios.
INSERT INTO usuario (id_area, nombre_completo, correo_institucional)
SELECT a.id_area, v.nombre, v.correo
FROM (VALUES
    ('Ana Ejemplo', 'ana.demo@ejemplo.test', 'Desarrollo de Software'),
    ('Bruno Ejemplo', 'bruno.demo@ejemplo.test', 'Desarrollo de Software'),
    ('Carla Ejemplo', 'carla.demo@ejemplo.test', 'Ingenieria Electronica'),
    ('Diego Ejemplo', 'diego.demo@ejemplo.test', 'Tecnologia en Sistemas'),
    ('Elena Ejemplo', 'elena.demo@ejemplo.test', 'Diseno Grafico'),
    ('Fabian Ejemplo', 'fabian.demo@ejemplo.test', 'Desarrollo de Software'),
    ('Gabriela Ejemplo', 'gabriela.demo@ejemplo.test', 'Ingenieria Electronica'),
    ('Hugo Ejemplo', 'hugo.demo@ejemplo.test', 'Tecnologia en Sistemas')
) AS v(nombre, correo, area)
JOIN area_estudio AS a ON a.nombre_area = v.area;

-- Catálogo de intereses.
INSERT INTO interes_habilidad (nombre, categoria) VALUES
    ('Python', 'tecnologica'),
    ('Internet de las cosas', 'tecnologica'),
    ('Redes', 'tecnologica'),
    ('Futbol', 'deportiva'),
    ('Diseno de interfaces', 'academica'),
    ('Analitica de datos', 'tecnologica'),
    ('Hackatones', 'tecnologica');

-- Nivel declarado por cada usuario-interés.
INSERT INTO usuario_interes (id_usuario, id_interes, nivel)
SELECT u.id_usuario, i.id_interes, v.nivel
FROM (VALUES
    ('ana.demo@ejemplo.test', 'Python', 'avanzado'),
    ('ana.demo@ejemplo.test', 'Analitica de datos', 'intermedio'),
    ('bruno.demo@ejemplo.test', 'Python', 'intermedio'),
    ('bruno.demo@ejemplo.test', 'Hackatones', 'avanzado'),
    ('carla.demo@ejemplo.test', 'Internet de las cosas', 'avanzado'),
    ('carla.demo@ejemplo.test', 'Redes', 'intermedio'),
    ('diego.demo@ejemplo.test', 'Redes', 'avanzado'),
    ('elena.demo@ejemplo.test', 'Diseno de interfaces', 'avanzado'),
    ('fabian.demo@ejemplo.test', 'Python', 'basico'),
    ('gabriela.demo@ejemplo.test', 'Internet de las cosas', 'intermedio'),
    ('hugo.demo@ejemplo.test', 'Futbol', 'avanzado'),
    ('hugo.demo@ejemplo.test', 'Redes', 'basico')
) AS v(correo, interes, nivel)
JOIN usuario AS u ON u.correo_institucional = v.correo
JOIN interes_habilidad AS i ON i.nombre = v.interes;

-- Comunidades estudiantiles.
INSERT INTO grupo (id_usuario_creador, nombre_grupo, tipo_grupo)
SELECT u.id_usuario, v.grupo, v.tipo
FROM (VALUES
    ('ana.demo@ejemplo.test', 'Semillero Python', 'estudio'),
    ('bruno.demo@ejemplo.test', 'Equipo Hackaton', 'hackaton'),
    ('carla.demo@ejemplo.test', 'Club IoT', 'club'),
    ('elena.demo@ejemplo.test', 'Comunidad Diseno', 'club')
) AS v(creador, grupo, tipo)
JOIN usuario AS u ON u.correo_institucional = v.creador;

-- Pertenencia y roles de las comunidades.
INSERT INTO membresia_grupo (id_usuario, id_grupo, rol)
SELECT u.id_usuario, g.id_grupo, v.rol
FROM (VALUES
    ('ana.demo@ejemplo.test', 'Semillero Python', 'administrador'),
    ('bruno.demo@ejemplo.test', 'Semillero Python', 'miembro'),
    ('fabian.demo@ejemplo.test', 'Semillero Python', 'miembro'),
    ('diego.demo@ejemplo.test', 'Semillero Python', 'miembro'),
    ('bruno.demo@ejemplo.test', 'Equipo Hackaton', 'administrador'),
    ('ana.demo@ejemplo.test', 'Equipo Hackaton', 'miembro'),
    ('diego.demo@ejemplo.test', 'Equipo Hackaton', 'miembro'),
    ('carla.demo@ejemplo.test', 'Club IoT', 'administrador'),
    ('gabriela.demo@ejemplo.test', 'Club IoT', 'miembro'),
    ('hugo.demo@ejemplo.test', 'Club IoT', 'miembro'),
    ('elena.demo@ejemplo.test', 'Comunidad Diseno', 'administrador'),
    ('fabian.demo@ejemplo.test', 'Comunidad Diseno', 'miembro')
) AS v(correo, grupo, rol)
JOIN usuario AS u ON u.correo_institucional = v.correo
JOIN grupo AS g ON g.nombre_grupo = v.grupo;

-- Publicaciones académicas e informales (grupo opcional).
INSERT INTO publicacion (id_usuario, id_grupo, tipo, contenido)
SELECT u.id_usuario, g.id_grupo, v.tipo, v.contenido
FROM (VALUES
    ('ana.demo@ejemplo.test', 'Semillero Python', 'recurso', 'Guia de Python para principiantes y ejercicios resueltos.'),
    ('fabian.demo@ejemplo.test', 'Semillero Python', 'pregunta', 'Como resolver una lista por comprension en Python?'),
    ('carla.demo@ejemplo.test', 'Club IoT', 'noticia', 'Presentacion del prototipo de sensores ambientales.'),
    ('diego.demo@ejemplo.test', 'Equipo Hackaton', 'pregunta', 'Quien quiere participar en el proximo hackaton?'),
    ('elena.demo@ejemplo.test', 'Comunidad Diseno', 'recurso', 'Recursos de accesibilidad para interfaces estudiantiles.'),
    ('ana.demo@ejemplo.test', NULL, 'meme', 'Cuando el codigo compila a la primera...'),
    ('gabriela.demo@ejemplo.test', 'Club IoT', 'pregunta', 'Como calibrar un sensor de temperatura?'),
    ('hugo.demo@ejemplo.test', NULL, 'noticia', 'Convocatoria deportiva universitaria abierta.')
) AS v(correo, grupo, tipo, contenido)
JOIN usuario AS u ON u.correo_institucional = v.correo
LEFT JOIN grupo AS g ON g.nombre_grupo = v.grupo;

-- Comentarios sobre publicaciones de demostración.
INSERT INTO comentario (id_usuario, id_publicacion, contenido)
SELECT u.id_usuario, p.id_publicacion, v.comentario
FROM (VALUES
    ('bruno.demo@ejemplo.test', 'Guia de Python para principiantes y ejercicios resueltos.', 'Gracias por compartir el recurso.'),
    ('fabian.demo@ejemplo.test', 'Guia de Python para principiantes y ejercicios resueltos.', 'Me sirvio la guia.'),
    ('ana.demo@ejemplo.test', 'Como resolver una lista por comprension en Python?', 'Prueba una expresion entre corchetes.'),
    ('carla.demo@ejemplo.test', 'Como calibrar un sensor de temperatura?', 'Consulta la hoja tecnica.'),
    ('gabriela.demo@ejemplo.test', 'Presentacion del prototipo de sensores ambientales.', 'Queremos conocer la demostracion.'),
    ('ana.demo@ejemplo.test', 'Quien quiere participar en el proximo hackaton?', 'Me interesa participar.'),
    ('diego.demo@ejemplo.test', 'Recursos de accesibilidad para interfaces estudiantiles.', 'Muy util para el equipo.'),
    ('elena.demo@ejemplo.test', 'Cuando el codigo compila a la primera...', 'Ese momento es legendario.')
) AS v(correo, publicacion, comentario)
JOIN usuario AS u ON u.correo_institucional = v.correo
JOIN publicacion AS p ON p.contenido = v.publicacion;

-- Una reacción por usuario y publicación.
INSERT INTO reaccion (id_usuario, id_publicacion, tipo_reaccion)
SELECT u.id_usuario, p.id_publicacion, v.tipo
FROM (VALUES
    ('ana.demo@ejemplo.test', 'Como resolver una lista por comprension en Python?', 'apoyo'),
    ('bruno.demo@ejemplo.test', 'Guia de Python para principiantes y ejercicios resueltos.', 'me_gusta'),
    ('carla.demo@ejemplo.test', 'Guia de Python para principiantes y ejercicios resueltos.', 'me_encanta'),
    ('diego.demo@ejemplo.test', 'Guia de Python para principiantes y ejercicios resueltos.', 'apoyo'),
    ('fabian.demo@ejemplo.test', 'Cuando el codigo compila a la primera...', 'divertido'),
    ('gabriela.demo@ejemplo.test', 'Presentacion del prototipo de sensores ambientales.', 'me_gusta'),
    ('hugo.demo@ejemplo.test', 'Presentacion del prototipo de sensores ambientales.', 'me_encanta'),
    ('ana.demo@ejemplo.test', 'Quien quiere participar en el proximo hackaton?', 'me_gusta'),
    ('bruno.demo@ejemplo.test', 'Recursos de accesibilidad para interfaces estudiantiles.', 'apoyo'),
    ('elena.demo@ejemplo.test', 'Como calibrar un sensor de temperatura?', 'me_gusta'),
    ('hugo.demo@ejemplo.test', 'Convocatoria deportiva universitaria abierta.', 'me_gusta')
) AS v(correo, publicacion, tipo)
JOIN usuario AS u ON u.correo_institucional = v.correo
JOIN publicacion AS p ON p.contenido = v.publicacion;

-- Eventos ficticios, uno con atributo JSONB de sensor de demostración.
INSERT INTO evento (id_usuario_organizador, id_grupo, nombre_evento, fecha_hora_inicio, fecha_hora_fin, ubicacion, metadatos_contexto)
SELECT u.id_usuario, g.id_grupo, v.evento, v.inicio::timestamptz, v.fin::timestamptz, v.ubicacion, v.metadatos::jsonb
FROM (VALUES
    ('ana.demo@ejemplo.test', 'Semillero Python', 'Taller Python basico', '2026-11-20 14:00:00-05', '2026-11-20 16:00:00-05', 'Laboratorio 2', NULL),
    ('bruno.demo@ejemplo.test', 'Equipo Hackaton', 'Preparacion Hackaton', '2026-11-22 09:00:00-05', '2026-11-22 11:00:00-05', 'Sala de proyectos', NULL),
    ('carla.demo@ejemplo.test', 'Club IoT', 'Demostracion de sensores IoT', '2026-11-25 10:00:00-05', '2026-11-25 12:00:00-05', 'Laboratorio electronica', '{"origen": "sensor_iot_demo", "ambiente": {"temperatura_c": 23.5, "humedad_pct": 61}, "medicion_simulada": true}'),
    ('ana.demo@ejemplo.test', NULL, 'Charla abierta de datos', '2026-12-01 15:00:00-05', '2026-12-01 16:30:00-05', 'Auditorio principal', NULL),
    ('diego.demo@ejemplo.test', 'Semillero Python', 'Encuentro de algoritmos', '2026-12-05 14:00:00-05', '2026-12-05 16:00:00-05', 'Sala 104', NULL)
) AS v(correo, grupo, evento, inicio, fin, ubicacion, metadatos)
JOIN usuario AS u ON u.correo_institucional = v.correo
LEFT JOIN grupo AS g ON g.nombre_grupo = v.grupo;

-- Registro de asistencia a eventos.
INSERT INTO asistencia_evento (id_usuario, id_evento, estado_asistencia)
SELECT u.id_usuario, e.id_evento, v.estado
FROM (VALUES
    ('ana.demo@ejemplo.test', 'Taller Python basico', 'confirmado'),
    ('bruno.demo@ejemplo.test', 'Taller Python basico', 'confirmado'),
    ('fabian.demo@ejemplo.test', 'Taller Python basico', 'interesado'),
    ('diego.demo@ejemplo.test', 'Taller Python basico', 'confirmado'),
    ('ana.demo@ejemplo.test', 'Preparacion Hackaton', 'confirmado'),
    ('bruno.demo@ejemplo.test', 'Preparacion Hackaton', 'confirmado'),
    ('diego.demo@ejemplo.test', 'Preparacion Hackaton', 'no_asiste'),
    ('carla.demo@ejemplo.test', 'Demostracion de sensores IoT', 'confirmado'),
    ('gabriela.demo@ejemplo.test', 'Demostracion de sensores IoT', 'interesado'),
    ('hugo.demo@ejemplo.test', 'Demostracion de sensores IoT', 'confirmado'),
    ('elena.demo@ejemplo.test', 'Charla abierta de datos', 'interesado'),
    ('fabian.demo@ejemplo.test', 'Encuentro de algoritmos', 'confirmado')
) AS v(correo, evento, estado)
JOIN usuario AS u ON u.correo_institucional = v.correo
JOIN evento AS e ON e.nombre_evento = v.evento;

-- Conexiones entre estudiantes.
INSERT INTO conexion (id_usuario_origen, id_usuario_destino, estado)
SELECT origen.id_usuario, destino.id_usuario, v.estado
FROM (VALUES
    ('ana.demo@ejemplo.test', 'fabian.demo@ejemplo.test', 'aceptada'),
    ('carla.demo@ejemplo.test', 'gabriela.demo@ejemplo.test', 'aceptada'),
    ('diego.demo@ejemplo.test', 'bruno.demo@ejemplo.test', 'pendiente')
) AS v(correo_origen, correo_destino, estado)
JOIN usuario AS origen ON origen.correo_institucional = v.correo_origen
JOIN usuario AS destino ON destino.correo_institucional = v.correo_destino;

COMMIT;
