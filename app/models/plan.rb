class Plan < ActiveRecord::Base
  include SyncableModel

  attr_accessible :name, :operation_name, :year, :operation_id

  self.primary_key = :id
  has_and_belongs_to_many :ppgs, :uniq => true
  has_and_belongs_to_many :indicators, :uniq => true
  has_and_belongs_to_many :outputs, :uniq => true
  has_and_belongs_to_many :problem_objectives, :uniq => true
  has_and_belongs_to_many :rights_groups, :uniq => true
  has_and_belongs_to_many :goals, :uniq => true
  has_and_belongs_to_many :strategies, :uniq => true


  has_many :indicator_data
  has_many :budgets

  belongs_to :operation
  belongs_to :country

  default_scope { includes([:country]) }

  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :name, :operation_name, :year, :id, :operation_id

      if options[:include]

        if options[:include][:counts]
          json.indicators_count self.indicators.length
          json.goals_count self.goals.length
          json.ppgs_count self.ppgs.length
          json.outputs_count self.outputs.length
          json.problem_objectives_count self.problem_objectives.length
        end

        if options[:include][:situation_analysis]
          json.situation_analysis self.situation_analysis
        end

      end

      json.country self.country
    end
  end

  def impact_indicators
    @impact_indicators ||= self.indicators.where(:is_performance => false)
    @impact_indicators
  end

  def situation_analysis(reported_value = IndicatorDatum::REPORTED_VALUES[:myr])
    indicator_data = self.indicator_data.where(:is_performance => false)
    indicator_data.situation_analysis(indicator_data, reported_value)
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
