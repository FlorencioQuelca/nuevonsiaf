# Documentación API REST - Almacenes

## Estado - Estado de la API REST

**`GET`**
```
/api/v2/estado
```
**Success 200**

| Campo            | Tipo                 | Descripción                                                  |
| :--------------- | :------------------- | :----------------------------------------------------------- |
| estado           | String               | Muestra un mensaje del estado de la aplicación               |

Ejemplo de respuesta:
```
HTTP/1.1 200 OK
{
    "estado": "El servicio de almacenes y activos se encuentra disponible."
}
```

## Artículos - Método para buscar y obtener items/artículos

**`GET`**
```
/api/v2/almacenes/articulos
```
Parámetros

| Campo            | Tipo                 | Descripción                                                  |
| :--------------- | :------------------- | :----------------------------------------------------------- |
| descripcion      | String               | Nombre o descripción del item o articulo                     |
| todos            | Integer              | Parametro opcional, bandera que permite considerar o no el stock de los items. total = 1 (No se considerar el stock), todos = 0 o si se omite el parametro (solo devuelve los items con stock mayo a cero)|

Ejemplo de consumo con curl:
```
curl -X GET \
     'http://127.0.0.1:8081/api/v2/almacenes/articulos?descripcion=boligrafo&todos=1' \
     -H 'Authorization: Bearer <token-de-acceso>'
```

**Success 200**

| Campo                 | Tipo                 | Descripción                                                  |
| :-------------------- | :------------------- | :----------------------------------------------------------- |
| finalizado            | String               | Estado de la consulta                                        |
| mensaje               | String               | Descripción del proceso de la consulta                       |
| items                 | Array                |                                                              |
| &nbsp;id              | Integer              | Id del item o subarticulo                                    |
| &nbsp;codigo          | Integer              | Código del item o subarticulo                                |
| &nbsp;descripcion     | String               | Descripción de item o subarticulo                            |
| &nbsp;unidad          | String               | Unidad del ítem o subarticulo                                |


Ejemplo de respuesta:
```
{
    "finalizado": true,
    "mensaje": "Consulta obtenida satisfactoriamente.",
    "items": [
        {
            "id": 14,
            "codigo": 3950012,
            "descripcion": "BOLIGRAFOS AZULES",
            "unidad": "Pieza"
        },
        {
            "id": 15,
            "codigo": 3950013,
            "descripcion": "BOLIGRAFOS NEGROS",
            "unidad": "Pieza"
        }
    ]
}
```

## Crear Solicitud - Método para crear una solicitud

**`POST`**
```
/api/v2/almacenes/solicitud
```
Parámetros

| Campo                  | Tipo         | Descripción                                                  |
| :--------------------- | :------------| :----------------------------------------------------------- |
| id                     | Integer      | Id del documento del sistema de plantillas                   |
| solicitante            | Object       |                                                              |
| &nbsp;nombres          | String       | Nombre del solicitante                                       |
| &nbsp;apellidos        | String       | Apellidos del solicitante                                    |
| &nbsp;numero_documento | String       | Cédula de identidad del solicitante                          |
| &nbsp;email            | String       | Email del solicitante                                        |
| &nbsp;cargo            | String       | Cargo del solicitante                                        |
| &nbsp;unidad           | String       | Unidad a la que pertenece el solicitante                     |
| responsable            | Object       |                                                              |
| &nbsp;nombres          | String       | Nombre del responsable                                       |
| &nbsp;apellidos        | String       | Apellidos del responsable                                    |
| &nbsp;numero_documento | String       | Cédula de identidad del responsable                          |
| &nbsp;email            | String       | Email del responsable                                        |
| &nbsp;cargo            | String       | Cargo del responsable                                        |
| &nbsp;unidad           | String       | Unidad a la que pertenece el responsable                     |
| items                  | Array        |                                                              |
| &nbsp;id               | Integer      | Id del item o subarticulo solicitado                         |
| &nbsp;cantidad         | Integer      | Cantidad solicitada del ítem o subarticulo                   |

