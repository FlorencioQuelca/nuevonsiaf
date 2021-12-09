## Api Doc - Alamacenes/activos
### Proyecto almacenes/activos
Documentación necesaria para utilizar los servicios de activos - almacenes.

# Activos
## Activo - Búsqueda de activos por usuario

Obtener los activos asignados a un usuario mediante el `CI`.

**Método** : `GET`

```
/api/v2/activos/usuario/:ci
```
Ejemplo uso:
```
curl -X GET \
  http://localhost:3000/api/v2/activos/usuario/123456 \
  -H 'Authorization: JWT token' \
  -H 'Content-Type: application/json'
```
Parámetros de entrada:

Campo | Tipo | Descripción
--- | --- | ---
**ci** | `string` | *Cédula de identidad del usuario del que se quiere obtener los activos.*

Seccess 200:

Campo | Tipo | Descripción
--- | --- | ---
**id** | `integer` | *Número único asignado al usuario en la base de datos.*
**description** | `string` | *Detalle del activo.*
**barcode** | `string` | *Código numérico único asignado al activo en la institución.*
**observation** | `string` | *Observaciones hechas al activo.*
**observaciones** | `string` | *Observaciones hechas al activo.*
**precio** | `string` | *Precio por tema de adquisición del activo.*
**detalle** | `string` | *Detalle específico del activo.*
**color** | `string` | *Color general del activo.*
**marca** | `string` | *Marca del activo.*
**modelo** | `string` | *Modelo del activo.*
**ci** | `string` | *Cédula de identidad del usuario que tiene asignado el activo.*

Error 5xx:

Campo | Descripción
--- | ---
**InternalServerError** | *Se efectuará cuando haya ocurrido un error interno al procesar la petición.*

Ejemplo de respuesta:
```
HTTP/1.1 500 internal_server_error
  {
    "finalizado": false,
    "mensaje": 'Ocurrio un error desconocido, contactese con el administrador del sistema.'
  }
```

## Activo - Búsqueda de activos por código de barras y/o descripción

Buscar activos por su `codigo` y/o `descripcion`.

**Método** : `GET`

```
/api/v2/activos/buscar
```
Ejemplo uso:
```
curl -X GET \
  'http://localhost:3000/api/v2/activos/buscar?codigo=0001&descripcion=descrip' \
  -H 'Authorization: JWT token' \
  -H 'Content-Type: application/json'
```
Parámetros de entrada:

*Al menos uno de los parámetros de entrada deben ser proporcionados para efectuarse la búsqueda.*

Campo | Tipo | Descripción
--- | --- | ---
**codigo** | `string` | *Código asignado al activo y adherido al mismo en un lugar visible..*
**descripcion** | `string` | *Nombre o descripción del activo con el cual fue registrado en la base de datos.*

Seccess 200:

Campo | Tipo | Descripción
--- | --- | ---
**id** | `integer` | *Número único asignado al usuario en la base de datos.*
**description** | `string` | *Detalle del activo.*
**barcode** | `string` | *Código numérico único asignado al activo en la institución.*
**observation** | `string` | *Observaciones hechas al activo.*
**observaciones** | `string` | *Observaciones hechas al activo.*
**precio** | `string` | *Precio por tema de adquisición del activo.*
**detalle** | `string` | *Detalle específico del activo.*
**color** | `string` | *Color general del activo.*
**marca** | `string` | *Marca del activo.*
**modelo** | `string` | *Modelo del activo.*
**ci** | `string` | *Cédula de identidad del usuario que tiene asignado el activo.*

Respuesta Errores

Error | Clave | Descripción
--- | --- | ---
400 | **BadRequest** | *Se efectuará cuando no se haya proporcinado ningún parametro de búsqueda.*
500 | **InternalServerError** | *Se efectuará cuando haya ocurrido un error interno al procesar la petición.*

Ejemplo de respuesta:
```
HTTP/1.1 400 bad_request
  {
    "finalizado": false,
    "mensaje": 'Ningun parametro de busqueda proporcionado.'
  }
```
## Activo - Obtener auxiliares

Obtiene nombres auxiliares.

**Método** : `GET`

```
/api/v2/activos/auxiliares
```
Ejemplo uso:
```
curl -X GET \
  'http://localhost:3000/api/v2/activos/auxiliares' \
  -H 'Authorization: JWT token' \
  -H 'Content-Type: application/json'
```
Parámetros de entrada:

*No cuenta con parámetros de entrada.*

