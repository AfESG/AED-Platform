module OfficialPublicationYearHelper

  def official_publication_year(year)
    # For some years, we publish a different official year
    # than the comparison or analysis year actually used
    # in the calculations. Enumerate those changes here.
    official_year_adjustments = {
      '2007' => '2006'
    }
    if year
      official_year_adjustments[year.to_s] or year
    end
  end

end
