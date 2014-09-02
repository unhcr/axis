module Build
  class PopulationsBuild < AntBuild
    BUILD_NAME = 'populations'

    def initialize(config)
      super config.merge({
        :build_name => BUILD_NAME,
        :parser => Parsers::PopulationsParser.new
      })
    end
  end
end





