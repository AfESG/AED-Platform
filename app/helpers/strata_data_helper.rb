module StrataDataHelper
  def get_strata_data(strcode)
    type, id = strcode.match(/^([A-Z]+)(\d+)$/)[1..2]
    case type
      when 'GT'
        sql = ground_total_sql
      when 'DC'
        sql = dung_count_sql
      when 'AT'
        sql = aerial_total_sql
      when 'GS'
        sql = ground_sample_sql
      when 'AS'
        sql = aerial_sample_sql
      when 'GD'
        sql = faecal_dna_sql
      when 'IR'
        sql = individual_sql
      when 'O'
        sql = others_sql
      else
        return { error: 'unknown survey type' }
    end
    execute(sql, id)
  end

  private
  def ground_total_sql
    'SELECT * FROM survey_ground_total_count_strata WHERE id = ?'
  end

  def dung_count_sql
    'SELECT * FROM survey_dung_count_line_transect_strata WHERE id = ?'
  end

  def aerial_total_sql
    'SELECT * FROM survey_aerial_total_count_strata WHERE id = ?'
  end

  def ground_sample_sql
    'SELECT * FROM survey_ground_sample_count_strata WHERE id = ?'
  end

  def aerial_sample_sql
    'SELECT * FROM survey_aerial_sample_count_strata WHERE id = ?'
  end

  def faecal_dna_sql
    'SELECT * FROM survey_faecal_dna_strata WHERE id = ?'
  end

  def individual_sql
    'SELECT * FROM survey_individual_registrations WHERE id = ?'
  end

  def others_sql
    'SELECT * FROM survey_others WHERE id = ?'
  end
end
