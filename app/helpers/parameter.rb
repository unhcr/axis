module Parameter

  def synced_models(synced_date = nil, limit = 200)
    models = {}

    if synced_date
      models[:new] = self.where('created_at >= ? and is_deleted = false', synced_date).limit(limit)
      models[:updated] = self.where('created_at < ? and updated_at >= ? and is_deleted = false', synced_date, synced_date).limit(limit)
      models[:deleted] = self.where('is_deleted = true and updated_at >= ?', synced_date).limit(limit)
    else
      models[:new] = self.limit(limit)
      models[:updated] = models[:deleted] = []
    end

    return models
  end

end
