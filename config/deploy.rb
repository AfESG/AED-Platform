require "rvm/capistrano"

set :application, "aaed"
set :repository,  "git@github.com:AfESG/AEDwebsite.git"

set :scm, :git

set :use_sudo, false
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

target = ENV['TARGET'] || 'WWW'

server "pg.elephantdatabase.org", :app, :web, :db, :primary => true
set :user, "aaed"

if target == 'WWW'
  puts "Deploying to production"

  default_environment['UNICORN_PORT'] = '5000'
  default_environment['POSTGRESQL_DATABASE'] = 'aaed_production'
  default_environment['HOSTNAME'] = 'www.elephantdatabase.org'
  set :deploy_to, '/u/apps'
end

if target == 'STAGING'
  puts "Deploying to staging"
  default_environment['UNICORN_PORT'] = '3000'
  default_environment['POSTGRESQL_DATABASE'] = 'aaed_staging'
  default_environment['HOSTNAME'] = 'staging.elephantdatabase.org'
  set :deploy_to, '/u/staging'
  set :branch,  "homepage"
end

set :rvm_ruby_string, 'ruby-2.1.6'

before 'deploy', 'rvm:install_rvm'
before 'deploy', 'rvm:install_ruby'

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
