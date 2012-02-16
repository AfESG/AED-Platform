# Methods common to all Count level objects.  If the naming
# pattern typical of [base] and [base_strata] is used, these
# methods may be mixed in and used portably across Counts.
module Count
  def count_base_name
    self.class.name.underscore
  end
  def new_stratum
    eval "#{count_base_name}_stratum.new"
  end
  def strata
    begin
      return eval "#{count_base_name}_strata"
    rescue
      return {}
    end
  end
  def has_strata?
    true
  end
end
