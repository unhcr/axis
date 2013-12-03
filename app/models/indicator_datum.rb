class IndicatorDatum < ActiveRecord::Base
  attr_accessible :baseline, :comp_target, :reversal, :standard, :stored_baseline, :threshold_green, :threshold_red, :yer, :myr

  self.primary_key = :id
  belongs_to :indicator
  belongs_to :output
  belongs_to :problem_objective
  belongs_to :rights_group
  belongs_to :goal
  belongs_to :ppg
  belongs_to :plan
  belongs_to :operation



  def self.synced_data(ids = {}, synced_date = nil, limit = nil, where = {})

    synced_data = {}

    query_string = "plan_id IN ('#{ids[:plan_ids].join("','")}') AND
      ppg_id IN ('#{(ids[:ppg_ids] || []).join("','")}') AND
      goal_id IN ('#{(ids[:goal_ids] || []).join("','")}') AND
      (problem_objective_id IN ('#{(ids[:problem_objective_ids] || []).join("','")}') OR output_id IN ('#{(ids[:output_ids] || []).join("','")}')) AND
      indicator_id IN ('#{(ids[:indicator_ids] || []).join("','")}')"

    if synced_date
      synced_data[:new] = IndicatorDatum.where("#{query_string} AND
        created_at >= :synced_date AND
        is_deleted = false", { :synced_date => synced_date })
          .where(where).limit(limit)
      synced_data[:updated] = IndicatorDatum.where("#{query_string} AND
        created_at < :synced_date AND
        updated_at >= :synced_date AND
        is_deleted = false", { :synced_date => synced_date })
          .where(where).limit(limit)
      synced_data[:deleted] = IndicatorDatum.where("#{query_string} AND
        updated_at >= :synced_date AND
        is_deleted = true", { :synced_date => synced_date })
          .where(where).limit(limit)
    else
      synced_data[:new] = IndicatorDatum.where("#{query_string} AND is_deleted = false")
        .where(where).limit(limit)
      synced_data[:updated] = synced_data[:deleted] = IndicatorDatum.limit(0)
    end

    return synced_data

  end
end
