module Build
  class GoalsBuild < AntBuild
    BUILD_NAME = 'goals'

    def initialize(config)
      super config.merge({
        :build_name => BUILD_NAME,
        :parser => Parsers::GoalsParser.new
      })
    end
  end
end




