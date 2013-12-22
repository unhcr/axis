module FocusFetch

  BASE_URL = 'https://intranetapps.unhcr.org/a47focus-data/XML/Current/'
  HEADERS = 'OperationHeaders.zip'
  PLAN_PREFIX = 'Plan_'
  PLAN_SUFFIX = '.zip'

  @@DIR = "#{Rails.root}/data/focus"
  @@TEST_PATH = ''

  PLAN_TYPES = ['ONEPLAN']

  require 'open-uri'
  require 'zip'
  include FocusParse

  def fetch(max_files = +1.0/0.0, expires = 1.week, test = false)
    monitor = FetchMonitor.first || FetchMonitor.create

    begin
      headers_zip = open(server_url(HEADERS),
         :http_basic_authentication => [ENV['LDAP_USERNAME'], ENV['LDAP_PASSWORD']])
    rescue Exception => e
      Rails.logger.fatal "Failed fetching header file: #{e.message}"
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

        input = entry.get_input_stream

        if test
          input = File.read(FocusFetchTest::TESTFILE_PATH + FocusFetchTest::TESTHEADER_NAME)
        end

        r = parse_header(input)
        ids = r[:ids]
        monitor.reset(ids) if monitor.reset?

        ret[:files_total] = ids.length

      end
    end

    ids.each_with_index do |id, i|
      break if i >= max_files

      # If we have a decently recent pull of file skip
      Rails.logger.debug "Skipping #{id}" and next if find_plan_file(id, expires) && monitor.complete?(id)

      begin
        plan_zip = open("#{server_url("#{PLAN_PREFIX}#{id}#{PLAN_SUFFIX}")}",
                      :http_basic_authentication => [ENV['LDAP_USERNAME'], ENV['LDAP_PASSWORD']])
      rescue Exception => e
        Rails.logger.error "Failed fetching #{id} -- e.message"
        monitor.set_state(id, FetchMonitor::MONITOR_STATES[:error])
        next
      end

      Rails.logger.debug "Parsing plan: #{PLAN_PREFIX + id + PLAN_SUFFIX}"
      begin
        Zip::File.open(plan_zip) do |zip|
          ret[:files_read] += 1
          zip.each_with_index do |entry, j|
            raise 'More than one plan file' if j > 0
            input = entry.get_input_stream
            if test
              input = File.read(@@TEST_PATH)
            end

            parse_plan(input)
          end
        end
      rescue Exception => e
        monitor.set_state(id, FetchMonitor::MONITOR_STATES[:error])
        next
      end

      # Save plan after it's been read
      hard_disk = File.new(filename(id), 'w:ascii-8bit')
      hard_disk.write(plan_zip.read)

      plan_zip.unlink
      plan_zip.close
      monitor.set_state(id, FetchMonitor::MONITOR_STATES[:complete])


    end
    monitor.mark_deleted if monitor.reset?

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

  def server_url(file_path, params = {})
    "#{BASE_URL}#{file_path}?#{server_params}"
  end

  def server_params(params = {})
    ip = Socket.ip_address_list.detect { |intf| intf.ipv4_private? }

    params = "user=#{ENV['LDAP_USERNAME']};type=#{Rails.application.class.parent_name}"
    params += ";IP=#{ip.ip_address}" if ip
    params += ";ver=0.0.1"

    params
  end

  def set_test_path(path)
    @@TEST_PATH = path
  end

  def get_test_path
    @@TEST_PATH
  end

  def set_data_dir(dir)
    @@DIR = dir
  end

  def get_data_dir
    @@DIR
  end

end
