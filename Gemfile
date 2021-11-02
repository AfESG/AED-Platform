source 'http://rubygems.org'

ruby '2.5.3'

gem 'rails', '~> 4.2.11'

gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'

gem 'jquery-rails'
gem 'leaflet-rails'
gem 'bootstrap-sass'

#Admin interface
gem 'rails_admin'

gem 'pg', '< 1.0.0'

gem 'devise'

gem 'slim'

gem 'formtastic'
gem 'formtastic-bootstrap'

gem 'maruku'

gem 'dalli'

gem 'rack-cache'

gem 'paperclip'

gem 'aws-sdk', '~> 3'

gem 'aws-sdk-rails'

gem 'paper_trail'

gem 'kaminari'

gem 'country_select'

gem 'rubyzip'

# Requires:
#   sudo apt install libgeos-dev
#     Make sure this lib is installed before running 'bundle install'.
#     Otherwise: `gem uninstall rgeo`, `sudo apt install libgeos-dev`, `gem install rgeo`
gem 'rgeo'
gem 'rgeo-shapefile'
gem 'rgeo-geojson'

# For shapefile writing support
gem 'dbf'
gem 'georuby'

# Make ActiveRecord PostGIS-aware
gem 'activerecord-postgis-adapter'

# Use puma as the web server
gem 'puma'

gem 'protected_attributes'
gem 'roo'

# For faking narratives (for now)
gem 'faker'

# Cache actions for API responses
gem 'actionpack-action_caching'

# font-awesome for admin
gem 'font-awesome-sass', '~> 4.6.1'

# log down login form with captcha
gem 'recaptcha'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :test do

end

group :development do
  gem "rails-erd"
end

group :development, :test do
  gem 'hpricot'
  gem 'dotenv-rails'
end

group :production do
  gem 'rails_12factor'
  gem 'appygram-rails'
end

