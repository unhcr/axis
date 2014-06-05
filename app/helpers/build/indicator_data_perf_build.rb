module Build
  class IndicatorDataPerfBuild < AntBuild
    BUILD_NAME = 'indicator_data_perf'

    def initialize(config)
      super config.merge({
        :build_name => BUILD_NAME,
        :parser => Parsers::IndicatorDataPerfParser.new
      })
    end

  end
end


