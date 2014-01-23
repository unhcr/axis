module MsrpFetch
  ANT_TEMPLATE_FILEPATH = "#{Rails.root}/script"
  ANT_BUILD_ERBNAME = 'build.xml.erb'
  ANT_BUILD_NAME = 'build.xml'
  FINAL_FILENAME = 'generated_expenses.csv'
  FIELDS = %W[planid planningyear goalid rightsgroupid objectiveid outputid populationgroupid budget_type budgetcomponent]
  GROUP_BY = %W[planid planningyear goalid rightsgroupid objectiveid outputid populationgroupid budget_type budgetcomponent]

  @@ANT_BUILD_FILEPATH = ANT_TEMPLATE_FILEPATH

  include MsrpParse

  def generate_build(limit = nil)
    config = {
      :limit => limit,
      :fields => FIELDS,
      :group_by => GROUP_BY
    }
    build = AntBuild.new(config)
    build_erb = ERB.new(File.read("#{ANT_TEMPLATE_FILEPATH}/#{ANT_BUILD_ERBNAME}"))
    build_doc = build_erb.result(build.get_binding)
    filename = "#{@@ANT_BUILD_FILEPATH}/#{ANT_BUILD_NAME}"
    File.open(filename, 'w') do |f|
      f.write(build_doc)
      f.close
    end
    filename
  end

  def build
    Dir.chdir @@ANT_BUILD_FILEPATH
    output = system("ant #{AntBuild::BUILD_NAME}")
    File.open(FINAL_FILENAME, 'w') do |final|
      final.puts FIELDS.join(',')
      File.foreach(AntBuild::OUTPUT_FILEPATH) do |line|
        final.puts line
      end
      final.close
    end

    return "#{@@ANT_BUILD_FILEPATH}/#{FINAL_FILENAME}"
  end

  def fetch(limit = nil)
    p '[0/3] Generating build'
    generate_build(limit)

    p '[1/3] Building'
    filename = build

    p '[2/3] Parsing'

    parse(filename)
    p '[3/3] Complete'
  end

  def set_build_dir(dir)
    @@ANT_BUILD_FILEPATH = dir
  end

  class AntBuild
    DB_URL = "jdbc:oracle:thin:@192.168.101.111:1521:GFPRD"
    JAR_LOCATION = "#{Rails.root}/vendor/jars/ojdbc6.jar"
    BUILD_NAME = "expenses"
    OUTPUT_FILEPATH = "generated_output.csv"

    def initialize(config = {})
      @config = config
      @config[:location] = JAR_LOCATION
      @config[:name] = BUILD_NAME
      @config[:db_url] = DB_URL
      @config[:output] = OUTPUT_FILEPATH
    end

    def get_binding
      binding()
    end
  end
end
