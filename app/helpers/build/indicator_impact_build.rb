module Build
  class IndicatorImpactBuild < AntBuild
    BUILD_NAME = 'indicator_impact'

    def initialize(config)
      super config.merge({
        :build_name => BUILD_NAME,
        :parser => Parsers::IndicatorImpactParser.new
      })
    end
  end
end




