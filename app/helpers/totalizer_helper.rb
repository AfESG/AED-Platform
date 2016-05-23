module TotalizerHelper
  def totalizer(scope, filter, year)
    <<-SQL
      select
        e.category "CATEGORY",
        surveytype "SURVEYTYPE",
        round(sum(definite)) "DEFINITE",
        round(sum(probable)) "PROBABLE",
        round(sum(possible)) "POSSIBLE",
        round(sum(speculative)) "SPECUL"
      from estimate_locator e
        join estimate_dpps d on e.input_zone_id = d.input_zone_id
          and e.analysis_name = d.analysis_name
          and e.analysis_year = d.analysis_year
        join surveytypes t on t.category = e.category
        where e.analysis_name = '#{filter}' and e.analysis_year = '#{year}'
        and #{scope}
        and e.category='A'
      group by e.category, surveytype

      UNION

      select
        e.category "CATEGORY",
        surveytype "SURVEYTYPE",
        CASE WHEN SUM(actually_seen) > (SUM(e.population_estimate)-SQRT(SUM(population_variance))*1.96)
        THEN SUM(actually_seen)
        ELSE ROUND(SUM(e.population_estimate) - SQRT(SUM(population_variance))*1.96)
        END "DEFINITE",
        round(sqrt(sum(population_variance))*1.96) "PROBABLE",
        round(sqrt(sum(population_variance))*1.96) "POSSIBLE",
        round(sum(speculative)) "SPECUL"
      from estimate_locator e
        join estimate_dpps d on e.input_zone_id = d.input_zone_id
          and e.analysis_name = d.analysis_name
          and e.analysis_year = d.analysis_year
        join surveytypes t on t.category = e.category
        where e.analysis_name = '#{filter}' and e.analysis_year = '#{year}'
        and #{scope}
        and e.category='B'
      group by e.category, surveytype

      UNION

      select
        e.category "CATEGORY",
        surveytype "SURVEYTYPE",
        round(sum(definite)) "DEFINITE",
        round(sum(probable)-sum(definite)) "PROBABLE",
        round(sqrt(sum(population_variance))*1.96) "POSSIBLE",
        round(sum(speculative)) "SPECUL"
      from estimate_locator e
        join estimate_dpps d on e.input_zone_id = d.input_zone_id
          and e.analysis_name = d.analysis_name
          and e.analysis_year = d.analysis_year
        join surveytypes t on t.category = e.category
        where e.analysis_name = '#{filter}' and e.analysis_year = '#{year}'
        and #{scope}
        and e.category='C'
      group by e.category, surveytype

      UNION

      select
        e.category "CATEGORY",
        surveytype "SURVEYTYPE",
        round(sum(definite)) "DEFINITE",
        round(sum(probable)) "PROBABLE",
        round(sum(possible)) "POSSIBLE",
        round(sum(speculative)) "SPECUL"
      from estimate_locator e
        join estimate_dpps d on e.input_zone_id = d.input_zone_id
          and e.analysis_name = d.analysis_name
          and e.analysis_year = d.analysis_year
        join surveytypes t on t.category = e.category
        where e.analysis_name = '#{filter}' and e.analysis_year = '#{year}'
        and #{scope}
        and e.category='D'
      group by e.category, surveytype

      UNION

      select
        e.category "CATEGORY",
        surveytype "SURVEYTYPE",
        round(sum(definite)) "DEFINITE",
        round(sum(probable)) "PROBABLE",
        round(sum(possible)) "POSSIBLE",
        round(sum(speculative)) "SPECUL"
      from estimate_locator e
        join estimate_dpps d on e.input_zone_id = d.input_zone_id
          and e.analysis_name = d.analysis_name
          and e.analysis_year = d.analysis_year
        join surveytypes t on t.category = e.category
        where e.analysis_name = '#{filter}' and e.analysis_year = '#{year}'
        and #{scope}
        and e.category='E'
      group by e.category, surveytype

      order by "CATEGORY"
    SQL
  end
end