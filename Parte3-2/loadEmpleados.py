import csv
import psycopg2
import os

# Función para conectarse a la base de datos PostgreSQL
def conectar_bd():
    conn = psycopg2.connect(
        host='postgres',            
        database='prueba_datos',      # Nombre de la base de datos
        user='postgres',              # Usuario de la base de datos
        password='contraseñaPostgres' # Contraseña de la base de datos
    )
    return conn

# Función para cargar los datos desde el CSV a la tabla empleados
def cargar_datos_empleados(ruta_csv):
    conn = conectar_bd()
    cur = conn.cursor()

    with open(ruta_csv, 'r') as f:
        reader = csv.reader(f)
        next(reader)  # Saltar la cabecera
        for row in reader:
            cur.execute(
                "INSERT INTO empleados (id_empleado, nombre, apellido, fecha_contratacion, salario, id_departamento) VALUES (%s, %s, %s, %s, %s, %s)",
                row
            )
    
    conn.commit()
    cur.close()
    conn.close()
    print(f"Datos cargados desde {ruta_csv} a la tabla empleados.")

if __name__ == '__main__':
    # Ruta del archivo CSV
    ruta_csv = 'empleados.csv'
    cargar_datos_empleados(ruta_csv)
