require 'iconv'
require 'roo'

xl = Excel.new("script/etl/mike_sites_replacement_data.xls")
xl.default_sheet = xl.sheets.first

ActiveRecord::Base.connection.execute <<-SQL
  delete from replacement_map
SQL

2.upto(xl.last_row) do |row|
  site = xl.cell(row,4).to_s
  from = xl.cell(row,7)
  if from.to_i == from
    from = from.to_i
  end
  from = from.to_s
  from.gsub! '+', ','
  from.gsub! /\s*,\s*/, ','
  from.gsub! /\s/, ''
  from.gsub! '(part)', ''

  to = xl.cell(row,8).to_s
  to.gsub! '+', ','
  to.gsub! /\s*,\s*/, ','
  to.gsub! /\s/, ''
  to.gsub! '(part)', ''

  if site == '' or from == '?' or (to == '' and from == '')
  else
    puts "#{site}: #{from} => #{to}"
    ActiveRecord::Base.connection.execute <<-SQL
      insert into replacement_map values ('#{site}','#{from}','#{to}')
    SQL
  end
end
