# This file is used by Rack-based servers to start the application.

require 'dalli'

require ::File.expand_path('../config/environment',  __FILE__)

use Rack::Cache, :verbose => true

run Aed::Application
