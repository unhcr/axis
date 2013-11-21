module FocusFetch

  BASE_URL = 'https://intranetapps.unhcr.org/a47focus-data/XML/Current/'
  HEADERS = 'OperationHeaders.zip'
  PLAN_PREFIX = 'Plan_'
  PLAN_SUFFIX = '.zip'

  @@DIR = "#{Rails.root}/data/focus"

  PLAN_TYPES = ['ONEPLAN']

  require 'open-uri'
  require 'zip'
  include FocusParse

  def fetch(max_files = +1.0/0.0, expires = 1.week)
    begin
      headers_zip = open(BASE_URL + HEADERS, :http_basic_authentication =>
                         [ENV['LDAP_USERNAME'], ENV['LDAP_PASSWORD']])
    rescue
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

      # If we have a decently recent pull of file skip
      p "Skipping #{id}" and next if find_plan_file(id, expires)

      begin
        plan_zip = open(BASE_URL + PLAN_PREFIX + id + PLAN_SUFFIX,
                      :http_basic_authentication => [ENV['LDAP_USERNAME'], ENV['LDAP_PASSWORD']])
      rescue
        puts 'Internet connection appears to be bad.'
      end

      p "Parsing plan: #{PLAN_PREFIX + id + PLAN_SUFFIX}"
      begin
        Zip::File.open(plan_zip) do |zip|
          ret[:files_read] += 1
          zip.each_with_index do |entry, j|
            raise 'More than one plan file' if j > 0

            parse_plan(entry.get_input_stream)
          end
        end
      rescue Exception => e
        p "Error parsing plan with id: #{id} -- Skipping"
        p e.message
        next
      end

      # Save plan after it's been read
      hard_disk = File.new(filename(id), 'w:ascii-8bit')
      hard_disk.write(plan_zip.read)

      plan_zip.unlink
      plan_zip.close


    end

    return ret

  end

  def filename(id)
    "#{@@DIR}/#{PLAN_PREFIX}#{id}__#{Time.now.to_i}#{PLAN_SUFFIX}"
  end

  def filename_glob(id)
    "#{@@DIR}/#{PLAN_PREFIX}#{id}__*#{PLAN_SUFFIX}"
  end

  def find_plan_file(id, expires)

    filenames = Dir.glob("#{@@DIR}/#{PLAN_PREFIX}#{id}__*#{PLAN_SUFFIX}")

    return nil if filenames.empty?

    # Reorder, most recent one last
    filenames.sort!

    current = filenames.pop

    # Remove any previous ones
    filenames.each { |filename| File.delete(filename) }

    stamp = current.split('__')[-1].to_i

    File.delete(current) and return nil if stamp < (Time.now - expires).to_i

    return current


  end

  def set_data_dir(dir)
    @@DIR = dir
  end

  def get_data_dir
    @@DIR
  end

end
