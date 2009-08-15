
namespace :thin do
  set :thin_clean, false
  set :thin_rails, 'thin'
  set :thin_conf, nil
  
  def set_thin_conf
    set :thin_conf, "/etc/thin/#{application}.yml" unless thin_conf
  end
  
  desc "Setup thin cluster configuration"
  task :setup, :roles => :app do
    set_thin_conf
    
    run <<-CMD
      thin_rails thin -e production -c #{current_path} -s 2 -C #{thin_conf} --user #{user} --group root -P #{shared_path}/pids/thin.pid -S /tmp/#{application}.sock
    CMD
  end

  desc <<-DESC
  Start Mongrel processes on the app server.  This uses the :use_sudo variable to determine whether to use sudo or not. By default, :use_sudo is
  set to true.
  DESC
  task :start, :roles => :app do
    set_thin_conf
    cmd = "#{thin_rails} -C #{thin_conf} start"
    cmd += " --clean" if thin_clean    
    send(run_method, cmd)
  end
  
  desc <<-DESC
  Restart the Mongrel processes on the app server by starting and stopping the cluster. This uses the :use_sudo
  variable to determine whether to use sudo or not. By default, :use_sudo is set to true.
  DESC
  task :restart, :roles => :app do
    set_thin_conf
    cmd = "#{thin_rails} -C #{thin_conf} restart"
    cmd += " --clean" if thin_clean    
    send(run_method, cmd)
  end
  
  desc <<-DESC
  Stop the Mongrel processes on the app server.  This uses the :use_sudo
  variable to determine whether to use sudo or not. By default, :use_sudo is
  set to true.
  DESC
  task :stop, :roles => :app do
    set_thin_conf
    cmd = "#{thin_rails} -C #{thin_conf} stop"
    cmd += " --clean" if thin_clean    
    send(run_method, cmd)
  end  
end
