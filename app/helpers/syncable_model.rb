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
        synced_models[key] = join_habtm(query, join_ids)
      end
    end

    synced_models
  end

  def models(join_ids, page = nil, where = {})
    models = self.where(where)
    models = models.page unless page.nil?
    models = join_habtm(models, join_ids) if join_ids

    models
  end

  private

    def join_habtm(query, join_ids)
      join_ids.each do |id_name, value|
        name = id_name.to_s.sub(/_id[s]*/, '')
        join_table = [self.table_name, name.pluralize].sort.join('_')
        table_name_singular = self.table_name.singularize
        query = query.joins(
          "inner join (select distinct(#{table_name_singular}_id) from #{join_table} where
          #{id_name.to_s.singularize} in ('#{Array(value).join("','")}')) as #{join_table}_rel
          on #{self.table_name}.id = #{join_table}_rel.#{table_name_singular}_id")
      end

      query
    end

end

