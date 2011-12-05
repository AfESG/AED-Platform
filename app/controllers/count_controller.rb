# Methods consistent across all Count level objects
module CountController

  def count_class_name
    self.class.name.gsub('Controller','').singularize
  end

  def count_base_name
    count_class_name.underscore
  end

  def count_class
    eval "#{count_class_name}"
  end

  # this allows the use of the Rails convention of a specifically
  # named class variable in views, e.g. @survey_aerial_transect_count,
  # but just @count will do fine, and is preferred going forward
  # because it makes it easier to port new views.
  def enable_named_class_variable
    eval "@#{count_base_name}=@count"
  end

  def index
    @counts = count_class.all

    respond_to do |format|
      format.html
    end
  end

  def show
    @count = count_class.find(params[:id])
    find_parents @count
    enable_named_class_variable

    respond_to do |format|
      format.html
    end
  end

  def new
    @count = count_class.new
    @count.population_submission = PopulationSubmission.find(params[:population_submission_id])
    find_parents @count
    enable_named_class_variable

    respond_to do |format|
      format.html
    end
  end

  def edit
    @count = SurveyAerialSampleCount.find(params[:id])
    find_parents @count
    enable_named_class_variable
  end

  def create
    @count = count_class.new(params[count_base_name])
    enable_named_class_variable

    respond_to do |format|
      if @count.save
        format.html { redirect_to(guess_new_stratum_path(@count)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @count = count_class.find(params[:id])
    find_parents @count
    enable_named_class_variable

    respond_to do |format|
      if @count.update_attributes(params[count_base_name])
        format.html { redirect_to(@count) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @count = count_class.find(params[:id])
    @count.destroy

    respond_to do |format|
      format.html { redirect_to(eval("#{count_base_name.pluralize}_url")) }
    end
  end

end
