server "imts.mtconnect.org", :web, :app, :db, primary: true
set :application, "mtc_imts_demo"
set :user, "deploy"
set :deploy_to, "/home/#{user}/#{application}"
set :deploy_via, :remote_cache

set :scm, "git"
set :repository, "git@github.com:systeminsights/mtc_imts_demo.git"
set :branch, "master"

#require "rvm/capistrano"
#set :rvm_ruby_string, '1.9.3@mtc_website'
#set :rvm_type, :user

require "bundler/capistrano"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

#role :web, "your web-server here"                          # Your HTTP server, Apache/etc
#role :app, "your app-server here"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
before "deploy:restart", "deploy:restart_thins"

namespace :deploy do
  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/auth.txt #{release_path}/config/auth.txt"
  end
  
  task :symlink_uploads, rolse: :app do
    run "ln -nfs #{shared_path}/uploads #{release_path}/public/uploads"
    run "ln -nfs #{shared_path}/inspections #{release_path}/public/inspections"
  end
  

  desc "restarting the thin workers"
  task :restart_thins, roles: :app do
    run "#{try_sudo} thin -C /etc/thin/imts_demo.yml stop"
    run "#{try_sudo} thin -C /etc/thin/imts_demo.yml start"
  end
  
  desc 'restart the collector'
  task :restart_collector, roles: :app, on_error: :continue do
    run "#{try_sudo} initctl stop collector"
    run "#{try_sudo} initctl start collector"
  end
 
  after "deploy:finalize_update", "deploy:symlink_config"
  after "deploy:finalize_update", "deploy:symlink_uploads"
  after "deploy:restart_thins", "deploy:restart_collector"
end
