module Build
  class OperationsBuild < AntBuild
    BUILD_NAME = 'operations'

    def initialize(config)
      super config.merge({
        :build_name => BUILD_NAME,
        :parser => Parsers::OperationsParser.new
      })
    end
  end
end



