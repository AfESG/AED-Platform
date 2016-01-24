require "rvm/capistrano"
require "rvm/capistrano/gem_install_uninstall"

set :application, "aaed"
set :repository,  "git@github.com:AfESG/AEDWebsite.git"

set :scm, :git

set :use_sudo, false
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

target = ENV['TARGET'] || 'WWW'

server "aed.elephantdatabase.org", :app, :web, :db, :primary => true
set :user, "aed"

if target == 'WWW'
  puts "Deploying to production"

  default_environment['UNICORN_PORT'] = '5000'
  default_environment['POSTGRESQL_DATABASE'] = 'aed_production'
  default_environment['HOSTNAME'] = 'www.elephantdatabase.org'
  default_environment['APP_PATH'] = '/u/production'
  set :deploy_to, '/u/production'
end

if target == 'STAGING'
  puts "Deploying to staging"

  default_environment['UNICORN_PORT'] = '4000'
  default_environment['POSTGRESQL_DATABASE'] = 'aed_staging'
  default_environment['HOSTNAME'] = 'staging.elephantdatabase.org'
  default_environment['authenticate_all_requests'] = 'cop17'
  default_environment['APP_PATH'] = '/u/staging'
  set :deploy_to, '/u/staging'
end

if target == 'DEV'
  puts "Deploying to dev"

  default_environment['UNICORN_PORT'] = '3000'
  default_environment['POSTGRESQL_DATABASE'] = 'aed_development'
  default_environment['HOSTNAME'] = 'dev.elephantdatabase.org'
  default_environment['authenticate_all_requests'] = 'theta'
  default_environment['APP_PATH'] = '/u/dev'
  set :deploy_to, '/u/dev'
end

if target == 'DEV2'
  puts "Deploying to dev2"

  default_environment['UNICORN_PORT'] = '3001'
  default_environment['POSTGRESQL_DATABASE'] = 'aed_development2'
  default_environment['HOSTNAME'] = 'dev2.elephantdatabase.org'
  default_environment['authenticate_all_requests'] = 'phi'
  default_environment['APP_PATH'] = '/u/dev2'
  set :deploy_to, '/u/dev2'
end

set :rvm_ruby_string, 'ruby-2.2.3@aed'
set :rvm_type, :user

require 'bundler/capistrano'

set :unicorn_pid, "#{fetch(:current_path)}/public/system/unicorn.pid"

require 'capistrano-unicorn'

# role :web, "your web-server here"                          # Your HTTP server, Apache/etc
# role :app, "your app-server here"                          # This may be the same as your `Web` server
# role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

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
