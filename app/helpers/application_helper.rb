# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = [sort_direction]
    new_direction = (column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc')
    if column == sort_column
      css_class << 'current'
    end
    link_to title, {:sort => column, :direction => new_direction, :page => nil}, {:class => css_class.join(' ')}
  end

  def get_nav_item(text, path)
    request_uri = controller.request.fullpath
    if (path == "/" && request_uri == path )
      return "<div class=\"selected\">#{text}</div>";
    elsif (path != "/" && request_uri.starts_with?( path))
      return "<div class=\"selected\">#{link_to text, path}</div>";
    end
    return link_to text, path
  end

  def last_three_surveys # inefficient!
    displayed = 0
    max = 3
    result = []
    PopulationSubmission.where(:released => true).order('id DESC').each do |population_submission|
      result << population_submission
      displayed = displayed + 1
      break if displayed >= max
    end
    result
  end

  # this shows all PS in the new model ... they're all new
  def new_surveys
    PopulationSubmission.where(:released => true).count
  end

  # this shows all users ... everybody's new
  def contributors
    User.find(:all).count
  end

  def guess_new_count_path(p)
    eval "new_population_submission_#{p.count_base_name}_path(p)"
  end

  def guess_edit_count_path(c)
    eval "edit_#{c.count_base_name}_path(c)"
  end

  def guess_new_stratum_path(c)
    eval "new_#{c.count_base_name}_#{c.count_base_name}_stratum_path(c)"
  end

  def guess_edit_stratum_path(b)
    eval "edit_#{b.stratum_base_name}_path(b)"
  end

  def guess_show_stratum_path(b)
    eval "#{b.stratum_base_name}_path(b)"
  end

  # FIXME/Annoying/NotDRY: this helper is duplicated in SurveyCrud
  def edit_allowed
    if current_user.nil?
      return false
    end
    if current_user.admin?
      return true
    end
    if @submission.nil?
      return false
    end
    if @submission.user == current_user
      if @population_submission.nil?
        return true
      else
        unless @population_submission.submitted?
          return true
        end
      end
    end
    return false
  end

  def best_label_for(tag)
    r = t "formtastic.labels.#{tag}", :default => ''
    if r.blank? and !@level.nil?
      r = t "formtastic.labels.#{@level.class.name.underscore}.#{tag}", :default => ''
    end
    if r.blank?
      return "#{tag}<b>?</b>:"
    end
    return "#{r}:"
  end

end
