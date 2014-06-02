module Build
  class ElementsBuild < AntBuild
    BUILD_NAME = 'elements'

    include ElementsParse

    def initialize(config)
      super config.merge({ :build_name => BUILD_NAME })
    end

  end
end

