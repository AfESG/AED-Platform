module AnalysesHelper

  def link_estimate(e)
    out="<a target='_blank' href='"
    mappings={
      'AS' => '/survey_aerial_sample_count_strata/',
      'AT' => '/survey_aerial_total_count_strata/',
      'DC' => '/survey_dung_count_line_transect_strata/',
      'GD' => '/survey_faecal_dna_strata/',
      'GS' => '/survey_ground_sample_count_strata/',
      'GT' => '/survey_ground_total_count_strata/',
      'IR' => '/survey_individual_registrations/',
      'ME' => '/survey_modeled_extrapolations/',
      'O' => '/survey_others/'
    }
    u = "#{e}"
    mappings.each do |code,uri|
      u.gsub! code, uri
    end
    out << u
    out << "'>#{e}</a>"
  end

  def describe_change_strata(strata, year)
    return '-' if strata==nil or strata=='-' or strata==''
    out = ''
    strata.split(/,\s*/).each do |input_zone_id|
      estimate = @estimates[input_zone_id+'@'+year.to_s]
      if estimate
        out << "<div class='RM_stratum' data-stratum='#{input_zone_id}' data-year='#{year}'>"
        out << "<div>#{estimate['completion_year']} #{estimate['stratum_name']}</div>"
        out << "<div style='font-size: x-small'>Phenotype: #{estimate['phenotype']}</div>"
        out << "<div style='font-size: x-small'>#{estimate['short_citation']}</div>"
        out << "<div style='font-size: x-small'>#{link_estimate(estimate['input_zone_id'])} / cat #{estimate['category']}: est. #{estimate['population_estimate']}, #{estimate['stratum_area']} km²</div>"
        out << "</div>"
      else
        out << input_zone_id+'@'+year.to_s+"?"
      end
    end
    out
  end

  def dashify(strata)
    return '-' if strata == nil or strata.blank?
    strata
  end

end
