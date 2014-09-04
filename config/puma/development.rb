#!/usr/bin/env puma

app_root = '/Users/will/projects/MTConnect/imtsdemo'
shared_path = "#{app_root}/shared"
current_path = "#{app_root}/current"

directory current_path
environment "production"
daemonize false
pidfile  "#{shared_path}/tmp/pids/puma.pid"
state_path "#{shared_path}/tmp/pids/puma.state"
stdout_redirect "#{current_path}/log/puma-access.log", "#{current_path}/log/puma-error.log"

threads 0, 16
bind 'unix:///tmp/sockets/imtsdemo-puma.sock'
bind 'tcp://127.0.0.1:3000'

workers 4

activate_control_app 'unix:///tmp/sockets/imtsdemo-pumactl.sock'


