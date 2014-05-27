require 'spec_helper'

describe Build do

  before(:all) do
    include Build

    @ant_path = "#{Rails.root}/test/files"
  end

  after(:all) do
    FileUtils.rm_rf("#{@ant_path}/#{Build::MsrpBuild::BUILD_NAME}/.", :secure => true)
  end

  it "should generate a build file with limit" do
    limit = 10
    build = Build::MsrpBuild.new({ :limit => limit, :ant_path => @ant_path })

    filename = build.generate_build

    doc = Nokogiri::XML(File.read(filename))

    project = doc.search('project')
    project.length.should eq(1)
    project.attribute('basedir').value.should eq('.')
    project.attribute('name').value.should eq('AXIS')

    target = project.search('./target')
    target.length.should eq(1)
    target.attribute('name').value.should eq(Build::MsrpBuild::BUILD_NAME)

    sql = target.search('./sql')
    sql.length.should eq(1)
    sql.attribute('url').value.should eq(Build::MsrpBuild::DB_URL)
    sql.attribute('output').value.should eq(Build::MsrpBuild::OUTPUT_FILENAME)
    expect(sql.text.downcase.include?("where rownum <= #{limit}")).to be(true)

    pathelement = sql.search('./classpath/pathelement')
    pathelement.length.should eq(1)
    pathelement.attribute('location').value.should eq(Build::MsrpBuild::JAR_LOCATION)
  end

  it "should generate build file without limit" do
    build = Build::MsrpBuild.new({ :ant_path => @ant_path })
    filename = build.generate_build

    doc = Nokogiri::XML(File.read(filename))
    sql = doc.search('sql')
    expect(sql.text.downcase.include?("where rownum")).to be(false)
  end

  it "should build file" do

    build = Build::MsrpBuild.new({ :limit => 10, :ant_path => @ant_path })

    allow(build).to receive('system').with("ant #{Build::MsrpBuild::BUILD_NAME}").and_return 'dummy'

    build.generate_build

    filename = build.build

    filename.should eq("#{@ant_path}/#{Build::MsrpBuild::BUILD_NAME}/#{Build::MsrpBuild::OUTPUT_FILENAME}")
  end

end
