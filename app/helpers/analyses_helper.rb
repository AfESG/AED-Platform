module AnalysesHelper

  def describe_change_strata(strata, year)
    return '-' if strata=='-' or strata==''
    out = ''
    strata.split(/,\s*/).each do |input_zone_id|
      estimate = @estimates[input_zone_id+'@'+year.to_s]
      if estimate
        out << "<div class='RM_stratum RM_clickable' data-stratum='#{input_zone_id}' data-year='#{year}'>"
        out << "<div>#{estimate['completion_year']} #{estimate['stratum_name']}</div>"
        out << "<div style='font-size: x-small'>#{estimate['short_citation']}</div>"
        out << "<div style='font-size: x-small'>#{estimate['estimate_type']} / cat #{estimate['category']}: est. #{estimate['population_estimate']}, #{estimate['stratum_area']} km²</div>"
        out << "</div>"
      else
        out << input_zone_id+'@'+year.to_s+"?"
      end
    end
    out
  end

end
