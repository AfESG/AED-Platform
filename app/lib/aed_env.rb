#
# Wrapper for environment variables.
#
module AedEnv

  #
  # Gets the full domain name of the app.
  #
  def self.DOMAIN
    ENV.fetch('DOMAIN', 'africanelephantdatabase.org')
  end

  def self.AWS_ACCESS_KEY_ID
    ENV.fetch('AWS_ACCESS_KEY_ID')
  end

  def self.AWS_SECRET_ACCESS_KEY
    ENV.fetch('AWS_SECRET_ACCESS_KEY')
  end

  def self.AWS_DEFAULT_REGION
    ENV.fetch('AWS_DEFAULT_REGION')
  end

  def self.MEMCACHED_URL
    ENV.fetch('MEMCACHED_URL', 'localhost:11211')
  end

  def self.REQUEST_FORM_SUBMITTED_TO_EMAIL
    ENV.fetch('REQUEST_FORM_SUBMITTED_TO_EMAIL')
  end

  def self.REQUEST_FORM_SUBMITTED_BCC_EMAIL
    ENV.fetch('REQUEST_FORM_SUBMITTED_BCC_EMAIL')
  end

  def self.REQUEST_FORM_THANKS_BCC_EMAIL
    ENV.fetch('REQUEST_FORM_THANKS_BCC_EMAIL')
  end

  def self.GOOGLE_ANALYTICS_TRACKING_ID
    ENV.fetch('GOOGLE_ANALYTICS_TRACKING_ID', nil)
  end

end
