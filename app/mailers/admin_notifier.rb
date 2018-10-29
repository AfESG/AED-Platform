class AdminNotifier < ActionMailer::Base
  default :from => "network@#{AedEnv.DOMAIN}"

  def data_request_form_submitted(data_request_form, user)
    @user = user
    @data_request_form = data_request_form
    mail :to => AedEnv.REQUEST_FORM_SUBMITTED_TO_EMAIL, :bcc => AedEnv.REQUEST_FORM_SUBMITTED_BCC_EMAIL
  end

  def data_request_form_thanks(data_request_form, user)
    @user = user
    @data_request_form = data_request_form
    mail :to => user.email, :bcc => AedEnv.REQUEST_FORM_THANKS_BCC_EMAIL
  end

end
