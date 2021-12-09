## Manual

### Registro de la Institución

Al iniciar sesión en el Sistema como `Super Administrador`, es requisito que se registre una Institución con los siguientes datos:

* `Código` de la Institución, debe ser la que está registrada en el sistema VSIAF (campo `ENTIDAD` de la tabla `unidadadmin.DBF`), porque es la que se utilizará para importar los archivos .DBF (obligatorio)
* `Nombre` que describa a la institución
* `Sigla` de la institución, se utiliza para generar los Códigos de Barras en el Sistema (obligatorio)

### Migración desde VSIAF

Para la migración se debe adjuntar los archivos con extensión DBF, una vez realizado dicha migración se presentara un mensaje de la cantidad de registros insertados y no insertados.

A continuación se detalla los nombres para cada migración:

1. Entidades: `unidadadmin.DBF`
2. Unidades: `OFICINA.DBF`
3. Funcionarios: `RESP.DBF`
4. Cuentas: `CODCONT.DBF`
5. Auxiliares: `auxiliar.DBF`
6. Activos: `ACTUAL.DBF`

Se debe respetar el orden descrito en la lista para que la migración sea correcta.

### Administrador de Activos

En éste paso se establecerá el usuario `Administrador de Activos` que corresponde al funcionario con cargo Encargado de Activos Fijos de la institución a partir de los usuarios importados desde el archivo `RESP.DBF`, para ello realizamos los siguiente pasos:

1. Iniciamos sesión como el usuario `Super Administrador`
2. Ingresamos al listado de usuarios: `Administración` > `Usuarios`
3. Presionamos en el botón `Nuevo Usuario`
4. En el campo `Nombre` introducir el nombre de un usuario existente y para seleccionarlo presionar `Enter`
5. Asignarle un Nombre de Usuario en el campo `Usuario`
  * Tomar en cuenta que éste campo será también la Contraseña de la cuenta.
6. Seleccionar en el campo `Rol` la opción `Administrador de Activos`
7. Para guardar los cambios presionamos en el botón `Aceptar`

### Administrador de Almacenes

Para el caso del usuario `Administrador de Almacenes` que corresponde al funcionario con cargo de Encargado de Almacenes de la institución, son los mismos pasos descritos para el usuario `Administrador de Activos`, solamente en el paso `6` (campo `Rol`) debemos seleccionar `Administrador de Almacenes`.

Actualmente los usuarios `Administrador de Activos` y `Administrador de Almacenes` corresponden a dos usuarios diferentes, el sistema no permite que un usuario pueda tener dos roles al mismo tiempo.
