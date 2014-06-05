module Build
  class IndicatorDataImpactBuild < AntBuild
    BUILD_NAME = 'indicator_data_impact'

    def initialize(config)
      super config.merge({
        :build_name => BUILD_NAME,
        :parser => Parsers::IndicatorDataImpactParser.new
      })
    end

  end
end


