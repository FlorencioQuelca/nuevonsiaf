# PRUEBAS DE CARGA NSIAF

## Requerimientos

Deberá tener instalado en su ambiente dónde ejecutará las pruebas de carga:

- python 3.8.5
- pip 20.3.3

## Instalación

1. Ejecutar el siguiente comando para la instalación de las librerias:

    ```console
        pip install -r requirements.txt
    ```

2. Copiar el archivo el archivo config.py de config.py.sample

    ```console
        cp src/config.py.sample src/config.py
    ```

3. Poner las configuraciones correspondientes dentro de src/config.py
   - HOST: El host principal donde se quieren realizar las pruebas.

## Ejecución de las pruebas - Flujo de inscripción

Para ejecutar las pruebas ejecutar los siguientes comandos:

```console
locust -f locustfile.py
```