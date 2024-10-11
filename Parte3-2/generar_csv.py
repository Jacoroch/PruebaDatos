import csv

# Datos para la tabla empleados
empleados = [
    [1, 'Juan', 'Pérez', '2020-01-15', 30000.00, 1],
    [2, 'María', 'González', '2019-05-20', 35000.00, 2],
    [3, 'Carlos', 'Rodríguez', '2021-03-10', 28000.00, 1],
    [4, 'Ana', 'Martínez', '2018-11-01', 40000.00, 3],
    [5, 'Luis', 'Sánchez', '2022-07-05', 32000.00, 2],
    [6, 'Elena', 'López', '2023-05-01', 33000.00, 3]
]

# Escribir los datos en un archivo CSV
def generar_csv_empleados(ruta_csv):
    with open(ruta_csv, mode='w', newline='') as file:
        writer = csv.writer(file)
        # Escribir la cabecera
        writer.writerow(['id_empleado', 'nombre', 'apellido', 'fecha_contratacion', 'salario', 'id_departamento'])
        # Escribir los datos de los empleados
        writer.writerows(empleados)

if __name__ == '__main__':
    # Generar el archivo empleados.csv
    ruta_csv = 'empleados.csv'
    generar_csv_empleados(ruta_csv)
    print(f'Archivo {ruta_csv} generado correctamente.')
