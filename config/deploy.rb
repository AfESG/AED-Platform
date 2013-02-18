set :application, "aaed"
set :repository,  "git@github.com:rfc2616/aaed.git"

set :scm, :git

set :use_sudo, false
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

target = ENV['TARGET'] || 'WWW'

if target=='WWW'
  puts "Deploying to production AAED"
  server "pg.elephantdatabase.org", :app, :web, :db, :primary => true
  set :user, "aaed"
else
  puts "Deploying to staging AAED"
  server "nonexistentstaging.elephantdatabase.org", :app, :web, :db, :primary => true
  set :user, "aaed"
end

set :rvm_ruby_string, 'ruby-1.9.3-p194'
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
