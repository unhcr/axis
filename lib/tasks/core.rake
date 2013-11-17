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
  BudgetLine.destroy_all
  IndicatorDatum.destroy_all
end
