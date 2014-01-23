require 'spec_helper'

describe MsrpFetch do
  include MsrpFetch
  TESTDATA_PATH = "#{Rails.root}/test/files/msrp"

  before(:all) do
    set_build_dir(TESTDATA_PATH)
  end

  after(:all) do
    FileUtils.rm_rf("#{TESTDATA_PATH}/.", :secure => true)
    FileUtils.touch("#{TESTDATA_PATH}/.gitignore")
  end

  it "should generate a build file with limit" do

    limit = 10
    filename = generate_build(limit)

    doc = Nokogiri::XML(File.read(filename))

    project = doc.search('project')
    project.length.should eq(1)
    project.attribute('basedir').value.should eq('.')
    project.attribute('name').value.should eq('AXIS')

    target = project.search('./target')
    target.length.should eq(1)
    target.attribute('name').value.should eq(MsrpFetch::AntBuild::BUILD_NAME)

    sql = target.search('./sql')
    sql.length.should eq(1)
    sql.attribute('url').value.should eq(MsrpFetch::AntBuild::DB_URL)
    sql.attribute('output').value.should eq(MsrpFetch::AntBuild::OUTPUT_FILEPATH)
    expect(sql.text.downcase.include?("where rownum <= #{limit}")).to be(true)

    pathelement = sql.search('./classpath/pathelement')
    pathelement.length.should eq(1)
    pathelement.attribute('location').value.should eq(MsrpFetch::AntBuild::JAR_LOCATION)
  end

  it "should generate build file without limit" do
    filename = generate_build

    doc = Nokogiri::XML(File.read(filename))
    sql = doc.search('sql')
    expect(sql.text.downcase.include?("where rownum")).to be(false)
  end

  it "should build file" do
    allow(self).to receive('system').with("ant #{MsrpFetch::AntBuild::BUILD_NAME}").and_return 'dummy'

    generate_build(10)

    # ensure file, since we stub creation
    FileUtils.touch("#{TESTDATA_PATH}/#{MsrpFetch::AntBuild::OUTPUT_FILEPATH}")
    filename = build

    filename.should eq("#{TESTDATA_PATH}/#{MsrpFetch::FINAL_FILENAME}")
    lines = File.readlines("#{TESTDATA_PATH}/#{MsrpFetch::FINAL_FILENAME}")
    lines.length.should eq(1)
    lines[0].gsub(/\s+/, '').should eq(MsrpFetch::FIELDS.join(',').gsub(/\s+/, ''))
  end

end
