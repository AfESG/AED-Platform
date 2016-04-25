class Change < ActiveRecord::Base

  has_paper_trail

  belongs_to :analysis

  attr_accessible(
    :change,
    :analysis_name,
    :analysis_year,
    :country,
    :population,
    :replacement_name,
    :replaced_strata,
    :new_strata,
    :reason_change,
    :status,
    :comments
  )

  before_validation :generate_sort_key

  def generate_sort_key
    self.population = '' unless self.population
    self.replacement_name = '' unless self.replacement_name
    self.sort_key = self.population + self.replacement_name
  end

  def fetch_strata(s)
    mappings={
      'AS' => 'SurveyAerialSampleCountStratum',
      'AT' => 'SurveyAerialTotalCountStratum',
      'DC' => 'SurveyDungCountLineTransectStratum',
      'GD' => 'SurveyFaecalDnaStratum',
      'GS' => 'SurveyGroundSampleCountStratum',
      'GT' => 'SurveyGroundTotalCountStrata',
      'IR' => 'SurveyIndividualRegistrations',
      'O' => 'SurveyOthers'
    }
    strata_codes = s.split(/,\s*/)
    result_strata = []
    strata_codes.each do |code|
      stratum_type = code.gsub(/\d/,'')
      puts stratum_type
      stratum_id = code.gsub(/\D/,'').to_i
      puts stratum_id
      begin
        result_strata << eval(mappings[stratum_type]).find(stratum_id)
      rescue Exception => e
        puts e.inspect
      end
    end
    return result_strata
  end

  def fetch_replaced_strata
    fetch_strata replaced_strata
  end

  def fetch_new_strata
    fetch_strata new_strata
  end

end
