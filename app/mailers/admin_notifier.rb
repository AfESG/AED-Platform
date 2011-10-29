class AdminNotifier < ActionMailer::Base
  default :from => "network@elephantdatabase.org"

  def data_request_form_submitted(data_request_form)
    @data_request_form = data_request_form
    mail :to => "Diane.Skinner@iucn.org", :cc => "heittman.rob@gmail.com"
  end

end
