class UpdateReportNarratives < ActiveRecord::Migration
  def change

    reversible do |dir|
      dir.up do

        ReportNarrative.all.each do |rn|

          if rn.uri.start_with?('_report/2013_africa/')
            rn.uri.sub!('_report/2013_africa/', '')
            rn.save!
          end

          if rn.uri.start_with?('_report/2013_africa_final/')
            rn.uri.sub!('_report/2013_africa_final/', '')
            rn.save!
          end

        end

      end # up

      dir.down do
        raise ActiveRecord::IrreversibleMigration
      end # down
    end # reversible

  end
end
