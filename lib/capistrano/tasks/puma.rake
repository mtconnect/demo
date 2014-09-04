
namespace :puma do
  desc 'Start puma'
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      within current_path do
        execute :bundle, "exec pumactl #{start_options} start", :pty => false
      end
    end
  end

  desc 'Stop puma'
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      within current_path do
        execute :bundle, "exec pumactl -S #{state_path} stop"
      end
    end
  end

  desc 'Restart puma'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      within current_path do
        begin
          execute :bundle, "exec pumactl -S #{state_path} restart"
        rescue Capistrano::CommandError => ex
          puts "Failed to restart puma: #{ex}\nAssuming not started."
          start
        end
      end
    end
  end

  desc 'Restart puma (phased restart)'
  task :phased_restart do
    on roles(:app), in: :sequence, wait: 5 do
      within current_path do
        begin
          execute :bundle, "exec pumactl -S #{state_path} phased-restart"
        rescue Capistrano::CommandError => ex
          puts "Failed to restart puma: #{ex}\nAssuming not started."
          start
        end
      end
    end
  end

  def start_options
    "-q -C #{config_file}"
  end

  def config_file
    @_config_file ||= begin
      file = fetch(:puma_config_file, nil)
      file = "./config/puma/#{puma_env}.rb" if !file && File.exists?("./config/puma/#{puma_env}.rb")
      file
    end
  end

  def puma_env
    fetch(:rack_env, fetch(:rails_env, 'production'))
  end

  def state_path
    (config_file ? configuration.options[:state] : nil) || puma_state
  end

  def configuration
    require 'puma/configuration'

    config = Puma::Configuration.new(:config_file => config_file)
    config.load
    config
  end
end