# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def get_nav_item(text, path)
    request_uri = controller.request.fullpath
    if (path == "/" && request_uri == path )
      return "<div class=\"selected\">#{text}</div>";
    elsif (path != "/" && request_uri.starts_with?( path))
      return "<div class=\"selected\">#{text}</div>";
    end
    return link_to text, path
  end

  def last_three_surveys # inefficient!
    displayed = 0
    max = 3
    result = []
    PopulationSubmission.find(:all, :order => 'id DESC').each do |population_submission|
      result << population_submission
      displayed = displayed + 1
      break if displayed > max
    end
    result
  end

  # this shows all PS in the new model ... they're all new
  def new_surveys
    PopulationSubmission.find(:all).count
  end

  # this shows all users ... everybody's new
  def contributors
    User.find(:all).count
  end

end
