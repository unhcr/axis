module Build
  class MsrpBuild < AntBuild
    BUILD_NAME = 'expenses'

    include MsrpParse

    def initialize(config)
      super config.merge({ :build_name => BUILD_NAME })
    end

  end
end
