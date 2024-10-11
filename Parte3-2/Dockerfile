# Usar la imagen base de Python 3.12
FROM python:3.12-slim

# Instalar psycopg2-binary para conectarse a PostgreSQL
RUN pip install psycopg2-binary

# Instalar pg_isready para verificar el estado de PostgreSQL
RUN apt-get update && apt-get install -y postgresql-client

# Copiar el script de espera
COPY wait-for-postgres.sh /app/wait-for-postgres.sh
RUN chmod +x /app/wait-for-postgres.sh

# Copiar el script Python en el contenedor
COPY loadEmpleados.py /app/loadEmpleados.py

# Copiar el archivo CSV en el contenedor
COPY empleados.csv /app/empleados.csv

# Definir el directorio de trabajo
WORKDIR /app

# Ejecutar el script de espera seguido del script Python
CMD ["/app/wait-for-postgres.sh", "python3", "loadEmpleados.py"]
