module Parameter

  def synced_models(synced_date = nil, models = nil, limit = 200, where = {})
    synced_models = {}

    if synced_date
      synced_models[:new] = (models || self).where('created_at >= ? and is_deleted = false', synced_date).where(where).limit(limit)
      synced_models[:updated] = (models || self).where('created_at < ? and updated_at >= ? and is_deleted = false', synced_date, synced_date).where(where).limit(limit)
      synced_models[:deleted] = (models || self).where('is_deleted = true and updated_at >= ?', synced_date).where(where).limit(limit)
    else
      synced_models[:new] = (models || self).where(where).limit(limit)
      synced_models[:updated] = synced_models[:deleted] = []
    end

    return synced_models
  end

end
