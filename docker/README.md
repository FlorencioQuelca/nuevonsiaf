# Levantar el sistema con Docker

## Requisitos

Para levantar este sistema se necesita tener instalado [Docker](https://www.docker.com/)

Archivo de configuración de la aplicación:

```sh
cp config/secrets.yml.sample config/secrets.yml
```

Archivo de configuración de base de datos:

```sh
cp config/database.yml.sample config/database.yml
```

Modificar el archivo de variables de entorno para la configuración del sistema:

```sh
cp docker/runtime.env.sample docker/runtime.env
```

Para una configuración personalizada modificar las variables necesarias. Cada
línea no comentada del archivo `.env` representa una variable de entorno que
es adoptada por el contenedor al momento del despliegue.

En entornos de producción es muy importante modificar las credenciales de
administrador y de MySQL. También es importante modificar el valor de la clave
secreta con una cadena aleatoria.

## Despliegue en producción

Crear la imagen a partir del Dockerfile:

```sh
docker build -t nsiaf:1.0.0 -f docker/Dockerfile .
```

Despliegue en producción con Docker Swarm:

```sh
docker stack deploy -c docker/docker-stack.yml nsiaf
```

Ingresar a `localhost:3000` para ver la instalación.
