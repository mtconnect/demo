#!/usr/bin/env puma

app_root = '/home/deploy/imtsdemo/'
shared_path = "#{app_root}/shared"
current_path = "#{app_root}/current"

rackup "#{current_path}/config.ru"

directory current_path
environment "production"
daemonize false
pidfile  "#{shared_path}/pids/puma.pid"
state_path "#{shared_path}/pids/puma.state"
stdout_redirect "#{current_path}/log/puma-access.log", "#{current_path}/log/puma-error.log"

threads 0, 16
bind 'unix:///tmp/sockets/imtsdemo-puma.sock'

workers 4

activate_control_app 'unix:///tmp/sockets/imtsdemo-pumactl.sock'


