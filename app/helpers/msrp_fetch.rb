module MsrpFetch
  ANT_TEMPLATE_FILEPATH = "#{Rails.root}/script"
  ANT_BUILD_ERBNAME = 'build.xml.erb'
  ANT_BUILD_NAME = 'build.xml'
  FINAL_FILENAME = 'generated_expenses.csv'
  FIELDS = %W[HCR_BUDGET_REF	HCR_ABC	HCR_PRODUCT	HCR_PROGRAM_CODE	HCR_CLASS_FLD	BUDGET_TYPE	PLAN_TYPE	BUDGETCOMPONENT	ACCOUNT	SITES_ID	COSTCENTRE	CURRENCY_CD	PARTNERID	ACTORID	POPULATIONGROUPID	POPULATIONGROUP	RFOUTPUTID	RFGOALID	GOAL	PLANNINGYEAR	OPERATIONID	OPERATION	BDGCATEGORYID	PLANID	PRJPOPULATIONGROUPID	GOALID	RIGHTSGROUPID	OBJECTIVEID	OUTPUTID	EXPENSES_USD	EXPENSES_LC]

  @@ANT_BUILD_FILEPATH = ANT_TEMPLATE_FILEPATH

  def generate_build(limit = nil)
    config = {
      :limit => limit,
      :fields => FIELDS
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
