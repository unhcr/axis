module CountryHelper

  def match_plan_to_country(plan)
    country = Country.where("un_names LIKE ?", '%' + plan.operation_name + '%').first
    p "No country for plan: #{plan.operation_name}" and return unless country
    plan.country = country
    plan.save
  end

end
