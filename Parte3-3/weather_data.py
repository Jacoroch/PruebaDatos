import requests
import psycopg2
import logging
import json
import csv
from datetime import datetime
import os

# Configurar logging
logging.basicConfig(filename='weather_data.log', level=logging.INFO,
                    format='%(asctime)s %(levelname)s:%(message)s')

# Cargar configuración desde config.json
with open('config.json') as config_file:
    config = json.load(config_file)

API_KEY = config['api_key']
CITIES = config['cities']
POSTGRES_CONFIG = config['postgres']

# Función para conectarse a PostgreSQL
def conectar_bd():
    conn = psycopg2.connect(
        host=POSTGRES_CONFIG['host'],
        database=POSTGRES_CONFIG['database'],
        user=POSTGRES_CONFIG['user'],
        password=POSTGRES_CONFIG['password']
    )
    return conn

# Función para obtener datos del clima
def obtener_clima(ciudad):
    try:
        url = f"http://api.openweathermap.org/data/2.5/weather?q={ciudad}&appid={API_KEY}&units=metric"
        response = requests.get(url)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        logging.error(f"Error al obtener el clima de {ciudad}: {e}")
        return None

# Función para almacenar o actualizar los datos en PostgreSQL
def almacenar_clima_en_bd(ciudad, datos):
    try:
        conn = conectar_bd()
        cur = conn.cursor()

        query = """
        INSERT INTO weather_data (city, description, temperature, humidity, wind_speed, date)
        VALUES (%s, %s, %s, %s, %s, CURRENT_TIMESTAMP)
        ON CONFLICT (city)
        DO UPDATE SET description = EXCLUDED.description,
                      temperature = EXCLUDED.temperature,
                      humidity = EXCLUDED.humidity,
                      wind_speed = EXCLUDED.wind_speed,
                      date = EXCLUDED.date;
        """
        cur.execute(query, (
            ciudad,
            datos['weather'][0]['description'],
            datos['main']['temp'],
            datos['main']['humidity'],
            datos['wind']['speed']
        ))
        
        conn.commit()
        cur.close()
        conn.close()
        logging.info(f"Datos de {ciudad} almacenados o actualizados correctamente.")
    except (Exception, psycopg2.DatabaseError) as error:
        logging.error(f"Error al almacenar o actualizar los datos en PostgreSQL: {error}")

# Función para generar o actualizar un archivo CSV con nuevas filas
def generar_csv(datos):
    fecha_actual = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    nombre_csv = "weather_data.csv"  # El archivo se mantendrá el mismo

    # Verifica si el archivo ya existe; si no, agrega los encabezados
    escribir_encabezados = not os.path.exists(nombre_csv)

    with open(nombre_csv, mode='a', newline='') as archivo_csv:
        campos = ['city', 'description', 'temperature', 'humidity', 'wind_speed', 'timestamp']
        escritor_csv = csv.DictWriter(archivo_csv, fieldnames=campos)
        
        # Escribe los encabezados solo si es la primera vez que se crea el archivo
        if escribir_encabezados:
            escritor_csv.writeheader()
        
        # Agrega nuevas filas con los datos y la fecha y hora de ejecución
        for ciudad, datos_clima in datos.items():
            escritor_csv.writerow({
                'city': ciudad,
                'description': datos_clima['weather'][0]['description'],
                'temperature': datos_clima['main']['temp'],
                'humidity': datos_clima['main']['humidity'],
                'wind_speed': datos_clima['wind']['speed'],
                'timestamp': fecha_actual  # Agrega la fecha y hora actuales
            })
    
    logging.info(f"Datos añadidos al archivo CSV: {nombre_csv}")
    return nombre_csv

# Función principal
def main():
    datos_ciudades = {}
    for ciudad in CITIES:
        datos_clima = obtener_clima(ciudad)
        if datos_clima:
            almacenar_clima_en_bd(ciudad, datos_clima)
            datos_ciudades[ciudad] = datos_clima
    
    if datos_ciudades:
        generar_csv(datos_ciudades)

if __name__ == '__main__':
    main()
