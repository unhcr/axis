module IndicatorDataImpactParse

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

  def map_fields(row, *extract)
    hash = {}
    fields = IndicatorDataImpactParse.fields
    extract.each do |key|
      hash[key] = row[fields[key]]
    end
    hash
  end

  def parse(csv_filename)

    fields = IndicatorDataImpactParse.fields

    CSV.foreach(csv_filename, :headers => true) do |row|
      id = row[fields[:id]]
      values = map_fields row, :yer, :myr, :imp_target, :comp_target, :baseline, :indicator_type, :reversal,
        :threshold_green, :threshold_red

      i = nil
      if IndicatorDatum.exists? id
        i = IndicatorDatum.find id
        i.update_attributes values
      else
        i = IndicatorDatum.new
        i.id = id
        i.update_attributes map_fields(row, :plan_id, :operation_id, :ppg_id, :goal_id,
                                       :problem_objective_id, :output_id, :year)
        i.update_attributes values
      end

      i.save
      i.found
    end

  end

end
