module ReportHelper

  def signed_number(n)
    number = n.to_i
    if number.nil? or number == 0
      '0'
    elsif number.to_i>0
      "+#{number_with_delimiter number}"
    else
      "#{number_with_delimiter number}"
     end
  end

end
