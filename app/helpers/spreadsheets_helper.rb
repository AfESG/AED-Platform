module SpreadsheetsHelper

  def hash_tuples result
    hash = {}
    result.each do |row|
      hash[row['CATEGORY']] = row
    end
    hash
  end

end
