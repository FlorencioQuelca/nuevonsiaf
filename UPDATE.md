# Actualización

Para actualizar a una versión reciente del sistema realizar los siguientes pasos:

Actualización del repositorio:

```console
cd /var/www/html/nsiaf
sudo -u nsiaf -H GIT_SSL_NO_VERIFY=true git pull origin master
```

Actualización de gemas:

```console
sudo -u nsiaf -H bundle install --deployment --without development test
```

Descargar las dependencias para frontend:

```console
sudo -u nsiaf -H yarn install
```

Ejecución de migraciones:

```console
sudo -u nsiaf -H bundle exec rake db:migrate RAILS_ENV=production
```

Compilación de archivos CSS y JS:

```console
sudo -u nsiaf -H bundle exec rake assets:clobber RAILS_ENV=production
sudo -u nsiaf -H bundle exec rake assets:precompile RAILS_ENV=production
```

<!-- Actualización de tareas programadas:

```console
sudo -u nsiaf -H bundle exec whenever -s 'environment=production' --update-crontab
``` -->

Reinicio del servidor mediante `passenger`:

```console
sudo -u nsiaf -H touch tmp/restart.txt
```
