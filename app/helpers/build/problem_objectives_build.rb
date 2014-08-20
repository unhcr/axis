module Build
  class ProblemObjectivesBuild < AntBuild
    BUILD_NAME = 'problem_objectives'

    def initialize(config)
      super config.merge({
        :build_name => BUILD_NAME,
        :parser => Parsers::ProblemObjectivesParser.new
      })
    end
  end
end




