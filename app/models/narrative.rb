class Narrative < ActiveRecord::Base
  self.primary_key = :id
  include SyncableModel
  attr_accessible :operation_id, :plan_id, :year, :goal_id, :problem_objective_id, :output_id,
    :ppg_id, :elt_id, :plan_el_type, :usertxt, :createusr, :id, :report_type

  belongs_to :operation
  belongs_to :plan
  belongs_to :ppg
  belongs_to :goal
  belongs_to :output
  belongs_to :problem_objective

  ARG_PREFIX = 'pyarguments'
  SUMMARY_PREFIX = 'summary'


  def self.summarize(ids)

    md5 = Digest::MD5.new
    md5.update ids.to_json

    token = "#{ARG_PREFIX}_#{md5.hexdigest}"

    summary_token = "#{SUMMARY_PREFIX}_#{md5.hexdigest}"
    summary = summary_token.get(summary_token)

    return summary if summary

    Rails.logger.info "[REDIS] Enqueuing summarize job with token: #{token}"

    Redis.current.set token, ids.to_json

    Resque.enqueue SummarizeJob, token

    nil
  end
end
