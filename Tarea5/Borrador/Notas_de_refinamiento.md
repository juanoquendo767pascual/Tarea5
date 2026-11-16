# Evolución del borrador a la versión final

**Trabajo individual:** Juan José Oquendo Sánchez. No se atribuyen sesiones de discusión ni contribuciones de compañeros.

1. Se pasó del simple conteo de miembros al indicador de grupos con publicaciones y eventos, usando agregaciones independientes para evitar productos cartesianos por joins.
2. La consulta de intereses se refinó para mostrar estudiantes únicos por área y una lista de intereses tecnológicos.
3. Se agregaron métricas de confirmación de eventos con `FILTER`, `NULLIF` y `COALESCE`.
4. Se crearon tres vistas para reutilizar las relaciones y evitar repetir consultas.
5. Los comentarios y alias de columnas calculadas se hicieron explícitos para facilitar su lectura.

La propuesta es una versión inicial documentada y su revisión técnica individual; no implica retroalimentación del docente aún recibida.
