module Build
  class MsrpBuild < AntBuild
    BUILD_NAME = 'expenses'


    def initialize(config)
      super config.merge({
        :build_name => BUILD_NAME,
        :parser => Parsers::MsrpParser.new
      })
    end

  end
end
