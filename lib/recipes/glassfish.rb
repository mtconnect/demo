namespace :glassfish do
  desc <<-DESC
  Start glassfish gem as root since it needs to bind to port 80
  DESC
  task :start, :roles => :app do
    sudo "jruby -S glassfish --config #{current_path}/config/glassfish.yml #{current_path}"
    sudo "chmod 644 #{current_path}/log/glassfish.pid"
  end
  
  desc <<-DESC
  Stops the glassfish gem
  DESC
  task :restart, :roles => :app do
    stop
    start
  end
  
  desc <<-DESC
  Stops the glassfish gem
  DESC
  task :stop, :roles => :app do
    sudo "kill -INT $(cat #{current_path}/log/glassfish.pid) || echo No pid file"
  end  
end
