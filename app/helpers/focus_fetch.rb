module FocusFetch

  BASE_URL = 'https://intranetapps.unhcr.org/a47focus-data/XML/Current/'
  HEADERS = 'OperationHeaders.zip'
  PLAN_PREFIX = 'Plan_'
  PLAN_SUFFIX = '.zip'
  DIR = "#{Rails.root}/data/focus"

  PLAN_TYPES = ['ONEPLAN']

  require 'open-uri'

  def fetch
    headers_zip = open(BASE_URL + HEADERS, :http_basic_authentication => ['rudolph@unhcr.org', 'benn2690'])

    ids = []

    Zip::File.open(headers_zip) do |zip|
      # Should always be one file
      zip.each_with_index do |file, index|
        raise 'More than one header file' if index > 0

        doc = Nokogiri::XML(file)

        PLAN_TYPES.each do |type|
          ids += doc.search("//PlanHeader[type =\"#{type}\"]/planID/text()").map(&:text)
        end

      end
    end

    ids.each do |id|

      plan_zip = open(BASE_URL + PLAN_PREFIX + id + PLAN_SUFFIX,
                      :http_basic_authentication => ['rudolph@unhcr.org', 'benn2690'])

      Zip::File.open(plan_zip) do |zip|
        zip.each_with_index do |file, index|
          raise 'More than one header file' if index > 0

          FocusParse::parse(file)
        end
      end


    end


  end

end
