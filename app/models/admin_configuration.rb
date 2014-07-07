class AdminConfiguration < ActiveRecord::Base
  attr_accessible :startyear, :endyear, :default_reported_type, :default_aggregation_type, :default_date, :default_use_local_storage

  validates :startyear, :inclusion => { :in => [2012, 2013, 2014, 2015, 2016, 2017, 2018] }
  validates :endyear, :inclusion => { :in => [2012, 2013, 2014, 2015, 2016, 2017, 2018] }
  validates :default_reported_type, :inclusion => { :in => ['myr', 'yer'] }
  validates :default_aggregation_type, :inclusion => { :in => ['operations', 'ppgs', 'goals',
                                                   'outputs', 'problem_objectives'] }

  validate do |config|
    if (AdminConfiguration.count > 0 and config.new_record?) or
        (not config.new_record? and AdminConfiguration.count > 1)
      errors.add(:base, "You can only have one AdminConfiguration")
    end

    if config.startyear >= endyear
      errors.add(:base, "Startyear must be less than end year")
    end

    if config.default_date < config.startyear or config.default_date > config.endyear
      errors.add(:base, "Date should be inbetween start and end year")
    end
  end

  def to_jbuilder(options = {})

    Jbuilder.new do |json|
      json.extract! self, :startyear, :endyear, :default_reported_type, :default_aggregation_type, :default_date, :default_use_local_storage
    end

  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end

end
