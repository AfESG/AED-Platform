class StratumLevelValidator < ActiveModel::Validator
  def validate(record)
    if record.surveyed_at_stratum_level.nil?
      record.errors[:surveyed_at_stratum_level] << "can't be blank"
    end
    if record.surveyed_at_stratum_level.nil?
      record.errors[:stratum_level_data_submitted] << "can't be blank"
    end
  end
end
