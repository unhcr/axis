class IndicatorDatum < ActiveRecord::Base
  attr_accessible :baseline, :comp_target, :reversal, :standard, :stored_baseline, :threshold_green, :threshold_red, :yer

  self.primary_key = :id
  belongs_to :indicator
  belongs_to :output
  belongs_to :problem_objective
  belongs_to :rights_group
  belongs_to :goal
  belongs_to :ppg
  belongs_to :plan
  belongs_to :operation

  QUERY_STRING = 'plan_id IN (:plan_ids) AND
      ppg_id IN (:ppg_ids) AND
      goal_id IN (:goal_ids) AND
      (problem_objective_id IN (:problem_objective_ids) OR output_id IN (:output_ids)) AND
      indicator_id IN (:indicator_ids) '


  def self.synced_data(ids = {}, synced_date = nil, limit = nil, where = {})

    synced_data = {}
    if synced_date
      synced_data[:new] = IndicatorDatum.where("#{QUERY_STRING} AND
        is_deleted = false", ids.merge({ :synced_date => synced_date }))
          .where(where).limit(limit)
      synced_data[:updated] = IndicatorDatum.where("#{QUERY_STRING} AND
        created_at < (:synced_date) AND
        updated_at >= (:synced_date) AND
        is_deleted = false", ids.merge({ :synced_date => synced_date }))
          .where(where).limit(limit)
      synced_data[:deleted] = IndicatorDatum.where("#{QUERY_STRING} AND
        updated_at >= (:synced_date) AND
        is_deleted = true", ids.merge({ :synced_date => synced_date }))
          .where(where).limit(limit)
    else
      synced_data[:new] = IndicatorDatum.where("#{QUERY_STRING} AND is_deleted = false")
        .where(where).limit(limit)
      synced_data[:updated] = synced_data[:deleted] = IndicatorDatum.limit(0)
    end

    return data

  end
end
