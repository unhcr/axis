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
end

task :fetch => :environment do

  n = ENV['n']

  n = n.nil? ? 1.0/0.0 : n.to_i

  p 'Fetching FOCUS data'

  include FocusFetch

  ret = fetch n
  p 'Finished fetching'
  p '-----------------'
  p "Files Read: #{ret[:files_read]}"
  p "Files Total: #{ret[:files_total]}"

end

task :init_countries => :environment do
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

end

task :match_plans_to_country => :environment do
  p 'No countries loaded' and return unless Country.count > 0

  include CountryHelper

  Plan.all.each do |plan|
    match_plan_to_country(plan)
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
