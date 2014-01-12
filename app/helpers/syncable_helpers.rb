module SyncableHelpers
  protected
    def resource
      self.controller_name.classify.constantize
    end
end
