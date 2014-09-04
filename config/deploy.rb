# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'imtsdemo'
set :repo_url, 'git@github.com:mtconnect/demo.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/deploy/imtsdemo'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/auth.txt}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle
    public/system public/uploads public/quality tmp/pids}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# rbenv
set :rbenv_type, :user
set :rbenv_ruby, '2.1.2'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails thin}
set :rbenv_roles, :all

# Bundler
set :bundle_binstubs, -> { shared_path.join('binstubs') }

# Puma
# Defaults should work from puma cap file
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
set :puma_state, "#{shared_path}/pids/puma.state"
set :puma_role, :app


namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir -p /tmp/sockets"
      execute "mkdir -p #{shared_path}/pids"
    end
  end
end


namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:phased_restart'
      execute "pkill -f collector"
    end
  end

  desc "start"
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      invoke "puma:start"
      # initctl start collector
    end
  end

  desc "stop"
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      invoke "puma:stop"
      # initctl stop collector
    end
  end


  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
  after :publishing, :restart

  before :starting,     :check_revision
end
