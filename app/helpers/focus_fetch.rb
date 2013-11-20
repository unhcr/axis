module FocusFetch

  BASE_URL = 'https://intranetapps.unhcr.org/a47focus-data/XML/Current/'
  HEADERS = 'OperationHeaders.zip'
  PLAN_PREFIX = 'Plan_'
  PLAN_SUFFIX = '.zip'
  DIR = "#{Rails.root}/data/focus"

  PLAN_TYPES = ['ONEPLAN']

  require 'open-uri'
  require 'zip'
  include FocusParse

  def fetch(max_files = +1.0/0.0)
    begin
      headers_zip = open(BASE_URL + HEADERS, :http_basic_authentication =>
                         [ENV['LDAP_USERNAME'], ENV['LDAP_PASSWORD']])
    rescue SocketError
      puts 'Internet connection appears to be bad.'
      exit
    end

    ret = {
      :files_read => 0,
      :files_total => 0
    }

    ids = []

    Zip::File.open(headers_zip) do |zip|
      # Should always be one file
      zip.each_with_index do |entry, index|
        raise 'More than one header file' if index > 0

        r = parse_header(entry.get_input_stream)
        ids = r[:ids]

        ret[:files_total] = ids.length

      end
    end

    ids.each_with_index do |id, i|
      break if i >= max_files

      begin
        plan_zip = open(BASE_URL + PLAN_PREFIX + id + PLAN_SUFFIX,
                      :http_basic_authentication => [ENV['LDAP_USERNAME'], ENV['LDAP_PASSWORD']])
      rescue SocketError
        puts 'Internet connection appears to be bad.'
      end

      begin
        Zip::File.open(plan_zip) do |zip|
          ret[:files_read] += 1
          zip.each_with_index do |entry, j|
            raise 'More than one plan file' if j > 0

            parse_plan(entry.get_input_stream)
          end
        end
      rescue
        p "Error parsing plan with id: #{id}"
      end


    end

    return ret

  end

end
