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
  p "Files Read: #{ret[:files_red]}"
  p "Files Total: #{ret[:files_total]}"

end
