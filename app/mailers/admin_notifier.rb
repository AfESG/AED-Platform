class AdminNotifier < ActionMailer::Base
  default :from => "network@elephantdatabase.org"

  def data_request_form_submitted(data_request_form, user)
    @user = user
    @data_request_form = data_request_form
    mail :to => "Diane.Skinner@iucn.org", :bcc => "heittman.rob@gmail.com"
  end

  def data_request_form_thanks(data_request_form, user)
    @user = user
    @data_request_form = data_request_form
    mail :to => user.email, :bcc => "heittman.rob@gmail.com"
  end

end
