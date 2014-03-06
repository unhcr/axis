class StrategiesController < ApplicationController
  def create
    s = Strategy.create(
      :name => params[:strategy][:name],
      :description => params[:strategy][:description])


    s = update_strategy s, params[:strategy]
    render :json => { :strategy => s.as_json({ :include => {
      :operations => true,
      :strategy_objectives => true } }) }
  end

  def update
    s = Strategy.find(params[:id])
    s.update_attributes(
      :name => params[:strategy][:name],
      :description => params[:strategy][:description])

    s = update_strategy s, params[:strategy]

    render :json => { :strategy => s.as_json({ :include => {
      :operations => true,
      :strategy_objectives => true } }) }
  end

  def destroy
    s = Strategy.find(params[:id])
    s = s.destroy

    render :json => s
  end

  private
    def update_strategy(s, strategy_json)
      s.operation_ids = strategy_json[:operations].map { |o| o['id'] } if strategy_json[:operations]

      # Load all related plans
      s.plans = Plan.where(:operation_id => s.operation_ids) if strategy_json[:operations]

      # Load all related ppgs
      s.ppgs = Ppg.find((s.plans.map &:ppg_ids).flatten.uniq)

      # Build out all strategy_objectives
      s.strategy_objectives.clear
      if strategy_json[:strategy_objectives]
        strategy_json[:strategy_objectives].each do |json|
          so = s.strategy_objectives.create(
            :name => json[:name],
            :description => json[:description])


          params = [:goals, :outputs, :problem_objectives, :indicators]
          params.each do |param|
            next unless json[param].present?
            method = (param.to_s.singularize + '_ids=').to_sym
            ids = json[param].map { |p| p['id'] }
            so.send method, ids
          end
          so.save
        end
      end

      s.save
      s

    end
end