Ejemplo de consumo con curl:
```
curl -X POST \
     'http://127.0.0.1:8081/api/v2/almacenes/solicitud' \
     -H 'Authorization: Bearer <token-de-acceso>' \
     -d '{
            "id": 3,
            "solicitante":{
                "nombres": "Jose",
                "apellidos": "Perez Perez",
                "numero_documento": "2334567",
                "email": "jperez@agetic.gob.bo",
                "cargo": "Profesional en Desarrollo en Sistemas Web",
                "unidad": "Unidad de Innovación Investigación y Desarrollo"
            },
            "responsable": {
                "nombres": "Claudia",
                "apellidos": "Segurondo Muiba ",
                "numero_documento": "5672345",
                "email": "csegurondo@agetic.gob.bo",
                "cargo": "Responsable de Almacenes",
                "unidad": "Unidad de Administración"
            },
            "items": [
                {
                    "id": 14,
                    "cantidad": 26
                },
                {
                    "id": 15,
                    "cantidad": 7
                },
                {
                    "id": 361,
                    "cantidad": 2
                }
            ]
        
        }'
```

**Success 200**

| Campo            | Tipo                 | Descripción                                                  |
| :--------------- | :------------------- | :----------------------------------------------------------- |
| finalizado       | String               | Estado de la consulta                                        |
| mensaje          | String               | Descripción del proceso de la consulta                       |
| id               | Integer              | Id de la nueva solicitud creada                              |


Ejemplo de respuesta:
```
{
    "finalizado": true,
    "mensaje": "Solicitud almacenada satisfactoriamente.",
    "id": 1841
}
```

## Actualizar Solicitud - Método para actualizar datos de una solicitud

**`PATCH`**
```
/api/v2/almacenes/solicitud
```
Parámetros

| Campo                  | Tipo         | Descripción                                                  |
| :--------------------- | :------------| :----------------------------------------------------------- |
| id                     | Integer      | Id de la solicitud a actualizar                              |
| cite_sms               | String       | Cite del documento SMS de plantillas                         |
| cite_ems               | String       | Cite del documento EMS de plantillas                         |


Ejemplo de consumo con curl:
```
curl -X PATCH \
     'http://127.0.0.1:8081/api/v2/almacenes/solicitud' \
     -H 'Authorization: Bearer <token-de-acceso>' \
    -d '{
        "id": 1830,
        "cite_sms": "AGETIC-UIID/SMS/0293/2019",
        "cite_ems": "AGETIC-UIID/EMS/0193/2019"
    }'
```

**Success 200**

| Campo            | Tipo                 | Descripción                                                  |
| :--------------- | :------------------- | :----------------------------------------------------------- |
| finalizado       | String               | Estado de la consulta                                        |
| mensaje          | String               | Descripción del proceso de la consulta                       |


Ejemplo de respuesta:
```
{
    "finalizado": true,
    "mensaje": "Solicitud actualizada satisfactoriamente."
}
```

## Obtener Solicitud - Método para obtener datos de una solicitud

**`GET`**
```
/api/v2/almacenes/solicitud
```
Parámetros

| Campo                  | Tipo         | Descripción                                                  |
| :--------------------- | :------------| :----------------------------------------------------------- |
| id                     | Integer      | Id de la solicitud                                           |


Ejemplo de consumo con curl:
```
curl -X GET \
     'http://127.0.0.1:8081/api/v2/almacenes/solicitud?id=10' \
     -H 'Authorization: Bearer <token-de-acceso>'
```

**Success 200**

