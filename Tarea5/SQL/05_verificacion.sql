-- Validacion de estructura en PostgreSQL 16.
SELECT COUNT(*) AS total_tablas
FROM information_schema.tables
WHERE table_schema = 'red_social_pascualina' AND table_type = 'BASE TABLE';
-- Esperado: 12 tablas.
SELECT COUNT(*) AS total_vistas
FROM information_schema.views
WHERE table_schema = 'red_social_pascualina';
-- Esperado: 3 vistas.
-- El esquema de db<>fiddle es temporal y los resultados estan basados en datos ficticios.
