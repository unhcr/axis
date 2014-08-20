module Build
  class OutputsBuild < AntBuild
    BUILD_NAME = 'outputs'

    def initialize(config)
      super config.merge({
        :build_name => BUILD_NAME,
        :parser => Parsers::OutputsParser.new
      })
    end
  end
end




