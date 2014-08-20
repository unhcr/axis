module Parsers
  # Abstract class
  class AmountParser < Parser
    AOL = 'Above Operating Level'
    OL = 'Operating Level'

    ADMIN = 'ADMIN'
    PARTNER = 'PARTNER'
    PROJECT = 'PROJECT'
    STAFF = 'STAFF'


    def parse(csv_filename)
      @relations = {
        GoalsOperations => [],
        GoalsPlans => [],
        GoalsPpgs => [],
        GoalsProblemObjectives => [],
        GoalsRightsGroups => [],
        GoalsIndicators => [],
        GoalsOutputs => [],
        OperationsOutputs => [],
        OperationsPpgs => [],
        OperationsProblemObjectives => [],
        OperationsRightsGroups => [],
        OutputsPlans => [],
        OutputsProblemObjectives => [],
        OutputsPpgs => [],
        PlansPpgs => [],
        PlansProblemObjectives => [],
        PlansRightsGroups => [],
        ProblemObjectivesRightsGroups => [],
        PpgsProblemObjectives => []
      }

      csvfields = self.class.csvfields

      columns = csvfields.keys.sort
      columns << :found_at
      values = []

      csv_foreach(csv_filename) do |row|
        next if row.empty?

        element = csv_parse_element csvfields, row

        values << element

        # Many-to-many relations
        @relations.each do |association, array|
          attrs = association.attribute_names.dup.sort.map &:to_sym
          attrs.delete :id
          fields = csvfields.select { |k, v| attrs.include? k }
          relation = csv_parse_element fields, row, false

          # only add if all attrs were found
          @relations[association] << relation if relation.length == attrs.length
        end
      end

      to_update = columns.dup
      to_update.delete :id

      self.class::MODEL.import columns, values, :on_duplicate_key_update => to_update

      p 'Importing Relations'
      # import relations
      @relations.each do |relation, array|
        columns = relation.attribute_names.dup.sort
        columns.delete 'id'
        relation.import columns, array, :on_duplicate_key_update => columns
      end
    end

    def csv_parse_element(csvfields, row, found_at = true)
      element = []

      csvfields.sort.each do |rails_attr, csvfield_attr|
        # If it's a lambda, call it
        if csvfield_attr.respond_to? :call
          element << instance_exec(row, &csvfield_attr)
        else
          element << row[csvfield_attr]
        end
      end

      # Add found_at parameter
      element << Time.now if found_at

      element
    end
  end
end

