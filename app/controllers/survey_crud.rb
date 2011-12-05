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

  def level_class_name
    self.class.name.gsub('Controller','').singularize
  end

  def level_base_name
    level_class_name.underscore
  end

  def level_class
    eval "#{level_class_name}"
  end

  # this allows the use of the Rails convention of a specifically
  # named class variable in views, e.g. @survey_aerial_transect_count,
  # but just @level will do fine, and is preferred going forward
  # because it makes it easier to port new views.
  def enable_named_class_variable
    eval "@#{level_base_name}=@level"
  end

  def index
    @levels = level_class.all

    respond_to do |format|
      format.html
    end
  end

  def show
    @level = level_class.find(params[:id])
    find_parents @level
    enable_named_class_variable

    respond_to do |format|
      format.html
    end
  end

  def new
    @level = level_class.new
    connect_parent
    find_parents @level
    enable_named_class_variable

    respond_to do |format|
      format.html
    end
  end

  def edit
    @level = level_class.find(params[:id])
    find_parents @level
    enable_named_class_variable
  end

  def create
    @level = level_class.new(params[level_base_name])
    find_parents @level
    enable_named_class_variable

    respond_to do |format|
      if @level.save
        if respond_to? 'new_child_path'
          format.html { redirect_to new_child_path }
        else
          format.html { render :action => "show" }
        end
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @level = level_class.find(params[:id])
    find_parents @level
    enable_named_class_variable

    respond_to do |format|
      if @level.update_attributes(params[level_base_name])
        format.html { redirect_to(@level) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @level = level_class.find(params[:id])
    @level.destroy

    respond_to do |format|
      format.html { redirect_to(eval("#{level_base_name.pluralize}_url")) }
    end
  end

end
