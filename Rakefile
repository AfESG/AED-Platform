# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

Aed::Application.load_tasks

namespace :memcached do
  desc 'Clears the Rails cache'
  task :flush => :environment do
    Rails.cache.clear
  end
end
