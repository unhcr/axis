require 'spec_helper'

describe FocusFetch do
  fixtures :all
  include FocusFetch

  TESTHEADER_NAME = "HeaderTest.zip"
  TESTFILE_PATH = "/files/"
  TESTFILE_NAME = "PlanTest.zip"
  TESTFILE_NAME_2 = "PlanTest2.zip"
  DELETED_TESTFILE_NAME = "DeletedPlanTest.zip"
  DELETED_TESTHEADER_NAME = "DeletedHeaderTest.zip"
  PLAN_PREFIX = 'Plan_'
  PLAN_SUFFIX = '.zip'

  TESTDATA_PATH = "#{Rails.root}/test/files/focus"

  COUNTS = {
    :plans => 1,
    :ppgs => 2,
    :goals => 2,
    :rights_groups => 8,
    :problem_objectives => 22,
    :indicators => 120,
    :outputs => 53,
    :operations => 139,
    :indicator_data => 120,
    :budgets => 232
  }

  COUNTS_DELETED = {
    :plans => 0,
    :ppgs => 1,
    :goals => 1,
    :outputs => 4,
    :rights_groups => 0,
    :problem_objectives => 1,
    :indicator_data => 7,
    :indicators => 7,
    :budgets => 12
  }

  before(:all) do
    set_data_dir(TESTDATA_PATH)
  end

  after(:all) do
    FileUtils.rm_rf("#{TESTDATA_PATH}/.", :secure => true)
    FileUtils.touch("#{TESTDATA_PATH}/.gitignore")
  end

  it "should fetch 2 files from focus" do
    zip_name = 'archive.zip'

    allow(self).to receive(:open).and_return(
      fixture_file_upload("#{TESTFILE_PATH}#{TESTHEADER_NAME}", 'application/zip'),
      fixture_file_upload("#{TESTFILE_PATH}#{TESTFILE_NAME}", 'application/zip'),
      fixture_file_upload("#{TESTFILE_PATH}#{TESTFILE_NAME_2}", 'application/zip'))

    ret = fetch(2)

    ret[:files_read].should eq(2)
    ret[:files_total].should eq(508)
  end

  it "should mark fetched deleted" do
    Plan.delete_all
    Ppg.delete_all
    Goal.delete_all
    RightsGroup.delete_all
    ProblemObjective.delete_all
    Output.delete_all
    Indicator.delete_all
    IndicatorDatum.delete_all
    Operation.delete_all
    Budget.delete_all

    allow(self).to receive(:open).and_return(
      fixture_file_upload("#{TESTFILE_PATH}#{DELETED_TESTHEADER_NAME}", 'application/zip'),
      fixture_file_upload("#{TESTFILE_PATH}#{TESTFILE_NAME}", 'application/zip'))

    ret = fetch(1, 1.week)

    COUNTS[:plans].should eq(Plan.count)
    COUNTS[:ppgs].should eq(Ppg.count)

    allow(self).to receive(:open).and_return(
      fixture_file_upload("#{TESTFILE_PATH}#{DELETED_TESTHEADER_NAME}", 'application/zip'),
      fixture_file_upload("#{TESTFILE_PATH}#{DELETED_TESTFILE_NAME}", 'application/zip'))

    ret = fetch(1, 1.week)

    COUNTS_DELETED[:plans].should eq(Plan.where(:is_deleted => true).count)
    COUNTS_DELETED[:ppgs].should eq(Ppg.where(:is_deleted => true).count)
    COUNTS_DELETED[:goals].should eq(Goal.where(:is_deleted => true).count)
    COUNTS_DELETED[:outputs].should eq(Output.where(:is_deleted => true).count)
    COUNTS_DELETED[:rights_groups].should eq(RightsGroup.where(:is_deleted => true).count)
    COUNTS_DELETED[:indicator_data].should eq(IndicatorDatum.where(:is_deleted => true).count)
    COUNTS_DELETED[:problem_objectives].should eq(ProblemObjective.where(:is_deleted => true).count)
    COUNTS_DELETED[:budgets].should eq(Budget.where(:is_deleted => true).count)
    COUNTS_DELETED[:indicators].should eq(Indicator.where(:is_deleted => true).count)
  end

  it "should find plan file" do

    id_new = 'recent'
    id_old = 'old'


    f = File.new("#{get_data_dir}/#{PLAN_PREFIX}#{id_old}__#{(Time.now - 2.weeks).to_i}#{PLAN_SUFFIX}", 'w')
    f.write('abcd')
    f.close

    f = File.new(filename(id_new), 'w')
    f.write('abcd')
    f.close

    # Ensure timestamp difference
    sleep(1)

    recent_name = filename(id_new)
    f = File.new(recent_name, 'w')
    f.write('abcd')
    f.close

    recent_names = Dir.glob(filename_glob(id_new))
    recent_names.length.should eq(2)

    plan_name = find_plan_file(id_new, 1.week)

    recent_names = Dir.glob(filename_glob(id_new))
    recent_names.length.should eq(1)
    recent_name.should eq(plan_name)


    old_names = Dir.glob(filename_glob(id_old))
    old_names.length.should eq(1)

    old_plan_name = find_plan_file(id_old, 1.week)

    old_names = Dir.glob(filename_glob(id_old))
    old_names.length.should eq(0)
    old_plan_name.should be_nil
  end

  it "should get server_params" do
    ENV['LDAP_USERNAME'] = 'rudolph@unhcr.org'

    params_string = server_params

    hash = Hash[(params_string.split(';').map { |p| p.split('=') })]

    hash["user"].should eq('rudolph@unhcr.org')
    hash["IP"].should_not be_nil
    hash["type"].should_not be_nil
    hash["ver"].should_not be_nil
    ENV['LDAP_USERNAME'] = nil
  end

end
