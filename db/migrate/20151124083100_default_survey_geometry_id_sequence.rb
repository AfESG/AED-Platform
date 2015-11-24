class DefaultSurveyGeometryIdSequence < ActiveRecord::Migration
  def up
    execute <<-SQL
      create sequence survey_geometries_id_seq;
      alter table survey_geometries alter column id set default nextval('survey_geometries_id_seq'::regclass);
      select setval('survey_geometries_id_seq', (select max(id) from survey_geometries));
    SQL
  end
  def down
    execute <<-SQL
      drop sequence survey_geometries_id_seq cascade;
    SQL
  end
end
