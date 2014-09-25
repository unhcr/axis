module WarmCache

  def self.warm
    year = AdminConfiguration.default_date
    report_type = AdminConfiguration::REPORT_TYPE_MAPPING[AdminConfiguration.default_reported_type]
    Strategy.all.each do |s|
      parameter_ids = s.parameter_ids
      parameter_ids.delete :output_ids

      # Warm narratives
      Narrative.summarize parameter_ids, report_type, year
    end
  end
end
