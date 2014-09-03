module CountryHelper

  def match_model_to_country(model, name)
    country = Country.where("un_names ILIKE ?", '%' + name + '%')
    if country.length == 1
      country = country.first
    elsif country.length > 1
      p 'Found multiple countries for one operation, using heuristics'
      # Any exact matches?
      selected = country.select do |c|
        matches = c.un_names.select { |un_name| name.downcase == un_name.downcase }
        not matches.empty?
      end

      if selected.empty?
        country = country.first
      else
        country = selected.first
      end

    else
      country = country.first
    end

    p "No country for model: #{name}" and return unless country
    model.country = country
    model.save
  end

end
