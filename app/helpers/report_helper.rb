module ReportHelper

  def signed_number(n, opts={})
    defaults = { positive: '+', negative: '' }
    defaults.merge!(opts) { |k,d,o| o.blank?? d : o }
    if n.nil?
      '0'
    else
      number = n.to_i
      if number.nil? or number == 0
        '0'
      elsif number.to_i>0
        "#{defaults[:positive]}#{number_with_delimiter number}".html_safe
      else
        "#{defaults[:negative]}#{number_with_delimiter number}".html_safe
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

  # TODO stupid ampersand trick
  def authify(authors)
    formatted_authors = []
    individual_authors = authors.split(';')
    individual_authors.each do |name|
      names = name.split(',')
      if names.length>1
        formatted_first_names = []
        first_names = names[1].split(' ')
        first_names.each do |first_name|
          formatted_first_names << "#{first_name[0]}."
        end
        names[1] = formatted_first_names.join ' '
      end
      formatted_authors << names.join(', ')
    end
    result = formatted_authors.join(", ")
    unless result =~ /\.$/
      result = result + "."
    end
    result
  end

  def format_reference(ref)
    formatted = []
    formatted << authify(ref["Authors"])
    formatted << " ("
    formatted << ref["Year_pub"]
    formatted << ")."
    if ref["Ref_type"] == "Personal Communication"
      formatted << " "
      formatted << ref["Ref_type"]
      formatted << ":"
    end
    formatted << " "
    formatted << ref["Title"]
    if ref["Type_work"] != "PDF document" and ref["Type_work"] != "Letter" and ref["Type_work"] != "Unpublished Report" and ref["Type_work"] != "Verbal information" and !ref["Type_work"].blank?
      formatted << " ("
      formatted << ref["Type_work"]
      formatted << ")"
    end
    formatted << "."
    unless ref["Place_pub"].blank?
      formatted << " "
      formatted << ref["Place_pub"]
      formatted << ": "
    end
    unless ref["Publisher"]==ref["Authors"] or ref["Publisher"].blank?
      formatted << " "
      formatted << ref["Publisher"]
      formatted << "."
    end
    url_shown = false
    if ref["Type_work"] == "PDF document"
      url_shown = true
      formatted << " Retrieved "
      formatted << ref["Number"] # TODO strftime
      formatted << ", from "
      formatted << link_to(ref["Url"], ref["Url"])
      formatted << "."
    end
    if ref["Type_work"] == "Letter"
      formatted << " Letter to "
      formatted << authify(ref["Sec_authors"])
      formatted << ", "
      formatted << ref["Date_pub"] # TODO strftime
      formatted << "."
    end
    if ref["Type_work"] == "Verbal information"
      formatted << " Verbal information to "
      formatted << authify(ref["Sec_authors"])
      formatted << ", "
      formatted << ref["Date_pub"] # TODO strftime
      formatted << "."
    end
    unless url_shown
      unless ref["Url"].blank?
        formatted << " URL: "
        formatted << link_to(ref["Url"], ref["Url"])
        formatted << "."
      end
    end
    formatted.join
  end

end
