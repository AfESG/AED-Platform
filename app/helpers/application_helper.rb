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

  def recent_submissions_scope
    # defined as submissions not yet included in any analysis
    PopulationSubmission.joins(:submission).joins('join countries on submissions.country_id=countries.id').where('population_submissions.id not in (select population_submission_id from estimate_factors_analyses) and EXTRACT(YEAR FROM population_submissions.created_at)>=2015')
  end

  def recent_released_submissions_scope
    recent_submissions_scope.where('released=true and submitted=true')
  end

  def last_three_surveys # inefficient!
    displayed = 0
    max = 3
    result = []
    recent_released_submissions_scope.order('id DESC').each do |population_submission|
      result << population_submission
      displayed = displayed + 1
      break if displayed >= max
    end
    result
  end

  # this shows all PS in the new model ... they're all new
  def new_surveys
    recent_released_submissions_scope.count
  end

  # this shows all users ... everybody's new
  def contributors
    User.where(disabled: false).count
  end

  def guess_new_count_path(p)
    eval "new_population_submission_#{p.count_base_name}_path(p)"
  end

  def guess_edit_count_path(c)
    eval "edit_#{c.count_base_name}_path(c)"
  end

  def guess_new_stratum_path(c)
    if c.has_strata?
      eval "new_#{c.count_base_name}_#{c.count_base_name}_stratum_path(c)"
    else
      eval "new_#{c.count_base_name}_path(c)"
    end
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

  def link_for_id(unit)
    if unit =~ /O(\d+)/
      return "/survey_others/#{$1}"
    elsif unit =~ /IR(\d+)/
      return "/survey_individual_registrations/#{$1}"
    elsif unit =~ /AS(\d+)/
      return "/survey_aerial_sample_count_strata/#{$1}"
    elsif unit =~ /AT(\d+)/
      return "/survey_aerial_total_count_strata/#{$1}"
    elsif unit =~ /DC(\d+)/
      return "/survey_dung_count_line_transect_strata/#{$1}"
    elsif unit =~ /GS(\d+)/
      return "/survey_ground_sample_count_strata/#{$1}"
    elsif unit =~ /GT(\d+)/
      return "/survey_ground_total_count_strata/#{$1}"
    elsif unit =~ /GD(\d+)/
      return "/survey_faecal_dna_strata/#{$1}"
    else
      return "/"
    end
  end

  def linked_ids_for(comma_separated_list)
    units = comma_separated_list.split(/,/)
    links = []
    units.each do |unit|
      links << link_to(unit, link_for_id(unit))
    end
    links.join(', ').html_safe
  end

  def best_label_for(tag)
    r = t "formtastic.labels.#{tag}", :default => ''
    if r.blank? and !@level.nil?
      r = t "formtastic.labels.#{@level.class.name.underscore}.#{tag}", :default => ''
    end
    if r.blank?
      return "#{tag}<b>?</b>: "
    end
    return "#{r}: "
  end

  def map_aggregate(level)
    area_sqkm = 0
    estimate = 0
    level.strata.each do |stratum|
      unless stratum.population_estimate.nil?
        estimate = estimate + stratum.population_estimate
      end
      unless stratum.stratum_area.nil?
        area_sqkm = area_sqkm + stratum.stratum_area
      end
    end
    "<h3>Aggregate area: #{area_sqkm} km<sup>2</sup></h3>" +
      "<h3>Aggregate estimate: #{estimate} elephants</h3>"
  end

end
