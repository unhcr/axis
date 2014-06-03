module Parsers
  class IndicatorDataPerfParser < Parser

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
        :indicator_id => 'PERFINDICATOR_RFID',
        :id => 'PERFINDICATOR_ID',
        :yer => 'PERF_YEAR_END_VALUE',
        :myr => 'PERF_MID_YEAR_VALUE',
        :imp_target => 'PERF_IMP_TARGET',
        :comp_target => 'PERF_COMP_TARGET',
        :reversal => 'REVERSAL',
        :missing_budget => 'MISSING_BUDGET'
      }

    end

    def map_csvfields(row, *extract)
      hash = {}
      csvfields = IndicatorDataPerfParse.csvfields
      extract.each do |key|
        hash[key] = row[csvfields[key]]
      end
      hash
    end

    def parse(csv_filename)

      csvfields = IndicatorDataPerfParse.csvfields

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
