class Narrative < ActiveRecord::Base
  self.primary_key = :id
  include VisioModel
  extend AmountHelpers
  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :id, index: :not_analyzed
    indexes :usertxt
    indexes :operation_id, type: "string", index: :not_analyzed
    indexes :plan_id, type: "string", index: :not_analyzed
    indexes :goal_id, type: "string", index: :not_analyzed
    indexes :problem_objective_id, type: "string", index: :not_analyzed
    indexes :output_id, type: "string", index: :not_analyzed
    indexes :ppg_id, type: "string", index: :not_analyzed
    indexes :report_type, type: "string", index: :not_analyzed
    indexes :year, type: "integer"
  end

  attr_accessible :operation_id, :plan_id, :year, :goal_id, :problem_objective_id, :output_id,
    :ppg_id, :elt_id, :plan_el_type, :usertxt, :createusr, :id, :report_type, :is_deleted

  belongs_to :operation
  belongs_to :plan
  belongs_to :ppg
  belongs_to :goal
  belongs_to :output
  belongs_to :problem_objective

  SUMMARY_PREFIX = 'summary'

  def self.public_fields
    %w{id ppg_id goal_id output_id problem_objective_id operation_id report_type year usertxt}
  end

  def self.summarize(ids, report_type = nil, year = nil)
    report_type ||= 'Mid Year Report'
    year ||= Time.now.year

    args = ids.merge({ :report_type => report_type, :year => year })

    md5 = Digest::MD5.new
    md5.update args.to_json

    token = "#{SUMMARY_PREFIX}_#{md5.hexdigest}"

    Rails.logger.info "[REDIS] Enqueuing summarize job with token: #{token}"

    Resque.enqueue SummarizeJob, token, args

    token
  end

  def self.search_models(query, ids = {}, report_type = nil, year = nil, options = {})
    ids ||= {}
    return [] if query.nil? or query.empty?

    conditions = generate_conditions ids
    query_string = conditions.join(' AND ')

    options[:page] ||= 1
    options[:per_page] ||= 6

    options[:page] = options[:page].to_i

    result = self.search(options) do
      query { string "usertxt:#{query}" }

      [:operation_ids, :ppg_ids, :goal_ids, :problem_objective_ids, :output_ids].each do |key|
        next unless ids.has_key? key
        value = ids[key]
        terms = {}
        terms[key.to_s.singularize.to_sym] = value
        filter :terms, terms
      end

      filter :term, { :year => year.to_i } if year.present?
      filter :term, { :report_type => report_type } if report_type.present?

      highlight :usertxt
    end
    result
  end

  def self.total_characters(ids = {})
    conditions = generate_conditions ids
    query_string = conditions.join(' AND ')

    sql = "select sum(#{self.table_name}.usertxt_length) as total_characters
           from #{self.table_name}
           where is_deleted = false AND #{query_string}"

    ActiveRecord::Base.connection.execute(sql)
  end

  def self.clear_summary_cache
    keys = Redis.current.keys "#{SUMMARY_PREFIX}*"
    Redis.current.del keys
  end
end
