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
end

namespace :build do

  builds = {
    :msrp => 'Build::MsrpBuild',
    :budgets => 'Build::BudgetsBuild',
    :elements => 'Build::ElementsBuild',
    :positions => 'Build::PositionsBuild',
    :indicator_data_impact => 'Build::IndicatorDataImpactBuild',
    :indicator_data_perf => 'Build::IndicatorDataPerfBuild'
  }

  builds.each do |build_name, builder_string|
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

  task :counter_caches => :environment do
    IndicatorsPlans.counter_culture_fix_counts
    GoalsPlans.counter_culture_fix_counts
    OutputsPlans.counter_culture_fix_counts
    PlansProblemObjectives.counter_culture_fix_counts
    PlansPpgs.counter_culture_fix_counts

    Plan.all.map &:touch
  end
end

task :build => :environment do
  starttime = Time.now
  fm = FetchMonitor.first
  Rake::Task['build:elements'].invoke
  Rake::Task['build:countries'].invoke
  Rake::Task['build:budgets'].invoke
  Rake::Task['build:msrp'].invoke
  Rake::Task['build:indicator_data_impact'].invoke
  Rake::Task['build:indicator_data_perf'].invoke

  fm.starttime = starttime
  fm.mark_deleted
end

namespace :utils do
  task :strategy_to_yaml => :environment do

    id = ENV['id']

    unless Strategy.exists? id
      p "No such strategy exists for id: #{id}"
      return
    end
    strategy = Strategy.find id
    yaml = strategy.as_json({ :include => { :strategy_objectives => true } }).as_json.as_json.to_yaml

    name = strategy.name.downcase.gsub ' ', '_'

    File.open("#{Rails.root}/data/strategies/#{name}.yml", 'w+') { |file| file.write yaml }
  end

  task :strategy_from_yaml => :environment do

  end

end


task :load_sample_strategy => :environment do

  name = 'education'

  Strategy.where(:name => name).destroy_all
  s = Strategy.create(:name => name)

  s.ppgs = Ppg.limit(10)
  s.goals = Goal.limit(10)
  s.indicators = Indicator.limit(40)

end

task :random_strategy => :environment do

  probability = 0.33

  s = Strategy.new(
    :name => "#{RandomWord.adjs.next} #{RandomWord.nouns.next}"
  )

  s.operations << Operation.order("RAND()").limit(probability * Operation.count)
  s.ppgs << Ppg.order("RAND()").limit(probability * Ppg.count)
  s.goals << Goal.order("RAND()").limit(probability * Goal.count)
  s.problem_objectives << ProblemObjective.order("RAND()").limit(probability * ProblemObjective.count)
  s.outputs << Output.order("RAND()").limit(probability * Output.count)
  s.indicators << Indicator.order("RAND()").limit(probability * Indicator.count)
  s.plans << Plan.where(:operation_id => s.operation_ids)
  s.save

end

task :reset_local_db => :environment do
  User.reset_local_db(User.all)
end
