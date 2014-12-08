# shared methods across all syncable helpers

module ControllerHelpers
  protected
    def resource
      self.controller_name.classify.constantize
    end
end
