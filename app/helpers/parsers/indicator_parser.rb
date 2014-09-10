module Parsers
  # Abstract class for indicator parsers
  class IndicatorParser < Parser

    def parse(csv_filename)
      super csv_filename

      relations = self.class.relations
      relations.each do |r|
        Upsert.batch(ActiveRecord::Base.connection, r.table_name.to_sym) do |upsert|
          csv_foreach(csv_filename) do |row|
            next if row.empty?

            names = r.attribute_names.map &:to_sym
            names.delete :indicator_id
            other_id = names[0]

            element = {
              :indicator_id => row[self.class.csvfields[:id]],
            }
            element[other_id] = row[self.class.relationfields[other_id]]

            selector = element.dup

            next if selector.values.any? { |v| v.nil? }

            upsert.row selector, {}
          end
        end
      end
    end

  end
end
