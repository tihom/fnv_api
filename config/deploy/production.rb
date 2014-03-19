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
# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

# role :web, "your web-server here"                          # Your HTTP server, Apache/etc
# role :app, "your app-server here"                          # This may be the same as your `Web` server
# role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

#If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end