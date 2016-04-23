class PopulateRangePreviews < ActiveRecord::Migration
  def p_execute(*array)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    return ActiveRecord::Base.connection.execute(sql)
  end
  def up
    p_execute <<-SQL
      delete from range_previews;
    SQL

    p_execute <<-SQL
      insert into range_previews
        (range_type,
         status,
         original_comments,
         source_year,
         published_year,
         geom,
         created_at,
         updated_at)
      select
        rangetype,
        'Needs review',
        comments || comments_1,
        sourceyear,
        publisyear,
        geom,
        NOW(),
        NOW()
      from
        "2014_rangetypeupdates5_final"
    SQL
  end
end