Seccess 200:

Campo | Tipo | Descripción
--- | --- | ---
**id** | `integer` | *Identificador único del auxiliar en la base de datos.*
**code** | `integer` | *Código del auxiliar.*
**name** | `string` | *Nombre del auxiliar.*
**account_id** | `integer` | *Identificador único de la cuenta relacionada al auxiliar.*
**created_at** | `string` | *Fecha de creación del auxiliar.*
**updated_at** | `string` | *Fecha de última actualización del auxiliar.*
**status** | `string` | *Estado del auxiliar.*

Error 5xx:

Campo | Descripción
--- | ---
**InternalServerError** | *Se efectuará cuando haya ocurrido un error interno al procesar la petición.*

Ejemplo de respuesta:
```
HTTP/1.1 500 internal_server_error
  {
    "finalizado": false,
    "mensaje": 'Ocurrio un error desconocido, contactese con el administrador del sistema.'
  }
```
## Activo - Obtener ubicaciones

Obtiene las ubicaciones donde se puede asignar los activos.

**Método** : `GET`

```
/api/v2/activos/ubicaciones
```
Ejemplo uso:
```
curl -X GET \
  'http://localhost:3000/api/v2/activos/ubicaciones' \
  -H 'Authorization: JWT token' \
  -H 'Content-Type: application/json'
```
Parámetros de entrada:

*No cuenta con parámetros de entrada.*

Seccess 200:

Campo | Tipo | Descripción
--- | --- | ---
**id** | `integer` | *Código único asignado en la base de datos para este registro.*
**abreviacion** | `string` | *Abreviación / Sigla que identifica la ubicación.*
**descripcion** | `string` | *Descripción sobre la ubicación.*
**created_at** | `string` | *Fecha de creación del registro en la base de datos.*
**updated_at** | `string` | *Fecha de última actualización del registro.*

Error 5xx:

Campo | Descripción
--- | ---
**InternalServerError** | *Se efectuará cuando haya ocurrido un error interno al procesar la petición.*

Ejemplo de respuesta:
```
HTTP/1.1 500 internal_server_error
  {
    "finalizado": false,
    "mensaje": 'Ocurrio un error desconocido, contactese con el administrador del sistema.'
  }
```
## Activo - Obtener estados

Obtiene las estados con los que se puede asignar a los activos.

**Método** : `GET`

```
/api/v2/activos/estados
```
Ejemplo uso:
```
curl -X GET \
  'http://localhost:3000/api/v2/activos/estados' \
  -H 'Authorization: JWT token' \
  -H 'Content-Type: application/json'
```
Parámetros de entrada:

*No cuenta con parámetros de entrada.*

Seccess 200:

Campo | Tipo | Descripción
--- | --- | ---
**Bueno** | `string` | *Código asignado para definir un estado bueno.*
**Regular** | `string` | *Código asignado para definir un estado regular.*
**Malo** | `string` | *Código asignado para definir un estado malo.*

Error 5xx:

Campo | Descripción
--- | ---
**InternalServerError** | *Se efectuará cuando haya ocurrido un error interno al procesar la petición.*

Ejemplo de respuesta:
```
HTTP/1.1 500 internal_server_error
  {
    "finalizado": false,
    "mensaje": 'Ocurrio un error desconocido, contactese con el administrador del sistema.'
  }
```
## Activo - Asignación de activos

Asignar activos a un usuario en específico.

**Método** : `POST`

```
/api/v2/activos/asignacion
```
Ejemplo uso:
```
curl -X POST \
  'http://localhost:3000/api/v2/activos/asignacion' \
  -H 'Authorization: JWT token' \
  -H 'Content-Type: application/json' \
  -d '{
  "asset_ids": ["1351"],
  "user_ci": "1234561",
  "admin_ci": "1234562",
  "estado_usr_nuevo": false,
  "solicitante": {
  	"nombres": "Juan",
      "apellidos": "Espinoza",
      "numero_documento": "123456",
      "email": "jua@agetic.gob.bo",
      "cargo": "Profesional",
      "unidad": "Unidad de Innovación Investigación y Desarrollo"
  }
}'
```
Parámetros de entrada:

