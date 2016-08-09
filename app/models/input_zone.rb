class InputZone < ActiveRecord::Base
  belongs_to :population

  def strata(year)
    sql = 'SELECT * FROM input_zone_export WHERE trim(inpzone) = ? and ayear = ?'
    execute(sql, name, year)
  end

  private
  def self.execute(*array)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    ActiveRecord::Base.connection.execute(sql)
  end

  def execute(*array)
    self.class.execute(*array)
  end
end
