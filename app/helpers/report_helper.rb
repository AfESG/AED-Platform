module ReportHelper

  def signed_number(n)
    if n.nil?
      '0'
    else
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

  def number_or_zero(n)
    if n.nil?
      '0'
    else
      "#{number_with_delimiter n}"
    end
  end

end