Campo | Tipo | Estado | Descripción
--- | --- | ---
**asset_ids** | `array:int` | `obligatorio` | *Arreglo unidimensional de valores enteros que representan el 'id' de los activos a asignar.*
**user_ci** | `string` | *opcional* | *Cédula de identidad del usuario a quien se le asignará los activos. Si se desea crear un nuevo usuario este campo debe tener un valor `null`*
**admin_ci** | `string` | `obligatorio` | *Cédula del usuario con un cargo de administrador que efectúa la asignación de activos.*
**estado_usr_nuevo** | `boolean` | `obligatorio` | *Valor booleano que indica si se quiere crear un nuevo usuario `true` caso contrario `false`.*
**solicitante** | `object` | *obligatorio* | *Objeto que contiene la información del beneficiario o usuario a quien se asignara el activo*
**solicitante.nombres** | `string` | *obligatorio* | *Nombre del usuario.*
**solicitante.apellidos** | `string` | *obligatorio* | *Apellidos del usuario.*
**solicitante.numero_documento** | `string` | *obligatorio* | *Cédula de identidad del nuevo usuario.*
**solicitante.email** | `string` | *obligatorio* | *Email del usuario.*
**solicitante.cargo** | `string` | *obligatorio* | *Cargo que tiene el usuario en la institución.*
**solicitante.unidad** | `string` | *obligatorio* | *Unidad a la que pertenece el usuario en la institución.*

Seccess 200:

Campo | Tipo | Descripción
--- | --- | ---
**finalizado** | `boolean` | *Estado que indica la finalización correcta del proceso con los resultados esperados.*
**mensaje** | `string` | *Mensaje correspondiente a la respuesta.*
**pdf** | `string` | *Ruta donde se generó el pdf para imprimir y ser firmado para dar conformidad*

Respuesta Errores

Error | Clave | Descripción
--- | --- | ---
400 | **BadRequest** | *Se efectuará cuando los activos no estén disponibles y/o asignados a un administrador.*
400 | **BadRequest** | *Se efectuará cuando los activos no cuenten con nota de ingreso en el sistema.*
400 | **BadRequest** | *Se efectuará cuando los datos del administrador no sean proporcionados.*
400 | **BadRequest** | *Se efectuará cuando se pretenda crear un nuevo usuario y la unidad especificada no se encuentre registrada en la base de datos.*
400 | **BadRequest** | *Se efectuará cuando no se haya proporcinado ningún dato de usuario.*
401 | **Unauthorized** | *Se efectuará cuando la petición realize alguien diferente a un administrador.*
404 | **NotFound** | *Se efectuará cuando el usuario a quien se pretende asignarle activos no se encuentre registrado en la base de datos.*
500 | **InternalServerError** | *Se efectuará cuando haya ocurrido un error interno al procesar la petición.*
500 | **InternalServerError** | *Se efectuará cuando haya ocurrido un error interno al procesar guardar un usuario nuevo en el sistema.*
500 | **InternalServerError** | *Se efectuará cuando haya ocurrido un error interno al procesar la asignación de los activos.*

Ejemplo de respuesta:
```
HTTP/1.1 400 bad_request
  {
    "finalizado": false,
    "mensaje": 'Verifique que todos los activos esten disponibles y/o asignados a un administrador.',
    "data":  [ID's PERMITIDOS] }
  }
```
## Activo - Devolución de activos

Efectuar la devolución de activos a un usuario en específico.

**Método** : `POST`

```
/api/v2/activos/devolucion
```
Ejemplo uso:
```
curl -X POST \
  'http://localhost:3000/api/v2/activos/devolucion' \
  -H 'Authorization: JWT token' \
  -H 'Content-Type: application/json' \
  -d '{
  "asset_ids": ["1351"],
  "user_ci": "1234561",
  "admin_ci": "1234562"
}'
```
Parámetros de entrada:

Campo | Tipo | Descripción
--- | --- | ---
**asset_ids** | `array:int` | *Arreglo unidimensional de valores enteros que representan el 'id' de los activos a regresar.*
**user_ci** | `string` | *Cédula de identidad del usuario a quien devuelve los activos*
**admin_ci** | `string` | *Cédula del usuario con un cargo de administrado que efectúa la devolución de activos.*

Seccess 200:

Campo | Tipo | Descripción
--- | --- | ---
**finalizado** | `boolean` | *Estado que indica la finalización correcta del proceso con los resultados esperados.*
**mensaje** | `string` | *Mensaje correspondiente a la respuesta.*
**pdf** | `string` | *Ruta donde se generó el pdf para imprimir y ser firmado para dar conformidad*

Respuesta Errores

