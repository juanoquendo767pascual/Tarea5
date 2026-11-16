-- TAREA 5: orden completo en un entorno PostgreSQL vacio (p. ej., db<>fiddle).
-- No ejecutar en bases reales o compartidas.

-- Tarea 4 | Red Social Pascualina | Juan Jose Oquendo Sanchez
-- PostgreSQL. Modelo equivalente al de Tarea 3, ampliado con evento.metadatos_contexto.
-- Ejecutar conectado a una base de datos vacia o nueva; requiere permiso CREATE SCHEMA.
BEGIN;
CREATE SCHEMA red_social_pascualina;
SET LOCAL search_path TO red_social_pascualina, public;


-- AREA_ESTUDIO
CREATE TABLE area_estudio (
    id_area INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    nombre_area VARCHAR(120) NOT NULL,
    facultad VARCHAR(140) NOT NULL,
    CONSTRAINT pk_area_estudio PRIMARY KEY (id_area),
    CONSTRAINT uq_area_estudio_nombre_area UNIQUE (nombre_area),
    CONSTRAINT ck_area_estudio_nombre_area_no_vacio CHECK (btrim(nombre_area) <> ''),
    CONSTRAINT ck_area_estudio_facultad_no_vacio CHECK (btrim(facultad) <> '')
);


-- USUARIO
CREATE TABLE usuario (
    id_usuario INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    id_area INTEGER NOT NULL,
    nombre_completo VARCHAR(160) NOT NULL,
    correo_institucional VARCHAR(180) NOT NULL,
    fecha_nacimiento DATE,
    fecha_registro TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    foto_perfil TEXT,
    biografia TEXT,
    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_correo_institucional UNIQUE (correo_institucional),
    CONSTRAINT fk_usuario_id_area FOREIGN KEY (id_area) REFERENCES area_estudio (id_area) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_usuario_nombre_completo_no_vacio CHECK (btrim(nombre_completo) <> ''),
    CONSTRAINT ck_usuario_correo_institucional_no_vacio CHECK (btrim(correo_institucional) <> '')
);


-- INTERES_HABILIDAD
CREATE TABLE interes_habilidad (
    id_interes INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    categoria VARCHAR(80) NOT NULL,
    CONSTRAINT pk_interes_habilidad PRIMARY KEY (id_interes),
    CONSTRAINT uq_interes_habilidad_nombre_categoria UNIQUE (nombre, categoria),
    CONSTRAINT ck_interes_habilidad_nombre_no_vacio CHECK (btrim(nombre) <> ''),
    CONSTRAINT ck_interes_habilidad_categoria_no_vacio CHECK (btrim(categoria) <> '')
);


-- USUARIO_INTERES
CREATE TABLE usuario_interes (
    id_usuario INTEGER NOT NULL,
    id_interes INTEGER NOT NULL,
    nivel VARCHAR(40) NOT NULL,
    CONSTRAINT pk_usuario_interes PRIMARY KEY (id_usuario, id_interes),
    CONSTRAINT fk_usuario_interes_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_usuario_interes_id_interes FOREIGN KEY (id_interes) REFERENCES interes_habilidad (id_interes) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_usuario_interes_nivel_dom CHECK (nivel IN ('basico', 'intermedio', 'avanzado'))
);


-- CONEXION
CREATE TABLE conexion (
    id_usuario_origen INTEGER NOT NULL,
    id_usuario_destino INTEGER NOT NULL,
    estado VARCHAR(40) NOT NULL,
    fecha_conexion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_conexion PRIMARY KEY (id_usuario_origen, id_usuario_destino),
    CONSTRAINT fk_conexion_id_usuario_origen FOREIGN KEY (id_usuario_origen) REFERENCES usuario (id_usuario) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_conexion_id_usuario_destino FOREIGN KEY (id_usuario_destino) REFERENCES usuario (id_usuario) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT ck_conexion_estado_dom CHECK (estado IN ('pendiente', 'aceptada', 'rechazada', 'bloqueada')),
    CONSTRAINT ck_conexion_distinta CHECK (id_usuario_origen <> id_usuario_destino)
);


-- GRUPO
CREATE TABLE grupo (
    id_grupo INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    id_usuario_creador INTEGER NOT NULL,
    nombre_grupo VARCHAR(160) NOT NULL,
    descripcion TEXT,
    tipo_grupo VARCHAR(60) NOT NULL,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),
    CONSTRAINT fk_grupo_id_usuario_creador FOREIGN KEY (id_usuario_creador) REFERENCES usuario (id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_grupo_nombre_grupo_no_vacio CHECK (btrim(nombre_grupo) <> ''),
    CONSTRAINT ck_grupo_tipo_grupo_dom CHECK (tipo_grupo IN ('estudio', 'club', 'hackaton', 'deportes', 'otro'))
);


-- MEMBRESIA_GRUPO
CREATE TABLE membresia_grupo (
    id_usuario INTEGER NOT NULL,
    id_grupo INTEGER NOT NULL,
    rol VARCHAR(40) NOT NULL,
    fecha_ingreso TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_membresia_grupo PRIMARY KEY (id_usuario, id_grupo),
    CONSTRAINT fk_membresia_grupo_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_membresia_grupo_id_grupo FOREIGN KEY (id_grupo) REFERENCES grupo (id_grupo) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT ck_membresia_grupo_rol_dom CHECK (rol IN ('administrador', 'moderador', 'miembro'))
);


