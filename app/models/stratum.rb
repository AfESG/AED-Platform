# Methods common to all Stratum level objects. If the naming
# pattern typical of [base] and [base_strata] is used, these
# methods may be mixed in and used portably across Counts.
module Stratum
  def stratum_base_name
    self.class.name.underscore
  end
  def parent_count
    eval self.class.name.gsub('Stratum','').underscore
  end
end
