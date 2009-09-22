set :application, "emo"
set :repository,  "git://github.com/mtconnect/demo.git"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/deploy/emo"

ssh_options[:port] = port
ssh_options[:username] = "deploy"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git

role :app, "emo.mtconnect.org"
role :web, "emo.mtconnect.org"
role :db,  "emo.mtconnect.org", :primary => true

namespace :deploy do
    desc "Override the default restart and execute mongel:restart task. See thin:restart"
    task :restart, :roles => :app, :except => { :no_release => true } do
      thin.restart
    end

    desc "Override the default start and execute thin:start"
    task :start, :roles => :app do
      thin.start
    end

    desc "Override the default stop and execute thin:stop"
    task :stop, :roles => :app do
      thin.stop
    end
end

after 'deploy:update_code', 'link_database_config'

task :link_database_config, :roles => :app do
    run "ln -nfs #{shared_path}/secure/database.yml #{release_path}/config/database.yml && " +
        "ln -nfs #{shared_path}/secure/auth #{release_path}/config/auth && " +
        "ln -nfs #{shared_path}/pictures #{release_path}/public/pictures && " +
        "ln -nfs #{shared_path}/media #{release_path}/public/media"
end
