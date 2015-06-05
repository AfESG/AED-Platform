def execute(*array)
  sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
  return ActiveRecord::Base.connection.execute(sql)
end

puts 'fetching old production versions'
@production_versions = execute <<-SQL
  select * from production_versions
SQL

puts 'fetching current versions'
@versions = execute <<-SQL
  select * from versions
SQL

puts 'marking versions seen'
seen = {}
@versions.each do |row|
  seen[row['created_at']] = true
end

puts 'finding unmatched versions'
count = 0
@production_versions.each do |row|
  if !seen[row['created_at']]
    puts row.inspect
    count = count + 1
    @nv = Version.new
    @nv.item_type = row['item_type']
    @nv.item_id = row['item_id']
    @nv.event = row['event']
    @nv.whodunnit = row['whodunnit']
    @nv.object = row['object']
    @nv.created_at = row['created_at']
    @nv.object_changes = row['object_changes']
    @nv.save!
  end
end

puts "inserted #{count} unmatched versions of #{@production_versions.count}"

