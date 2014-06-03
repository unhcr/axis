module Parsers

  class IndicatorDataImpactParser < Parser
    def self.csvfields
      @csvfields = {
        :plan_id => 'PLANID',
        :year => 'PLANNINGYEAR',
        :operation_id => 'operation_id',
        :ppg_id => 'ORIGPOPGROUP_ID',
        :goal_id => 'RFGOALID',
        :rights_group_id => 'RFRIGHTSGROUPID',
        :problem_objective_id => 'RFPROBLEMOBJECTIVEID',
        :output_id => 'RFOUTPUTID',
        :indicator_id => 'IMPACTINDICATOR_RFID',
        :id => 'IMPINDICATOR_ID',
        :yer => 'IMP_YEAR_END_VALUE',
        :myr => 'IMP_MID_YEAR_VALUE',
        :imp_target => 'IMP_IMP_TARGET',
        :comp_target => 'IMP_COMP_TARGET',
        :baseline => 'IMP_BASELINE',
        :standard => 'IMP_STANDARD',
        :threshold_green => 'IMP_GREEN',
        :threshold_red => 'IMP_RED',
        :reversal => 'IMP_ISREVERSAL',
        :indicator_type => 'IMP_TYPE'
      }

    end

    def map_csvfields(row, *extract)
      hash = {}
      csvfields = IndicatorDataImpactParse.csvfields
      extract.each do |key|
        hash[key] = row[csvfields[key]]
      end
      hash
    end

    def parse(csv_filename)

      csvfields = IndicatorDataImpactParse.csvfields

      CSV.foreach(csv_filename, :headers => true, :col_sep => COL_SEP) do |row|
        next if row.empty?
        id = row[csvfields[:id]]

        (datum = IndicatorDatum.find_or_initialize_by_id(:id => id).tap do |d|
          csvfields.each do |rails_attr, csv_attr|
            d[rails_attr] = row[csv_attr]
          end
        end).save

        i.found
      end

    end

  end
end
