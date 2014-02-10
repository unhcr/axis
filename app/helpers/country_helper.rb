module CountryHelper

  def match_plan_to_country(plan)
    country = Country.where("un_names LIKE ?", '%' + plan.operation_name + '%').first
    Rails.logger.info "No country for plan: #{plan.operation_name}" and return unless country
    plan.country = country
    plan.save
  end

  def match_operation_to_country(operation)
    country = Country.where("un_names LIKE ?", '%' + operation.name + '%').first
    Rails.logger.info "No country for plan: #{operation.name}" and return unless country
    operation.country = country
    operation.save
  end
end
