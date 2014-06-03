module Build
  class BudgetsBuild < AntBuild
    BUILD_NAME = 'budgets'

    include Parsers

    def initialize(config)
      super config.merge({
        :build_name => BUILD_NAME,
        :parser => Parsers::BudgetParser.new
      })
    end

  end
end

