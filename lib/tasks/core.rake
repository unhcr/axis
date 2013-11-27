task :clear => :environment do

  p 'Clearing Database'

  Operation.destroy_all
  Plan.destroy_all
  Ppg.destroy_all
  Goal.destroy_all
  RightsGroup.destroy_all
  ProblemObjective.destroy_all
  Output.destroy_all
  Indicator.destroy_all
  IndicatorDatum.destroy_all
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
