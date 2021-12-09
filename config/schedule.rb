set :output, "log/cron.log"

every 4.hours do
  rake "db:ufv_importar"
end
