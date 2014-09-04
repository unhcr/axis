module Build
  class IndicatorPerfBuild < AntBuild
    BUILD_NAME = 'indicator_perf'

    def initialize(config)
      super config.merge({
        :build_name => BUILD_NAME,
        :parser => Parsers::IndicatorPerfParser.new
      })
    end
  end
end




