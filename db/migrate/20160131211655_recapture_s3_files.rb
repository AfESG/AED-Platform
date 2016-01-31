require 'find'

class RecaptureS3Files < ActiveRecord::Migration
  def change
    file_paths = []
    Find.find('/u/s3') do |path|
      file_paths << path
    end
    PopulationSubmissionAttachment.order(:id).each do |psa|
      fn = psa.file_file_name
      next if fn and fn.empty?
      file_paths.each do |file_path|
        if file_path.end_with? "#{psa.id}/#{fn}"
          puts "#{psa.id}: found #{fn} at #{file_path}"
          File.open(file_path) do |f|
            psa.file = f
            begin
              psa.save!
            rescue
              puts "NOTICE: Could not save #{psa.id} -- please check file content"
            end
          end
          break
        end
      end
    end
  end
end
