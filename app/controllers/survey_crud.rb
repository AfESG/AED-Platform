# This set of controller internals can be shared across all
# objects in the survey submission hierarchy. At the minimum
# it is necessary to include it in the target controller.
#
# If the object type has a parent, define a connect_parent
# method that populates the parent relationship in the new
# method.
#
# If the object type has a child, define a new_child_path
# method that supplies the link path that will be short-
# circuited after creating the object for the first time.

module SurveyCrud

  def set_title
    @title = I18n.t 'title', scope: "#{level_base_name.pluralize}.#{params[:action]}"
  end

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

  def level_class_name
    self.class.name.gsub('Controller','').singularize
  end

  def level_base_name
    level_class_name.underscore
  end

  def level_class
    eval "#{level_class_name}"
  end

  def level_form
    'layouts/survey_crud_form'
  end

  def level_display
    if(level_class_name!="PopulationSubmissionAttachment")
      'layouts/survey_display'
    end
  end

  # this allows the use of the Rails convention of a specifically
  # named class variable in views, e.g. @survey_aerial_transect_count,
  # but just @level will do fine, and is preferred going forward
  # because it makes it easier to port new views.
  def enable_named_class_variable
    eval "@#{level_base_name}=@level"
  end

  def index
    set_title
    @levels = level_class.all
  end

  def show
    set_title
    @level = level_class.find(params[:id])
    find_parents @level
    enable_named_class_variable
    render template: level_display if level_display
  end

  def new
    if user_signed_in? and !current_user.admin?
      render template: 'submissions/how_to_submit'
      return
    end
    set_title
    @level = level_class.new
    if respond_to? 'connect_parent'
      connect_parent
      find_parents @level
    end
    enable_named_class_variable
    if params[:from_feature]
      @from_feature = params[:from_feature]
      population_submission_geometry = PopulationSubmissionGeometry.find(@from_feature)
      from_properties = JSON.parse(population_submission_geometry.geom_attributes)
      if from_properties and from_properties['name']
        @level.stratum_name = from_properties['name']
      end
    end
    render template: level_form if level_form
  end

  def edit(explicit_level_form = nil)
    set_title
    @level = level_class.find(params[:id])
    find_parents @level
    enable_named_class_variable

    puts "----------------------------------------------"
    puts "edit_allowed = #{edit_allowed}"

    unless edit_allowed
      flash[:error] = "You attempted an operation that was not permitted."
      redirect_to @level
      return
    end
    if explicit_level_form
      render template: explicit_level_form
    elsif level_form
      render template: level_form
    end
  end

  def create
    @from_feature = params[level_base_name]['from_feature']
    params[level_base_name].delete 'from_feature'
    @level = level_class.new(params[level_base_name])

    # We have special knowledge of this association since it cannot
    # be done by mass assignment
    if level_base_name == 'submission'
      @level.user_id = current_user.id
    end

    find_parents @level
    enable_named_class_variable

    unless edit_allowed
      flash[:error] = "You attempted an operation that was not permitted."
      if @submission.nil?
        redirect_to root_url
      else
        redirect_to @submission
      end
      return
    end

    if @level.save
      if @from_feature and !@from_feature.blank?
        population_submission_geometry = PopulationSubmissionGeometry.find(@from_feature);
        survey_geometry = SurveyGeometry.new
        survey_geometry.geom = population_submission_geometry.geom
        if @population_submission
          survey_geometry.attribution = @population_submission.short_citation
        end
        survey_geometry.save!
        @level.survey_geometry = survey_geometry
        @level.save!
        population_submission_geometry.destroy
      end
      if params['commit'] == 'This is my final stratum'
        redirect_to "/population_submissions/#{@population_submission.id}/submit"
      else
        if respond_to? 'new_child_path'
          redirect_to new_child_path
        else
          redirect_to @level
        end
      end
    else
      if level_form
        render template: level_form
      else
        render :action => "new"
      end
    end
  end

  def update
    @level = level_class.find(params[:id])
    find_parents @level
    enable_named_class_variable

    unless edit_allowed
      flash[:error] = "You attempted an operation that was not permitted."
      if @submission.nil?
        redirect_to root_url
      else
        redirect_to @submission
      end
      return
    end

    params[level_base_name].delete 'from_feature'
    if @level.update_attributes(params[level_base_name])
      redirect_to @level
    else
      if level_form
        render template: level_form if level_form
      else
        render :action => "edit"
      end
    end
  end

  def destroy
    @level = level_class.find(params[:id])
    find_parents @level

    unless edit_allowed
      flash[:error] = "You attempted an operation that was not permitted."
      if @submission.nil?
        redirect_to root_url
      else
        redirect_to @submission
      end
      return
    end

    @level.destroy
    if @population_submission.nil?
      unless @submission.nil?
        redirect_to @submission
      else
        redirect_to '/submissions'
      end
    else
      redirect_to @population_submission
    end
  end

end
