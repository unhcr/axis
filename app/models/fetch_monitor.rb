class FetchMonitor < ActiveRecord::Base
  attr_accessible :starttime

  validate do |monitor|
    if (FetchMonitor.count > 0 and monitor.new_record?) or
        (not monitor.new_record? and FetchMonitor.count > 1)
      errors.add(:base, "You can only have one FetchMonitor")
    end
  end

  def mark_deleted
    return unless self.starttime

    parameters = [Plan, Ppg, Goal, RightsGroup, ProblemObjective, Output, Indicator,
      IndicatorDatum, Budget, Expenditure, Narrative]

    parameters.each do |parameter|
      to_delete = parameter.where('found_at < ?', self.starttime).all
      to_undelete = parameter.where('found_at >= ?', self.starttime).all

      to_delete.each do |p|
        p.update_column(:is_deleted, true)
      end
      to_undelete.each do |p|
        p.update_column(:is_deleted, false)
      end
    end
  end
end
