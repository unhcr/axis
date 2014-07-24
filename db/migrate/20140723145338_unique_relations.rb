class UniqueRelations < ActiveRecord::Migration
  def up
    relations = {
      GoalsOperations => [],
      GoalsPlans => [],
      GoalsPpgs => [],
      GoalsProblemObjectives => [],
      GoalsRightsGroups => [],
      IndicatorsOperations => [],
      IndicatorsOutputs => [],
      IndicatorsPlans => [],
      IndicatorsProblemObjectives => [],
      OperationsOutputs => [],
      OperationsPpgs => [],
      OperationsProblemObjectives => [],
      OperationsRightsGroups => [],
      OutputsPlans => [],
      OutputsProblemObjectives => [],
      PlansPpgs => [],
      PlansProblemObjectives => [],
      PlansRightsGroups => [],
      ProblemObjectivesRightsGroups => [],
    }

    relations.each do |r, dummy|
      # Ensure all relations are gone
      r.delete_all

      name = r.to_s.underscore.to_sym
      index_name = name.to_s + '_uniq'

      unless index_exists? name, r.attribute_names.map(&:to_sym), :name => index_name
        add_index name, r.attribute_names.map(&:to_sym), :unique => true, :name => index_name
      end
    end
  end

  def down
    relations = {
      GoalsOperations => [],
      GoalsPlans => [],
      GoalsPpgs => [],
      GoalsProblemObjectives => [],
      GoalsRightsGroups => [],
      IndicatorsOperations => [],
      IndicatorsOutputs => [],
      IndicatorsPlans => [],
      IndicatorsProblemObjectives => [],
      OperationsOutputs => [],
      OperationsPpgs => [],
      OperationsProblemObjectives => [],
      OperationsRightsGroups => [],
      OutputsPlans => [],
      OutputsProblemObjectives => [],
      PlansPpgs => [],
      PlansProblemObjectives => [],
      PlansRightsGroups => [],
      ProblemObjectivesRightsGroups => [],
    }

    relations.each do |r, dummy|
      name = r.to_s.underscore.to_sym

      index_name = name.to_s + '_uniq'

      # Ensure all relations are gone
      if index_exists? name, r.attribute_names.map(&:to_sym), :name => index_name
        remove_index name, r.attribute_names.map(&:to_sym), :name => index_name
      end
    end
  end
end
