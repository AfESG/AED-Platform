load 'deploy'
# Uncomment if you are using Rails' asset pipeline
load 'deploy/assets'
Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy' # remove this line to skip loading any of the default tasks

namespace :memcached do
  desc 'Flushes memcached local instance'
  task :flush, :roles => [:app] do
    run("cd #{current_path} && rake memcached:flush")
  end
end
