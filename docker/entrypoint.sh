#!/bin/sh

if [ ! -f /opt/install.lock ]
then
  bundle exec rake assets:precompile
  bundle exec rake db:create
  bundle exec rake db:migrate
  bundle exec rake db:seed
  bundle exec whenever -s 'environment=production' --update-crontab
  service cron start
  touch /opt/install.lock
fi

exec "$@"
