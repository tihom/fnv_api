set :application, "fnv_api"
set :repository,  "git@github.com:tihom/fnv_api.git"

set :whenever_environment, defer { :production }
set :whenever_command, "bundle exec whenever"
# adding as using staging server for delayed job production soif not this  whenever will overwrite cron
set :whenever_identifier, defer { "#{application}_#{stage}" }

require "whenever/capistrano"



set :deploy_to, "/var/fnv_api"
set :scm, :git
set :branch, "master"
set :deploy_via, :copy

default_run_options[:pty] = true
set :use_sudo, false
set :user, "ubuntu"
ssh_options[:forward_agent] = true
ssh_options[:auth_methods] = ["publickey"]
ssh_options[:keys] = ["/Users/mohitagg/Desktop/Aalgro/aalgro.pem"]

set :rails_env, "production"

server "54.200.142.105", :app, :web, :db, :primary => true


#If you are using Passenger mod_rails uncomment this:
namespace :deploy do
	desc "Symlink shared config files"
	task :symlink_config_files do
	    run "#{ try_sudo } ln -fs #{ deploy_to }/shared/config/database.yml #{ release_path }/config/database.yml"
	    run "#{ try_sudo } ln -fs #{ deploy_to }/shared/config/app_config.yml #{ release_path }/config/app_config.yml"
	    # linking the db folder to shared directory as db structure on production can be different
	    #  run "#{ try_sudo } ln -fs #{ deploy_to }/shared/db #{ release_path }/"
	end

    task :start do ; end
	task :stop do ; end
	task :restart, :roles => :app, :except => { :no_release => true } do
	   run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
	end
end

before "deploy:assets:precompile", "deploy:symlink_config_files"
