module Build
  class PpgsBuild < AntBuild
    # Has to match .sql file
    BUILD_NAME = 'ppgs'

    def initialize(config)
      super config.merge({
        :build_name => BUILD_NAME,
        :parser => Parsers::PpgsParser.new
      })
    end
  end
end




