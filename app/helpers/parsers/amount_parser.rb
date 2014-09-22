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
      @relations = [
        GoalsOperations,
        GoalsOutputs,
        GoalsProblemObjectives,
        OperationsOutputs,
        OperationsPpgs,
        OperationsProblemObjectives,
        OutputsPlans,
        OutputsProblemObjectives,
        OutputsPpgs,
        PpgsProblemObjectives
      ]

      model = self.class::MODEL

      csvfields = self.class.csvfields

      Upsert.batch(ActiveRecord::Base.connection, model.table_name.to_sym) do |upsert|
        csv_foreach(csv_filename) do |row|
          next if row.empty?

          element = csv_parse_element csvfields, row

          selector = element.dup
          selector.keep_if { |k, v| self.class.selector.include? k }

          setter = element.dup
          setter.keep_if { |k, v| !self.class.selector.include?(k) }

          upsert.row selector, setter

        end
      end

      @relations.each do |association|
        p "Parsing #{association.to_s}"
        Upsert.batch(ActiveRecord::Base.connection, association.table_name.to_sym) do |upsert|
          csv_foreach(csv_filename) do |row|
            next if row.empty?

            attrs = association.attribute_names.map &:to_sym

            relation = {}

            attrs.each { |attr| relation[attr] = row[csvfields[attr]] }

            upsert.row relation, {} if relation.values.all? { |v| v.present? }
          end
        end
      end

    end

  end
end

