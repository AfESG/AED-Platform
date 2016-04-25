class AddSortKeyToChanges < ActiveRecord::Migration
  def p_execute(*array)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    return ActiveRecord::Base.connection.execute(sql)
  end
  def up
    add_column :changes, :sort_key, :string
    p_execute <<-SQL
      update changes set population = '' where population is null;
      update changes set sort_key = population || replacement_name
    SQL
  end
  def down
    remove_column :changes, :sort_key
  end
end