| Campo            | Tipo                 | Descripción                                                         |
| :-------------------------      | :------------| :----------------------------------------------------------- |
| finalizado                      | String       | Estado de la consulta                                        |
| mensaje                         | String       | Descripción del proceso de la consulta                       |
| datos                           | Object       |                                                              |
| &nbsp;cabecera                  | Object       |                                                              |
| &nbsp;&nbsp;nro_solicitud       | Integer      | Número de la solicitud                                       |
| &nbsp;&nbsp;fecha_entrega       | String       | Fecha de entrega de la solicitud                             |
| &nbsp;&nbsp;entregado_por       | String       | Nombre de la persona que realizo la entrega de la solicitud  |
| &nbsp;items                     | Array        |                                                              |
| &nbsp;&nbsp;id                  | Integer      | Id del item o subarticulo                                    |
| &nbsp;&nbsp;codigo              | Integer      | Código del item o subarticulo                                |
| &nbsp;&nbsp;descripcion         | String       | Descripción del item o subarticulo                           |
| &nbsp;&nbsp;unidad              | String       | Unidad de medida del item o subarticulo                      |
| &nbsp;&nbsp;cantidad_solicitada | Integer      | Cantidad solicitada del item o subarticulo                   |
| &nbsp;&nbsp;cantidad_entregada  | Integer      | Cantidad aprobada y entregada del item o subarticulo         |


Ejemplo de respuesta:
```
{
    "finalizado": true,
    "datos": {
        "cabecera": {
            "nro_solicitud": 10,
            "fecha_entrega": "04/01/2016",
            "entregado_por": "CLAUDIA SEGURONDO MUIBA"
        },
        "items": [
            {
                "id": 35,
                "codigo": 3950033,
                "descripcion": "PERFORADORAS GRANDES NOVUS 200 HJAS",
                "unidad": "PIEZAS",
                "cantidad_solicitada": 2,
                "cantidad_entregada": 2
            },
            {
                "id": 36,
                "codigo": 3950034,
                "descripcion": "ENGRAPADORAS GRANDES 210  HJAS",
                "unidad": "PIEZAS",
                "cantidad_solicitada": 10,
                "cantidad_entregada": 5
            },
            {
                "id": 83,
                "codigo": 3950044,
                "descripcion": "FOLDER CARTUL. OF. COLOR  AMARILLO",
                "unidad": "PIEZA",
                "cantidad_solicitada": 100,
                "cantidad_entregada": 90
            },
            {
                "id": 3,
                "codigo": 395001,
                "descripcion": "FASTENERS METALFILE ( 50 UNIDADES C/CAJA)",
                "unidad": "CAJA (50 UNID.)",
                "cantidad_solicitada": 2,
                "cantidad_entregada": 2
            }
        ]
    },
    "mensaje": "Solicitud procesada satisfactoriamente."
}
```


## Proveedores - Método para buscar y obtener proveedores

**`GET`**
```
/api/v2/almacenes/proveedores
```
Parámetros

| Campo            | Tipo                 | Descripción                                                  |
| :--------------- | :------------------- | :----------------------------------------------------------- |
| descripcion      | String               | Nombre o descripción del proveedor                           |

Ejemplo de consumo con curl:
```
curl -X GET \
     'http://127.0.0.1:8081/api/v2/almacenes/proveedores?descripcion=full' \
     -H 'Authorization: Bearer <token-de-acceso>'
```

**Success 200**

| Campo                 | Tipo                 | Descripción                                                  |
| :-------------------- | :------------------- | :----------------------------------------------------------- |
| finalizado            | String               | Estado de la consulta                                        |
| mensaje               | String               | Descripción del proceso de la consulta                       |
| datos                 | Object               |                                                              |
| &nbsp;id              | Integer              | Id del proveedor                                             |
| &nbsp;nit             | String               | Nit del proveedor                                            |
| &nbsp;nombre          | String               | Nombre o descripción del proveedor                           |


Ejemplo de respuesta:
```
{
    "finalizado": true,
    "mensaje": "Consulta obtenida satisfactoriamente.",
    "datos": [
        {
            "id": 2,
            "nit": "207782025",
            "nombre": "FULL OFFICE"
        },
        {
            "id": 3,
            "nit": "43432432432",
            "nombre": "FULL COLOR"
        }
    ]
}
```

## Crear Nota de ingreso - Método para crear una nueva nota de ingreso/reingreso

**`POST`**
```
/api/v2/almacenes/ingreso
```
Parámetros

