# Pasos para construir y ejecutar el proyecto en Docker

1. Construir la imagen de Docker
   docker build -t calculadora-teamqeson . 

2. Crear y ejecutar el contenedor en el puerto 8093 
   docker run -d -p 8093:80 calculadora-teamqeson

3. Acceder al proyecto en el navegador
   Abre tu navegador y ve a la dirección: http://localhost:8093