class FetchMonitor < ActiveRecord::Base
  attr_accessible :starttime, :plans

  serialize :plans, Array

  MONITOR_STATES = {
    :incomplete => 'incomplete',
    :complete => 'complete',
    :error => 'error',
    :not_found => 'not found'
  }

  def validate
    errors.add_to_base "You can only have one FetchMonitor" unless FetchMonitor.count == 0
  end

  def reset(ids)
    self.starttime = Datetime.now

    self.mark_deleted
    self.plans = ids.map { |id| { :id => id, :state => MONITOR_STATES[:incomplete] } }

    self.save
  end

  def mark_deleted
    return unless self.starttime

    Plan.where('updated_at < ?', self.starttime).update_attribute(:is_deleted, true)
    Ppg.where('updated_at < ?', self.starttime).update_attribute(:is_deleted, true)
    Goal.where('updated_at < ?', self.starttime).update_attribute(:is_deleted, true)
    RightsGroup.where('updated_at < ?', self.starttime).update_attribute(:is_deleted, true)
    ProblemObjective.where('updated_at < ?', self.starttime).update_attribute(:is_deleted, true)
    Output.where('updated_at < ?', self.starttime).update_attribute(:is_deleted, true)
    Indicator.where('updated_at < ?', self.starttime).update_attribute(:is_deleted, true)
    IndicatorDatum.where('updated_at < ?', self.starttime).update_attribute(:is_deleted, true)

    Plan.where('updated_at >= ?', self.starttime).update_attribute(:is_deleted, false)
    Ppg.where('updated_at >= ?', self.starttime).update_attribute(:is_deleted, false)
    Goal.where('updated_at >= ?', self.starttime).update_attribute(:is_deleted, false)
    RightsGroup.where('updated_at >= ?', self.starttime).update_attribute(:is_deleted, false)
    ProblemObjective.where('updated_at >= ?', self.starttime).update_attribute(:is_deleted, false)
    Output.where('updated_at >= ?', self.starttime).update_attribute(:is_deleted, false)
    Indicator.where('updated_at >= ?', self.starttime).update_attribute(:is_deleted, false)
    IndicatorDatum.where('updated_at >= ?', self.starttime).update_attribute(:is_deleted, false)
  end

  def reset?
    count = self.plans.count do |plan|
      plan[:state] == MONITOR_STATES[:not_found] || plan[:state] == MONITOR_STATES[:complete]
    end

    count == self.plans.count
  end

  def complete?(id)
    p = plan(id)
    return false unless p

    return p[:state] == MONITOR_STATES[:complete]
  end

  def set_state(id, state)
    p = plan(id)
    p[:state] = state
    self.save
  end

  def plan(id)
    plan = (self.plans.select { |p| p[:id] == id }).first
  end
end
