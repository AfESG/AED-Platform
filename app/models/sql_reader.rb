class SqlReader

  def self.parse path, &block
    file = File.open path, 'r'
    sql = ''
    stopped = false
    found = false
    file.readlines.each do |current|
      break if stopped

      line = current.rstrip

      if line.start_with? '##', '--'
        next
      end

      sql << line
      sql << "\n" unless line.blank?
      if line.end_with?(';')
        found = true
        begin
          yield sql
        rescue Exception => e
          puts e.inspect
          puts "Failed on query: #{sql}"
          stopped = true
        end
        sql = ''
      end
    end

    file.close

    if !found && !sql.blank?
      begin
        yield sql
      rescue
        puts "Failed on query: #{sql}"
        stopped = true
      end
    end

    if stopped
      raise Exception.new "Could not run SQL update on all queries in #{path}"
    end
  end


end
