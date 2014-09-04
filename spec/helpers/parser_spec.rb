require 'spec_helper'
require 'database_cleaner'
DatabaseCleaner.strategy = :truncation

describe Parsers do

  include Parsers
  include Build

  TESTFILE_PATH = "#{Rails.root}/test/files/"

  parsers = [
    {
      parser: Parsers::BudgetParser,
      build: Build::BudgetsBuild,
      required: [:plan_id, :operation_id, :goal_id, :problem_objective_id, :output_id, :year, :scenario,
                 :budget_type]
    },
    {
      parser: Parsers::MsrpParser,
      build: Build::MsrpBuild,
      required: [:plan_id, :operation_id, :goal_id, :problem_objective_id, :output_id, :year, :scenario,
                 :budget_type]
    },
    {
      parser: Parsers::NarrativesParser,
      build: Build::NarrativesBuild,
      required: [:plan_id, :operation_id, :year, :report_type, :createusr, :plan_el_type, :elt_id]
    },
    {
      parser: Parsers::OfficesParser,
      build: Build::OfficesBuild,
      required: [:plan_id, :operation_id, :name]
    },
    {
      parser: Parsers::PositionsParser,
      build: Build::PositionsBuild,
      required: [:plan_id, :operation_id, :office_id, :existing]
    },
    {
      parser: Parsers::PopulationsParser,
      build: Build::PopulationsBuild,
      required: [:value, :ppg_code, :ppg_id, :year, :operation_id]
    },

  ]


  before(:all) do
    DatabaseCleaner.start
  end

  after(:all) do
    ActiveRecord::Base.connection.close

    DatabaseCleaner.clean
  end

  it "should respond to selector" do
    parsers.each do |parser|
      @parserClass = parser[:parser]
      @parser = @parserClass.new
      @required = parser[:required]
      @path = "#{TESTFILE_PATH}#{parser[:build]::BUILD_NAME}/#{parser[:build]::OUTPUT_FILENAME}"
      expect(@parserClass.respond_to?(:selector)).to be(true)
    end
  end

  it "should parse" do
    parsers.each do |parser|
      @parserClass = parser[:parser]
      @parser = @parserClass.new
      @required = parser[:required]
      @path = "#{TESTFILE_PATH}#{parser[:build]::BUILD_NAME}/#{parser[:build]::OUTPUT_FILENAME}"
      @parser.parse @path

      @parserClass::MODEL.count.should eq(50)

      @parserClass::MODEL.all.each do |model|
        @required.each do |requirement|
          expect(model[requirement].present?).to be(true)
        end
      end

      # Idempotent
      @parser.parse @path

      @parserClass::MODEL.count.should eq(50)
      @parserClass::MODEL.all.each do |model|
        @required.each do |requirement|
          expect(model[requirement].present?).to be(true)
        end
      end
    end
  end




end