-- PUBLICACION
CREATE TABLE publicacion (
    id_publicacion INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    id_usuario INTEGER NOT NULL,
    id_grupo INTEGER,
    tipo VARCHAR(50) NOT NULL,
    contenido TEXT NOT NULL,
    fecha_publicacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_publicacion PRIMARY KEY (id_publicacion),
    CONSTRAINT fk_publicacion_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_publicacion_id_grupo FOREIGN KEY (id_grupo) REFERENCES grupo (id_grupo) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT ck_publicacion_tipo_dom CHECK (tipo IN ('pregunta', 'recurso', 'noticia', 'meme', 'otro')),
    CONSTRAINT ck_publicacion_contenido_no_vacio CHECK (btrim(contenido) <> '')
);


-- COMENTARIO
CREATE TABLE comentario (
    id_comentario INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    id_usuario INTEGER NOT NULL,
    id_publicacion INTEGER NOT NULL,
    contenido TEXT NOT NULL,
    fecha_comentario TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_comentario PRIMARY KEY (id_comentario),
    CONSTRAINT fk_comentario_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_comentario_id_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion (id_publicacion) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT ck_comentario_contenido_no_vacio CHECK (btrim(contenido) <> '')
);


-- REACCION
CREATE TABLE reaccion (
    id_usuario INTEGER NOT NULL,
    id_publicacion INTEGER NOT NULL,
    tipo_reaccion VARCHAR(40) NOT NULL,
    fecha_reaccion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_reaccion PRIMARY KEY (id_usuario, id_publicacion),
    CONSTRAINT fk_reaccion_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_reaccion_id_publicacion FOREIGN KEY (id_publicacion) REFERENCES publicacion (id_publicacion) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT ck_reaccion_tipo_reaccion_dom CHECK (tipo_reaccion IN ('me_gusta', 'me_encanta', 'apoyo', 'divertido', 'sorprendido'))
);


-- EVENTO
CREATE TABLE evento (
    id_evento INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    id_usuario_organizador INTEGER NOT NULL,
    id_grupo INTEGER,
    nombre_evento VARCHAR(180) NOT NULL,
    descripcion TEXT,
    fecha_hora_inicio TIMESTAMPTZ NOT NULL,
    fecha_hora_fin TIMESTAMPTZ NOT NULL,
    ubicacion TEXT NOT NULL,
    metadatos_contexto JSONB,
    CONSTRAINT pk_evento PRIMARY KEY (id_evento),
    CONSTRAINT fk_evento_id_usuario_organizador FOREIGN KEY (id_usuario_organizador) REFERENCES usuario (id_usuario) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_evento_id_grupo FOREIGN KEY (id_grupo) REFERENCES grupo (id_grupo) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT ck_evento_nombre_evento_no_vacio CHECK (btrim(nombre_evento) <> ''),
    CONSTRAINT ck_evento_ubicacion_no_vacio CHECK (btrim(ubicacion) <> ''),
    CONSTRAINT ck_evento_fechas CHECK (fecha_hora_fin > fecha_hora_inicio),
    CONSTRAINT ck_evento_metadatos_objeto CHECK (metadatos_contexto IS NULL OR jsonb_typeof(metadatos_contexto) = 'object')
);


-- ASISTENCIA_EVENTO
CREATE TABLE asistencia_evento (
    id_usuario INTEGER NOT NULL,
    id_evento INTEGER NOT NULL,
    estado_asistencia VARCHAR(30) NOT NULL,
    CONSTRAINT pk_asistencia_evento PRIMARY KEY (id_usuario, id_evento),
    CONSTRAINT fk_asistencia_evento_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_asistencia_evento_id_evento FOREIGN KEY (id_evento) REFERENCES evento (id_evento) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT ck_asistencia_evento_estado_asistencia_dom CHECK (estado_asistencia IN ('interesado', 'confirmado', 'no_asiste'))
);

CREATE INDEX idx_usuario_id_area ON usuario (id_area);
CREATE INDEX idx_usuario_interes_id_interes ON usuario_interes (id_interes);
CREATE INDEX idx_conexion_id_usuario_destino ON conexion (id_usuario_destino);
CREATE INDEX idx_grupo_id_usuario_creador ON grupo (id_usuario_creador);
CREATE INDEX idx_membresia_grupo_id_grupo ON membresia_grupo (id_grupo);
CREATE INDEX idx_publicacion_id_usuario ON publicacion (id_usuario);
CREATE INDEX idx_publicacion_id_grupo ON publicacion (id_grupo);
CREATE INDEX idx_comentario_id_usuario ON comentario (id_usuario);
CREATE INDEX idx_comentario_id_publicacion ON comentario (id_publicacion);
CREATE INDEX idx_reaccion_id_publicacion ON reaccion (id_publicacion);
CREATE INDEX idx_evento_id_usuario_organizador ON evento (id_usuario_organizador);
CREATE INDEX idx_evento_id_grupo ON evento (id_grupo);
CREATE INDEX idx_asistencia_evento_id_evento ON asistencia_evento (id_evento);

-- Indice JSON para busquedas por contenido de objeto; extension propia del motor.
CREATE INDEX idx_evento_metadatos_gin ON evento USING GIN (metadatos_contexto);

COMMIT;


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
