module AedUtils

  #
  # Get all analysis years (does not include legacy years).
  #
  def self.analysis_years(published=true)
    get_years(:analysis_year, published)
  end

  #
  # Get all publication years (does not include legacy years).
  #
  def self.publication_years(published=true)
    get_years(:publication_year, published)
  end

  #
  # Gets all analysis years and legacy years.
  #
  def self.all_analysis_years(published=true)
    get_all_years(:analysis_year, published)
  end

  #
  # Gets all analysis publication years and legacy years.
  #
  def self.all_publication_years(published=true)
    get_all_years(:publication_year, published)
  end

  #
  # Gets the latest published Analysis.
  #
  def self.latest_published_analysis
    Analysis.published.order(publication_year: :desc).first
  end

  private

  def self.get_years(year_field, published=true)
    years =
        if published || published.nil?
          Analysis.published.pluck(year_field)
        else
          Analysis.not_published.pluck(year_field)
        end.sort.reverse

    years
  end

  def self.get_all_years(year_field, published=true)
    years =
        if published || published.nil?
          (Analysis.published.pluck(year_field) + AedLegacy.years)
        else
          Analysis.not_published.pluck(year_field)
        end.sort.reverse

    years
  end

end
