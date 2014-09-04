module Build
  class RelationsBuild < AntBuild
    BUILD_NAME = 'relations'

    def initialize(config)
      super config.merge({
        :build_name => BUILD_NAME,
        :parser => Parsers::RelationsParser.new
      })
    end

  end
end

