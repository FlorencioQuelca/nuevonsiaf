# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
ENV['ADMIN_USUARIO'] ||= 'admin'
ENV['ADMIN_PASSWORD'] ||= 'admin'
user = { name: 'Administrador', username: ENV['ADMIN_USUARIO'], email: 'admin@dominio.gob.bo', password: ENV['ADMIN_PASSWORD'], role: 'super_admin' }
u = User.find_by_username('admin')
unless u.present?
  u = User.new(user)
  u.save!(validate: false)
  puts "User '#{u.username}' created."
end
