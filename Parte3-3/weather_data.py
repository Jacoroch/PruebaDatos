import requests
import psycopg2
import logging
import json
from datetime import datetime

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
        response.raise_for_status()  # Genera una excepción para códigos de estado HTTP 4xx/5xx
        return response.json()
    except requests.RequestException as e:
        logging.error(f"Error al obtener el clima de {ciudad}: {e}")
        return None

# Función para almacenar los datos en PostgreSQL
def almacenar_clima_en_bd(ciudad, datos):
    try:
        conn = conectar_bd()
        cur = conn.cursor()

        query = """
        INSERT INTO weather_data (city, description, temperature, humidity, wind_speed)
        VALUES (%s, %s, %s, %s, %s)
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
        logging.info(f"Datos de {ciudad} almacenados correctamente.")
    except (Exception, psycopg2.DatabaseError) as error:
        logging.error(f"Error al almacenar los datos en PostgreSQL: {error}")

# Función principal
def main():
    for ciudad in CITIES:
        datos_clima = obtener_clima(ciudad)
        if datos_clima:
            almacenar_clima_en_bd(ciudad, datos_clima)

if __name__ == '__main__':
    main()