| Campo                     | Tipo         | Descripción                                                  |
| :---------------------    | :------------| :----------------------------------------------------------- |
| id                        | Integer      | Id del documento del sistema de plantillas                   |
| reingreso                 | Integer      | Determina si es un reingreso = 1, o un nuevo ingreso = 0     |
| responsable               | Object       |                                                              |
| &nbsp;nombres             | String       | Nombre del responsable                                       |
| &nbsp;apellidos           | String       | Apellidos del responsable                                    |
| &nbsp;numero_documento    | String       | Cédula de identidad del responsable                          |
| &nbsp;email               | String       | Email del responsable                                        |
| &nbsp;cargo               | String       | Cargo del responsable                                        |
| &nbsp;unidad              | String       | Unidad a la que pertenece el responsable                     |
| cabecera                  | Object       |                                                              |
| &nbsp;proveedor           | Integer      | Id del proveedor                                             |
| &nbsp;c31                 | String       | c31                                                          |
| &nbsp;c31_fecha           | String       | Fecha del c31                                                |
| &nbsp;nota_entrega_numero | Integer      | Número de la nota de entrega                                 |
| &nbsp;nota_entrega_fecha  | String       | Fecha de la nota de entrega                                  |
| &nbsp;factura_numero      | String       | Número de factura                                            |
| &nbsp;factura_autorizacion| String       | Número de autorización de la factura                         |
| &nbsp;factura_fecha       | String       | Fecha de la factura                                          |
| detalle                   | Object       |                                                              |
| &nbsp;items               | Array        |                                                              |
| &nbsp;&nbsp;id            | Integer      | Id del item o subarticulo                                    |
| &nbsp;&nbsp;cantidad      | Float        | Cantidad de ingreso del item o subarticulo                   |
| &nbsp;&nbsp;precio        | Float        | Precio del item o subarticulo                                |
| &nbsp;&nbsp;total         | Float        | total = Precio * Cantidad(por cada item)                     |
| &nbsp;subtotal            | Float        | Sumatoria de los totales de los items                        |
| &nbsp;descuento           | Float        | Descuento                                                    |
| &nbsp;total               | Float        | Subtotal - Descuento                                         |

Ejemplo de consumo con curl:
```
curl -X POST \
     'http://127.0.0.1:8081/api/v2/almacenes/ingreso' \
     -H 'Authorization: Bearer <token-de-acceso>' \
    -d '{
        "id": 18,
        "reingreso": 0,
        "responsable": {
            "nombres": "Claudia",
            "apellidos": "Segurondo ",
            "numero_documento": "5672345",
            "email": "csegurondo@agetic.gob.bo",
            "cargo": "Responsable de almacenes",
            "unidad": "Unidad de Administración"
        },
        "cabecera":{
            "proveedor": "2",
            "c31": "c1",
            "c31_fecha": "2019-10-12",
            "nota_entrega_numero": 1,
            "nota_entrega_fecha": "2019-11-06",
            "factura_numero": "0034342",
            "factura_autorizacion": "655745747",
            "factura_fecha": "2019-12-15"
        },
        "detalle": {
            "items": [
                {
                    "id": 113,
                    "cantidad": 20,
                    "precio": "12.678",
                    "total": 253.56
                },
                {
                    "id": 366,
                    "cantidad": 9.56,
                    "precio": 12.56756,
                    "total": 120.15
                }
            ],
            "subtotal": 373.71,
            "descuento": 256.576,
            "total": 117.13
        }
    
    }'
```

**Success 200**

| Campo            | Tipo                 | Descripción                                                  |
| :--------------- | :------------------- | :----------------------------------------------------------- |
| finalizado       | String               | Estado de la consulta                                        |
| mensaje          | String               | Descripción del proceso de la consulta                       |
| id               | Integer              | Id de la nueva nota de ingreso creada                        |


Ejemplo de respuesta:
```
{
    "finalizado": true,
    "mensaje": "Ingreso almacenado satisfactoriamente.",
    "id": 419
}
```
