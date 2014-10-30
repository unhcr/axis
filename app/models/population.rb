class Population < ActiveRecord::Base
  attr_accessible :ppg_code, :value, :year, :element_id, :element_type, :ppg_id

  def self.models_optimized(ids = {}, limit = nil, where = nil, offset = nil)

    conditions = ''
    conditions = "element_id IN ('#{ids.values.flatten.join("','")}')" if ids

    sql = "select array_to_json(array_agg(row_to_json(t)))
      from (
        select
          #{self.table_name}.ppg_id,
          #{self.table_name}.value,
          #{self.table_name}.element_type,
          #{self.table_name}.element_id,
          #{self.table_name}.year
        from #{self.table_name}
        where #{conditions}
      ) t
      "

    sql += " LIMIT #{sanitize(limit)}" unless limit.nil?
    sql += " OFFSET #{sanitize(offset)}" unless offset.nil?


    ActiveRecord::Base.connection.execute(sql)
  end

  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :ppg_id, :ppg_code, :element_id, :element_type, :year, :value
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end

end
