# Instalación

## Requisitos

* Sistema Operativo: Debian Jessie
* Usuario: nsiaf
* Servidor: www.dominio.gob.bo

## Paquetes y dependencias

La instalación de paquetes en el servidor remoto

```console
sudo apt-get install -y curl checkinstall bzip2 gawk g++ gcc make \
libc6-dev patch libreadline6-dev zlib1g-dev libssl-dev libyaml-dev \
libsqlite3-dev sqlite3 autoconf libgmp-dev libgdbm-dev libncurses5-dev \
automake libtool bison pkg-config libffi-dev wget
```

Instalar [Git](http://git-scm.com/)

```console
sudo apt-get install -y git git-core
```

Instalar [ImageMagick](http://www.imagemagick.org/)

```console
sudo apt-get install -y imagemagick libmagickwand-dev
```

Instalar Vim como editor por defecto:

```console
sudo apt-get install -y vim
sudo update-alternatives --set editor /usr/bin/vim.basic
```

### wkhtmltopdf

[wkhtmltopdf](http://wkhtmltopdf.org/) permite la conversión de HTML a PDF. En
los respositorios oficiales de Debian está la versión `0.9.9` el cual no cumple
correctamente con su función, debido a que estamos utilizando funciones nuevas.
Se recomienda la versión `0.12.0` o superiores, el cual se puede descargar
manualmente desde http://wkhtmltopdf.org/downloads.html

```console
wget -c https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.3/wkhtmltox-0.12.3_linux-generic-amd64.tar.xz
tar -xvf wkhtmltox-0.12.3_linux-generic-amd64.tar.xz
sudo mv wkhtmltox /opt/
rm wkhtmltox-0.12.3_linux-generic-amd64.tar.xz
```

La ubicación del binario es: `/opt/wkhtmltox/bin/wkhtmltopdf`

### Conversión de formatos

Éste sistema depende del API de Conversión de Formatos para la importación de
archivos `DBF`, cuyo repositorio es https://gitlab.agetic.gob.bo/bolivia-libre/conversion-formatos

Este paso es requerido solamente en el caso que se desee importar la base de datos
desde el sistema VSIAF.

La instalación del API de Conversión de Formatos está descrita en el archivo [INSTALL.md](https://gitlab.agetic.gob.bo/bolivia-libre/conversion-formatos/blob/master/INSTALL.md)

Nota: Por incompatibilidad en las versiones del framework phalcon no funciona
correctamente la instalación, por tanto se recomienda utilizar el servicio
provisto por la ADSIB: `https://intranet.adsib.gob.bo/conversion-formatos`

## Ruby

Eliminar la versión actual de ruby en el sistema:

```console
sudo apt-get remove ruby1.8
```

Descargar Ruby y compilarlo:

```console
mkdir /tmp/ruby && cd /tmp/ruby
curl --remote-name --progress https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.6.tar.gz
echo '8322513279f9edfa612d445bc111a87894fac1128eaa539301cebfc0dd51571e  ruby-2.3.6.tar.gz' | shasum -c - && tar xzf ruby-2.3.6.tar.gz
cd ruby-2.3.6
./configure --disable-install-rdoc
make
sudo make install
```

Instalar la gema Bundler:

```console
sudo gem install bundler --no-ri --no-rdoc
```

## NodeJS

Instalación de [NodeJS v6](https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions):

```console
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs
```

Actualización del paquete npm:

```console
sudo npm install -g npm
```

Instalación del paquete `yarn`:

```console
sudo npm install -g yarn
```

## Usuario de Sistema Operativo

Crear el usuario `nsiaf`:

```
sudo adduser --disabled-login --gecos 'NSIAF' nsiaf
```

## Base de Datos

Instalación de `MySQL` la versión 5.5 que viene en Debian Jessie

```console
sudo apt-get install -y mysql-server libmysqlclient-dev
```

Creación de la base de datos

```console
mysql -u root -p

mysql> CREATE DATABASE IF NOT EXISTS `nsiaf_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;
mysql> exit
Bye
```

## NSIAF

Instalar NSIAF en el directorio home del usuario "nsiaf":

```console
cd /home/nsiaf
```

Clonar el código fuente:

```console
sudo -u nsiaf -H GIT_SSL_NO_VERIFY=true git clone https://gitlab.agetic.gob.bo/adsib/nsiaf.git -b agetic-mysql
```

Configurar el sistema:

```console
# Ingresar al folder de instalación
cd /home/nsiaf/nsiaf

# Copiar el archivo de configuración de la base de datos de ejemplo
sudo -u nsiaf -H cp config/database.yml.sample config/database.yml

# Copiar el archivo secrets de ejemplo
sudo -u nsiaf -H cp config/secrets.yml.sample config/secrets.yml
sudo -u nsiaf -H chmod 0600 config/secrets.yml
```

Instalar las gemas:

```console
sudo -u nsiaf -H bundle install --deployment --without development test
```

Editar `config/database.yml`:

```console
sudo -u nsiaf -H editor config/database.yml
```

si se necesita hacer una configuración más específica para la base de datos
se debe cambiar los siguientes datos:

```yaml
production:
  adapter: mysql2
  encoding: utf8
  database: nsiaf_production
  pool: 5
  host: localhost
  username: root
  password: root
  port: 3306
  socket: /var/run/mysqld/mysqld.sock
```

Hacer que `config/database.yml` solo sea accesible por el usuario nsiaf:

```console
sudo -u nsiaf -H chmod o-rwx config/database.yml
```

Generar la clave secreta:

```console
sudo -u nsiaf -H bundle exec rake secret
```

copiar la clave secreta generada y editar `config/secrets.yml`:

```console
sudo -u nsiaf -H editor config/secrets.yml
```
Editar `secrets.yml` con el siguiente contenido

```yml
production:
  convert_api_url: "https://intranet.adsib.gob.bo/conversion-formatos"
  rails_host: "www.dominio.gob.bo"
  rails_relative_url_root: ""
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
  wkhtmltopdf: "/opt/wkhtmltox/bin/wkhtmltopdf"
  ufv_desde: "01-01-2018"
  exception_notification:
    email_prefix: "[NSIAF] "
    sender_address: "notificador <noreply@dominio.gob.bo>"
    exception_recipients: "desarrollador1@dominio.gob.bo, desarrollador2@dominio.gob.bo, ..."
  smtp_settings:
    address: 'smtp.dominio.gob.bo'
    port: 587
    domain: 'dominio.gob.bo'
    user_name: 'nsiaf'
    password: 'mi-super-password'
    authentication: 'plain'
    enable_starttls_auto: true
  interoperabilidad_plantillas: false
```

donde:

* `convert_api_url` es la URL donde se encuentra instalado el API de [Conversión de Formatos](https://gitlab.agetic.gob.bo/bolivia-libre/conversion-formatos)
* `rails_host` es el host del servidor de deploy tal como: `www.dominio.gob.bo`.
* `rails_relative_url_root` es la ubicación del subdirectorio de deploy tal como: `www.dominio.gob.bo/activos`
  dejar una cadena vacía en el caso que el deploy sea en la raíz del dominio.
* `secret_key_base` se **DEBE** reemplazar con la clave secreta generada en el
  paso anterior.
* `wkhtmltopdf` es la ubicación del binario para conversión de HTML a PDF.
* `ufv_desde` descarga UFVs desde esa fecha del sitio web del Banco Central de
  Bolivia.
* `sender_address` es el email desde donde se haran las notificaciones por email
* `exception_recipients` ahí va los destinos de los emails puede ser uno o
  varios emails separados por comas: `des1@dominio.gob.bo, des2@dominio.gob.bo`
* `smtp_settings` la configuración del servidor de email desde el cual se
  enviará los emails de notificación de excepciones.
* `interoperabilidad_plantillas` Si es `true`, entonces implica que habra intercambio de información con el sistema de gestión documental(plantillas) mediante servicios web.

Descargar las dependencias para frontend:

```console
sudo -u nsiaf -H yarn install
```

Compilamos los archivos CSS y JS:

```console
sudo -u nsiaf -H bundle exec rake assets:clobber RAILS_ENV=production
sudo -u nsiaf -H bundle exec rake assets:precompile RAILS_ENV=production
```

Crear la estructura de tablas e inicializar con la configuración por defecto

```console
sudo -u nsiaf -H bundle exec rake db:migrate RAILS_ENV=production
sudo -u nsiaf -H bundle exec rake db:seed RAILS_ENV=production
```

El último comando establece los datos del usuario `super administrador`

* Usuario: `admin`
* Contraseña: `admin`

## Apache

Instalar `apache2` en el servidor:

```console
sudo apt-get install -y apache2 libcurl4-openssl-dev apache2-mpm-worker \
apache2-threaded-dev libapr1-dev libaprutil1-dev
```

Instalar `passenger` en el servidor:

```console
sudo gem install passenger --version 5.2.0 --no-ri --no-rdoc
```

Nota: se puede realizar la instalación de Passenger sin especificar la versión
solamente tener cuidado de copiar la ruta exacta para los archivos `passenger.conf`
y `passenger.load`.

Instalar el módulo de `passenger` para `apache2`:

```console
sudo passenger-install-apache2-module
```

Nota:

En la parte que `passenger-install-apache2-module` pide seleccionar los lenguajes
de programación para los cuales se instalará el módulo, seleccionar Ruby solamente.

Después de instalar el módulo de `passenger`, crear los archivos de configuración:

```console
sudo editor /etc/apache2/mods-available/passenger.conf
```

```apache
<IfModule mod_passenger.c>
  PassengerRoot /usr/local/lib/ruby/gems/2.3.0/gems/passenger-5.2.0
  PassengerDefaultRuby /usr/local/bin/ruby
</IfModule>
```

```console
sudo editor /etc/apache2/mods-available/passenger.load
```

```apache
LoadModule passenger_module /usr/local/lib/ruby/gems/2.3.0/gems/passenger-5.2.0/buildout/apache2/mod_passenger.so
```

Nota: El contenido de éstos dos archivos depende de la versión de la gema Passenger.

Habilitar el módulo `passenger` para Apache2:

```console
sudo a2enmod passenger
```

Habilitar el módulo `mod_rewrite` para Apache

```console
sudo a2enmod rewrite
```

Mover NSIAF a `/var/www/html`:

```console
sudo mv /home/nsiaf/nsiaf /var/www/html/
```

Configuración de Apache para el sistema NSIAF

```console
sudo editor /etc/apache2/sites-available/www.dominio.gob.bo.conf
```

Adicionar el siguiente contenido si se va instalar la aplicación en la raiz del dominio

```apache
<VirtualHost *:80>
  ServerName www.dominio.gob.bo
  DocumentRoot /var/www/html/nsiaf/public
  RailsEnv production
  <Directory /var/www/html/nsiaf/public>
    Allow from all
    Options -MultiViews
  </Directory>
</VirtualHost>
```

Contenido para deploy de la aplicación en un subdirectorio `/activos`

```apache
<VirtualHost *:80>
  ServerName www.dominio.gob.bo
  DocumentRoot /var/www/html

  <IfModule mod_rewrite.c>
      RewriteEngine on
      RewriteRule ^/activos$ /activos/ [R]
  </IfModule>

  Alias /activos /var/www/html/nsiaf/public
  RailsBaseURI /activos
  <Directory /var/www/html/nsiaf/public>
      RailsEnv production
      PassengerAppRoot /var/www/html/nsiaf/

      # Options FollowSymLinks -MultiViews -Indexes
      AllowOverride All
      Order deny,allow
      allow from all
  </Directory>
</VirtualHost>
```

Nota: Para el despliegue en un subdirectorio la configuración en `config/secrets.yml`
debe ser: `rails_relative_url_root: "/activos"`.

Habilitar el nuevo sitio y reiniciar Apache

```console
sudo a2ensite www.dominio.gob.bo
sudo service apache2 restart
```

Nota: Puede ser necesario deshabilitar el dominio por defecto con el comando
`sudo a2dissite 000-default`

Visitamos el sitio http://www.dominio.gob.bo o http://www.dominio.gob.bo/activos depende
de la configuración que se haya elegido para el deploy.

## Cron Jobs

Se hace uso de cron jobs para actualizar la información de los UFVs de manera
automática desde la página oficial del Banco Central de Bolivia.

Instalación de crontab:

```console
sudo apt-get install -y cron
```

Configurar los tareas programadas:

```console
sudo -u nsiaf -H bundle exec whenever -s 'environment=production' --update-crontab
```

Para revisar la configuración en el crontab:

```console
sudo -u nsiaf -H crontab -l
```

```console
# Begin Whenever generated tasks for: /var/www/html/nsiaf/config/schedule.rb
0 0,4,8,12,16,20 * * * /bin/bash -l -c 'cd /var/www/html/nsiaf && RAILS_ENV=production bundle exec rake db:ufv_importar --silent >> log/cron.log 2>&1'

# End Whenever generated tasks for: /var/www/html/nsiaf/config/schedule.rb
```


## Interoperabilidad con el sistema de gestión documental(Opcional)

Para interoperar con el sistema de gestión documental, entonces se debe realizar las siguientes acciones:

Editar el archivo de configuración `secrets.yml`, estableciendo a true el valor de la variable de interoperabilidad

```
  interoperabilidad_plantillas: true
```

Como usuario administrador, crear un token en `Administración/Tokens/` en base a los siguientes datos:

* `Email` Correo electrónico del usuario cliente perteneciente al sistema de gestión documental
* `Nombre` Nombre del usuario cliente perteneciente al sistema de gestión documental.
* `Fecha de expiración` Fecha limite hasta el cual sera valido el token, pasada esa fecha el token no sera valido.

Posteriormente se ha de generar un token, el cual debera ser proveido al cliente del sistema de gestión documental.
