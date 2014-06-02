module IndicatorDataPerfParse

  def self.fields
    {
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
      :comp_target => 'PERF_COMP_TARGET'
    }

  end

  def map_fields(row, *extract)
    hash = {}
    fields = IndicatorDataPerfParse.fields
    extract.each do |key|
      hash[key] = row[fields[key]]
    end
    hash
  end

  def parse(csv_filename)

    fields = IndicatorDataPerfParse.fields

    CSV.foreach(csv_filename, :headers => true) do |row|
      id = row[fields[:id]]
      values = map_fields row, :yer, :myr, :imp_target, :comp_target

      i = nil
      if IndicatorDatum.exists? id
        i = IndicatorDatum.find id
        i.update_attributes values
      else
        i = IndicatorDatum.new
        i.id = id
        i.is_performance = true
        i.update_attributes map_fields(row, :plan_id, :operation_id, :ppg_id, :goal_id,
                                       :problem_objective_id, :output_id, :year)
        i.update_attributes values
      end

      i.save
      i.found
    end

  end

end
