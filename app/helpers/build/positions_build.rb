module Build
  class PositionsBuild < AntBuild
    BUILD_NAME = 'positions'

    def initialize(config)
      super config.merge({
        :build_name => BUILD_NAME,
        :parser => Parsers::PositionsParser.new
      })
    end
  end
end

