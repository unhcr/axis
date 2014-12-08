desc "Deletes everything in the database"
task :clear => :environment do

  p 'Clearing Database'

  Operation.delete_all
  Plan.delete_all
  Ppg.delete_all
  Goal.delete_all
  RightsGroup.delete_all
  ProblemObjective.delete_all
  Output.delete_all
  Indicator.delete_all
  IndicatorDatum.delete_all
  Budget.delete_all
  Expenditure.delete_all
  Position.delete_all
  Office.delete_all
  Narrative.delete_all
end

namespace :build do

  builds = {
    :msrp => 'Build::MsrpBuild',
    :budgets => 'Build::BudgetsBuild',
    :relations => 'Build::RelationsBuild',
    :positions => 'Build::PositionsBuild',
    :offices => 'Build::OfficesBuild',
    :indicator_data_impact => 'Build::IndicatorDataImpactBuild',
    :indicator_data_perf => 'Build::IndicatorDataPerfBuild',
    :narratives => 'Build::NarrativesBuild',
    :operations => 'Build::OperationsBuild',
    :outputs => 'Build::OutputsBuild',
    :problem_objectives => 'Build::ProblemObjectivesBuild',
    :goals => 'Build::GoalsBuild',
    :populations => 'Build::PopulationsBuild',
    :ppgs => 'Build::PpgsBuild',
    :indicator_impact => 'Build::IndicatorImpactBuild',
    :indicator_perf => 'Build::IndicatorPerfBuild',

  }

  builds.each do |build_name, builder_string|
    desc "Loads the data for #{build_name}"
    task build_name => :environment do
      builder = builder_string.constantize

      n = ENV['n']
      n = n.to_i unless n.nil?

      p "Fetching #{build_name} data"

      build = builder.new({ :limit => n })

      deltaTime = build.run

      p "Finished fetching #{build_name} data in: #{deltaTime}"
    end
  end


  desc "Matches country meta data with an operation"
  task :countries => :environment do
    file = open("#{Rails.root}/data/countries.json")
    json = file.read

    require "csv"

    parsed = JSON.parse(json)

    parsed.each do |c|
      country = Country.find_or_create_by_iso3({
        :name => c["name"],
        :latlng => c["latlng"],
        :iso3 => c["cca3"],
        :iso2 => c["cca2"],
        :region => c["region"],
        :subregion => c["subregion"]
      })
    end

    CSV.foreach("#{Rails.root}/data/uniso.csv", :headers => true) do |row|
      country = Country.where(:iso3 => row["ISO"]).first
      p "No country found for #{row["ISO"]}" and next unless country
      country.un_names << row["Country"] unless country.un_names.include? row["Country"]
      country.save
    end

    include CountryHelper

    Plan.all.each do |plan|
      match_model_to_country(plan, plan.operation_name)
    end
    Operation.all.each do |operation|
      match_model_to_country(operation, operation.name)
    end
  end

end

desc "Runs all the builds and then deletes parameters that were not found"
task :build => :environment do
  starttime = Time.now
  fm = FetchMonitor.first
  fm = FetchMonitor.create if fm.nil?

  Rake::Task['build:relations'].invoke
  Rake::Task['build:budgets'].invoke
  Rake::Task['build:msrp'].invoke
  Rake::Task['build:narratives'].invoke
  Rake::Task['build:offices'].invoke
  Rake::Task['build:positions'].invoke
  Rake::Task['build:indicator_data_impact'].invoke
  Rake::Task['build:indicator_data_perf'].invoke
  Rake::Task['build:operations'].invoke
  Rake::Task['build:countries'].invoke
  Rake::Task['build:outputs'].invoke
  Rake::Task['build:problem_objectives'].invoke
  Rake::Task['build:goals'].invoke
  Rake::Task['build:populations'].invoke
  Rake::Task['build:ppgs'].invoke
  Rake::Task['build:indicator_impact'].invoke
  Rake::Task['build:indicator_perf'].invoke

  fm.starttime = starttime
  fm.mark_deleted
  fm.save
end

desc "Reindexes elasticsearch models"
task :reindex => :environment do
  indexes = [Operation, Ppg, Goal, Output, StrategyObjective, ProblemObjective, Indicator]

  indexes.each do |i|
    i.index.delete
    i.index.import i.all
  end
end

