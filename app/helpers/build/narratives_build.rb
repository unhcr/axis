module Build
  class NarrativesBuild < AntBuild
    BUILD_NAME = 'narratives'

    include Parsers

    def initialize(config)
      super config.merge({
        :build_name => BUILD_NAME,
        :parser => Parsers::NarrativesParser.new
      })
    end

  end
end


