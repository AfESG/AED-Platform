module NarrativeBoilerplates
  extend ActiveSupport::Concern

  def narrative_boilerplate(year)
    add_data = add(year) # TODO custom query here may be faster
    summary_sums = add_data[:summary_sums].first
    ranges = add_data[:areas].first

    unless summary_sums
      return "No estimate available for #{name}." # TODO figure out what to do in this case
    end

    name = to_s
    estimate = summary_sums['ESTIMATE']
    confidence = summary_sums['CONFIDENCE'].to_f.round
    boilerplate = ["The estimated number of elephants in areas surveyed in the last ten years in
    #{name} is #{estimate} &plusmn; #{confidence} (95% CL) at the time of the last survey for each area."]

    guesses_from = summary_sums['GUESS_MIN'].to_f.round
    guesses_to = summary_sums['GUESS_MAX'].to_f.round
    if guesses_from > 0
      guesses = guesses_from != guesses_to ? "#{guesses_from} to #{guesses_to}" : guesses_from
      boilerplate << "There may be an additional #{guesses} elephants in areas
      not systematically surveyed in #{name}. These guesses likely represent a minimum number, and actual
      numbers could be higher than those reported."
    end

    area = ranges['range_area'].to_f.round
    pct_assessed = ranges['percent_range_assessed'].to_f.round
    boilerplate << "Together, this estimate and guess apply to #{area} km&sup2;, which is #{pct_assessed}%
    of the estimated known and possible elephant range in #{name}."
    if pct_assessed < 100
      boilerplate << "There remains an additional #{100 - pct_assessed}% of the estimated known and possible
      elephant range in #{name} for which no elephant population estimates are available."
    end

    boilerplate.join(' ').gsub(/\n\s+/, "\s")
  end
end
