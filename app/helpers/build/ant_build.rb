module Build
  class AntBuild
    DB_URL = "jdbc:oracle:thin:@ironwood.svc.unicc.org:1521:GFPRD"
    JAR_LOCATION = "#{Rails.root}/vendor/jars/ojdbc6.jar"
    OUTPUT_FILENAME = "generated_output.csv"

    # Directory for sql queries
    SQL_PATH = "#{Rails.root}/data/queries"

    # Root directory for ant builds
    ANT_TEMPLATE_FILEPATH = "#{Rails.root}/script/builds"

    # ERB build name
    ANT_BUILD_ERBNAME = 'build.xml.erb'

    # Ouput of build file
    ANT_BUILD_NAME = 'build.xml'

    def initialize(config)
      @config = config
      @config[:location] = JAR_LOCATION
      @config[:db_url] = DB_URL
      @config[:output] = OUTPUT_FILENAME
      @config[:build_name] = config[:build_name]
      @config[:sql_query] = self.sql_query
      @config[:limit] = config[:limit]

      @ant_path = config[:ant_path] || ANT_TEMPLATE_FILEPATH

      dir_path = "#{@ant_path}/#{MsrpBuild::BUILD_NAME}"
      Dir.mkdir(dir_path) unless Dir.exists? dir_path
    end

    # Path and filename for the build.xml.erb
    def build_erb_path
      @build_erb_path ||= "#{ANT_TEMPLATE_FILEPATH}/#{ANT_BUILD_ERBNAME}"
    end

    # Path where build.xml is generated to and CSV is written
    def build_path
      @build_path ||= "#{@ant_path}/#{@config[:build_name]}"
    end

    def build_erb
      @build_erb ||= ERB.new(File.read(self.build_erb_path))
    end

    def build_doc
      @build_doc ||= self.build_erb.result(binding)
    end

    def sql_query
      @sql_query ||= File.read("#{SQL_PATH}/#{@config[:build_name]}.sql")
    end

    # Writes the ANT xml file
    def generate_build
      filename = "#{self.build_path}/#{ANT_BUILD_NAME}"
      log "Writing build xml to #{filename}"
      File.open(filename, 'w') do |f|
        f.write(self.build_doc)
        f.close
      end
      filename
    end

    # Writes the CSV file to be parsed. Returns the file location of CSV
    def build
      output_filepath = "#{self.build_path}/#{OUTPUT_FILENAME}"

      Dir.chdir "#{self.build_path}"

      cmd = "ant #{@config[:build_name]}"

      log "Running '#{cmd}' in #{self.build_path}"
      output = system(cmd)

      return output_filepath
    end

    # Parses the CSV file
    def parse; end

    # Runs all pieces of the build
    def run
      start = Time.now
      log "[0/3] Generating build"
      generate_build

      log "[1/3] Building"
      filename = build

      log "[2/3] Parsing"

      parse(filename)
      log "[3/3] Complete"

      Time.now - start
    end

    def log(message)
      p "[#{@config[:build_name]}] #{message}"

    end

  end
end
