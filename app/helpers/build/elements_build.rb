module Build
  class ElementsBuild < AntBuild
    BUILD_NAME = 'elements'

    def initialize(config)
      super config.merge({
        :build_name => BUILD_NAME,
        :parser => Parsers::ElementsParser.new
      })
    end

  end
end

