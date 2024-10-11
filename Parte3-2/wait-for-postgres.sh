# Esperar a que PostgreSQL esté listo antes de continuar

echo "Esperando a que PostgreSQL esté listo..."

while ! pg_isready -h $POSTGRES_HOST -p 5432 -U $POSTGRES_USER; do
  sleep 1
done

echo "PostgreSQL está listo. Ejecutando el script Python..."
exec "$@"
