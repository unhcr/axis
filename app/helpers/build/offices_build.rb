module Build
  class OfficesBuild < AntBuild
    BUILD_NAME = 'offices'

    def initialize(config)
      super config.merge({
        :build_name => BUILD_NAME,
        :parser => Parsers::OfficesParser.new
      })
    end
  end
end


