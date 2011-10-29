ActionMailer::Base.smtp_settings = {
  :address => "smtp.gmail.com",
  :port => '587',
  :domain => "elephantdatabase.org",
  :authentication => :plain,
  :user_name => "network@elephantdatabase.org",
  :password => ENV['GMAIL_PASSWORD'],
  :enable_starttls_auto => true
}
