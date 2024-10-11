# Proyecto: Carga de Datos a PostgreSQL usando Docker

Este proyecto configura un entorno Docker con un contenedor de PostgreSQL y un contenedor de Python que carga datos desde un archivo CSV a la base de datos PostgreSQL.

## Requisitos

Asegúrate de tener instalados los siguientes requisitos en tu sistema:

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Instalación y ejecución

Sigue los siguientes pasos para clonar el repositorio y ejecutar el entorno.

### 1. Clonar el repositorio

Primero, clona el repositorio en tu máquina local:

```bash
git clone <URL_DEL_REPOSITORIO>
```
### 2. Navegar a la carpeta del proyecto

Una vez clonado el repositorio, navega a la carpeta del proyecto:
```bash
cd <nombre_del_repositorio>/parte3-2
```
### 3. Ejecutar Docker Compose

Levanta los servicios de Docker (PostgreSQL y Python) con Docker Compose:
```bash
docker-compose up --build
```

Esto hará lo siguiente:

1. Levantará un contenedor con PostgreSQL que creará una base de datos y tablas usando el archivo init.sql.
2. Levantará un contenedor con Python que ejecutará el script loadEmpleados.py para cargar los datos desde el archivo empleados.csv a la tabla empleados de PostgreSQL.

### 4. Verificar la ejecución
Puedes verificar que todo se haya ejecutado correctamente conectándote al contenedor de PostgreSQL:
```bash
docker exec -it parte3-2-postgres-1 psql -U postgres -d prueba_datos
```
Luego, puedes listar las tablas para confirmar que se crearon:
```sql
\dt
```

Y también puedes verificar los datos cargados en la tabla empleados:
```sql
SELECT * FROM empleados;
```
### 5. Detener los contenedores
Para detener los contenedores, puedes usar:
```bash
docker-compose down
```
Esto detendrá los contenedores y eliminará los servicios, pero los datos de la base de datos se mantendrán gracias al volumen persistente.