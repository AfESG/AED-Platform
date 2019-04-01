#
# Provides mappings to the legacy reports.
#
module AedLegacy

  #
  # Gets the metadata for all the legacy reports.
  #
  def self.reports
    @reports ||= [
        { year: '2007', full_text: '033', authors: 'J.J. Blanc, R.F.W. Barnes, G.C. Craig, H.T. Dublin, C.R. Thouless, I. Douglas-Hamilton, and J.A. Hart', errata: true },
        { year: '2002', full_text: '029', authors: 'J.J. Blanc, C.R. Thouless, J.A. Hart, H.T. Dublin, I. Douglas-Hamilton, G.C. Craig and R.F.W. Barnes', errata: true },
        { year: '1998', full_text: '022', authors: 'R.F.W. Barnes, G.C. Craig, H.T. Dublin, G. Overton, W. Simons and C.R. Thouless', errata: false },
        { year: '1995', full_text: '011', authors: 'M.Y. Said, R.N. Chunge, G.C. Craig, C.R. Thouless, R.F.W. Barnes and H.T. Dublin', errata: true }
    ]
  end

  #
  # Gets all the years for the legacy reports.
  #
  def self.years
    @years ||= reports.map {|report| report[:year]}.map(&:to_i)
  end

  #
  # Gets if a specified year is a legacy report year.
  #
  def self.legacy_year?(year)
    if year.is_a?(String)
      year = Integer(year)
    end

    years.include?(year)
  end

  #
  # Gets the publication year for a legacy report.
  #
  def self.official_publication_year(year)
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
