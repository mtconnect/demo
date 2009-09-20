namespace :glassfish do
  desc <<-DESC
  Start glassfish gem as root since it needs to bind to port 80
  DESC
  task :start, :roles => :app do
    run "jruby -S glassfish"
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
    run "kill -INT $(cat #{current_path}/log/glasfish.pid)"
  end  
end
