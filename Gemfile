source 'http://rubygems.org'

gem 'rails'

# Rails 3.1 - Asset Pipeline
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

gem 'jquery-rails'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'

gem 'devise'

gem 'haml'

gem 'slim'

gem 'formtastic'

gem 'flutie', :git => 'https://github.com/thoughtbot/flutie.git'

gem 'maruku'

gem 'dalli'

gem 'rack-cache'

# gem 'sqlite3'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :test do
  gem 'turn', :require => false
end

group :development, :test do
  gem 'ruby_parser'
  gem 'hpricot'
end

group :production do
  gem 'newrelic_rpm'
  gem 'thin'
end
