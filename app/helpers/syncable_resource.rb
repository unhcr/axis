module SyncableHelpers
  protected
    def resource
      self.class.to_s.delete('Controller').singularize.constantize
    end
end

module SyncableParameter
  include SyncableHelpers

  def synced
    synced_date = params[:synced_timestamp] ? Time.at(params[:synced_timestamp].to_i) : nil

    render :json => resource.synced_models(synced_date, params[:join_ids], nil, params[:where]).as_json
  end
end

module SyncableData
  include SyncableHelpers

  def synced
    synced_date = params[:synced_timestamp] ? Time.at(params[:synced_timestamp].to_i) : nil

    if params[:strategy_id]
      strategy = Strategy.find(params[:strategy_id])

      render :json => strategy.synced(resource, synced_date)
    else
      render :json => { :new => [], :updated => [], :deleted => [] }
    end

  end
end

module SyncableModel

  def synced_models(synced_date = nil, join_ids = {}, limit = nil, where = {})
    synced_models = {}

    if synced_date
      synced_models[:new] = self.where('created_at >= ? and is_deleted = false', synced_date).where(where).limit(limit)

      synced_models[:updated] = self.where('created_at < ? and updated_at >= ? and is_deleted = false', synced_date, synced_date).where(where).limit(limit)
      synced_models[:deleted] = self.where('is_deleted = true and updated_at >= ?', synced_date).where(where).limit(limit)
    else
      synced_models[:new] = self.where(:is_deleted => false).where(where).limit(limit)
      synced_models[:updated] = synced_models[:deleted] = self.limit(0)
    end

    if join_ids
      synced_models.each do |key, query|
        join_ids.each do |id_name, value|
          name = id_name.to_s.sub(/_id[s]*/, '')
          join_table = [self.table_name, name.pluralize].sort.join('_')
          table_name_singular = self.table_name.singularize
          synced_models[key] = query.joins(
            "inner join (select distinct(#{table_name_singular}_id) from #{join_table} where
            #{id_name.to_s.singularize} in ('#{Array(value).join("','")}')) as #{join_table}_rel
            on #{self.table_name}.id = #{join_table}_rel.#{table_name_singular}_id")
        end
      end
    end

    return synced_models
  end

end
