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

end