Error | Clave | Descripción
--- | --- | ---
400 | **BadRequest** | *Se efectuará cuando no todos los activos pertenezcan a la misma persona.*
400 | **BadRequest** | *Se efectuará cuando los datos del administrador no sean proporcionados.*
400 | **BadRequest** | *Se efectuará cuando no se haya proporcionado datos del usuario.*
401 | **Unauthorized** | *Se efectuará cuando la petición la realize alguien diferente a un administrador.*
500 | **InternalServerError** | *Se efectuará cuando haya ocurrido un error interno al procesar la petición.*

Ejemplo de respuesta:
```
HTTP/1.1 400 bad_request
  {
    "finalizado": false,
    "mensaje": 'Verifique que todos los activos pertenezcan a la misma persona.',
    "data":  [ID's PERMITIDOS]
  }
```
## Activo - Ingresar activos

Realizar la nota de ingreso de diferentes activos.

**Método** : `POST`

```
/api/v2/activos/ingresar
```
Ejemplo uso:
```
curl -X POST \
  'http://localhost:3000/api/v2/activos/ingresar' \
  -H 'Authorization: JWT token' \
  -H 'Content-Type: application/json' \
  -d '{
    "nota_id": null,
    "nt_admin_ci": "4914412 LP",
    "nt_supplier": "2",
    "nt_factura_nro": "1",
    "nt_factura_aut": "1",
    "nt_factura_fec": "27/12/2019",
    "nt_numero": "1",
    "nt_fecha": "30/12/2019",
    "nt_c31_num": "1",
    "nt_c31_fec": "13/12/2019",
    "nt_tot": "600",
    "nt_obs": "obs",
    "nt_assets": [
      "1350"
    ]
  }'
```
Parámetros de entrada:

Campo | Tipo | Estado | Descripción
--- | --- | --- | ---
**nota_id** | `string` | *opcional* | *null*
**nt_admin_ci** | `string` | `obligatorio` | *Cédula de identidad del administrador que realizará la petición.*
**nt_supplier** | `string` | `obligatorio` | *Id del proveedor en la base de datos.*
**nt_factura_nro** | `string` | `obligatorio` | *Número de la factura.*
**nt_factura_aut** | `string` | `obligatorio` | *Número de autorización de la factura.*
**nt_factura_fec** | `string` | `obligatorio` | *Fecha de la factura.*
**nt_numero** | `string` | `obligatorio` | *Número de la nota de entrega.*
**nt_fecha** | `string` | `obligatorio` | *Fecha de la nota de entrega.*
**nt_c31_num** | `string` | `obligatorio` | *Número C31.*
**nt_c31_fec** | `string` | `obligatorio` | *Fecha C31.*
**nt_tot** | `string` | `obligatorio` | *El precio total de todos los activos que ingresarán con la nota de ingreso.*
**nt_obs** | `string` | *opcional* | *Observación sobre la nota de entrega en caso de ser necesaria, de otro modo mantener con valor `null`.*
**nt_assets** | `array:int` | `obligatorio` | *Arreglo unidimensional de valores enteros que representan el 'id' de los activos que ingresaran con la nota de ingreso.*

Seccess 200:

Campo | Tipo | Descripción
--- | --- | ---
**finalizado** | `boolean` | *Estado que indica la finalización correcta del proceso con los resultados esperados.*
**mensaje** | `string` | *Mensaje correspondiente a la respuesta.*

Respuesta Errores

Error | Clave | Descripción
--- | --- | ---
400 | **BadRequest** | *Se efectuará cuando haya un inconveniente con la fecha proporcionada de la factura.*
400 | **BadRequest** | *Se efectuará cuando haya problemas con la información en la nota de ingreso.*
400 | **BadRequest** | *Se efectuará cuando uno o mas activos agregados a la nota de ingreso ya cuenten con una nota de ingreso en el sistema.*
500 | **InternalServerError** | *Se efectuará cuando ocurra un problema al intentar guardar los datos de la nota de ingreso.*
500 | **InternalServerError** | *Se efectuará cuando haya ocurrido un error interno al procesar la petición.*

Ejemplo de respuesta:
```
HTTP/1.1 400 bad_request
  {
    "finalizado": false,
    "mensaje": "Se está introduciendo un ingreso con fecha anterior al '29/12/2019', la numeración asignada será la siguiente: 15-D. Es necesario especificar una observación."
  }
```
`Nota:` *En el ejemplo que se muestra arriba se debe reenviar toda la información mas una observación, de esa manera se subsanara la advertencia.*
