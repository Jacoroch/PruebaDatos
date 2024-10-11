# Usa la imagen oficial de PostgreSQL
FROM postgres:14

# Establece una contraseña para el usuario 'postgres'
ENV POSTGRES_PASSWORD=contrasenaPostgres

# Crea una base de datos inicial
ENV POSTGRES_DB=prueba_datos

# Copia los scripts de inicialización al contenedor
COPY ./init.sql /docker-entrypoint-initdb.d/
COPY ./consultas.sql /docker-entrypoint-initdb.d/