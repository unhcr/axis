class StrategyObjective < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks

  attr_accessible :description, :name
  belongs_to :strategy

  def self.parameters
    [Goal, ProblemObjective, Output, Indicator]
  end

  default_scope :include => [parameters.map { |p| p.table_name.to_sym }]

  self.parameters.each do |p|
    through = [p.table_name, 'strategy_objectives'].sort.join('_').to_sym
    class_name = [p.to_s.pluralize, StrategyObjective.to_s.pluralize].sort.join

    has_many through, :class_name => class_name
    has_many p.table_name.to_sym, :uniq => true, :through => through,
      :after_add => [:add_to_strategy, :touch_data],
      :after_remove => [:remove_from_strategy, :touch_data]

  end

  def add_to_strategy(assoc)
    self.strategy.send(assoc.class.table_name) << assoc if self.strategy
  end

  def touch_data(assoc)
    assoc.touch :updated_at
    assoc.touch_data self
  end

  def remove_from_strategy(assoc)
    included = false
    name = assoc.class.table_name
    if self.strategy
      self.strategy.strategy_objectives.each do |so|
        included = true if so.send(name).include? assoc and so != self
      end
      self.strategy.send(name).delete(assoc) unless included
    end
    assoc.touch_data self
  end

  def self.search_models(query, options = {})
    return [] if !query || query.empty?
    options[:page] ||= 1
    options[:per_page] ||= 6
    s = self.search(options) do
      query { string "name:#{query}" }

      highlight :name
    end
    s
  end

  def synced(resource = IndicatorDatum, synced_date = nil, limit = nil, where = {})
    ids = {
      :goal_ids => self.goal_ids,
      :problem_objective_ids => self.problem_objective_ids,
      :output_ids => self.output_ids,
    }

    ids[:indicator_ids] = self.indicator_ids if resource == IndicatorDatum

    resource.synced_models(ids, synced_date, limit, where)
  end

  def data(resource = IndicatorDatum, limit = nil, where = {})
    synced(resource, nil, limit, where)[:new]
  end

  def to_jbuilder(options = {})
    options ||= {}
    options[:include] ||= {}
    Jbuilder.new do |json|
      json.extract! self, :name, :id, :description, :strategy_id

      json.goals self.goals
      json.problem_objectives self.problem_objectives
      json.outputs self.outputs
      json.indicators self.indicators


      if options[:include][:ids].present?
        json.goal_ids self.goal_ids.inject({}) { |h, id| h[id] = true; h }
        json.output_ids self.output_ids.inject({}) { |h, id| h[id] = true; h }
        json.problem_objective_ids self.problem_objective_ids.inject({}) { |h, id| h[id] = true; h }
        json.indicator_ids self.indicator_ids.inject({}) { |h, id| h[id] = true; h }
      end
    end
  end

  def to_json(options = {})
    to_jbuilder(options).target!
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
