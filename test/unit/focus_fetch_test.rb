require 'test_helper'

class FocusFetchTest < ActiveSupport::TestCase
  fixtures :all
  include FocusFetch

  TESTHEADER_NAME = "DeletedHeaderTest.xml"
  TESTFILE_PATH = "#{Rails.root}/test/files/"
  TESTFILE_NAME = "PlanTest.xml"
  DELETED_TESTFILE_NAME = "DeletedPlanTest.xml"

  TESTDATA_PATH = "#{Rails.root}/test/files/focus"

  COUNTS = {
    :plans => 1,
    :ppgs => 3,
    :goals => 3,
    :rights_groups => 8,
    :problem_objectives => 28,
    :indicators => 171,
    :outputs => 82,
    :operations => 139,
    :indicator_data => 208,
    :budgets => 403
  }

  COUNTS_DELETED = {
    :plans => 0,
    :ppgs => 1,
    :goals => 1,
    :outputs => 29,
    :rights_groups => 0,
    :problem_objectives => 6,
    :indicator_data => 88,
    :indicators => 51,
    :budgets => 171
  }

  def setup
    # Change directory for testing
    set_data_dir(TESTDATA_PATH)
  end

  def teardown
    FileUtils.rm_rf("#{TESTDATA_PATH}/.", secure: true)
    FileUtils.touch("#{TESTDATA_PATH}/.gitignore")
  end

  test "Fetching from FOCUS - max files 2" do
    return if !ENV['LDAP_USERNAME'] || !ENV['LDAP_PASSWORD']
    ret = fetch(2)

    assert_equal 2, ret[:files_read]
    assert ret[:files_total] >= 2
  end

  test "Mark fetched deleted" do
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

    set_test_path("#{TESTFILE_PATH}#{TESTFILE_NAME}")
    ret = fetch(1, 1.week, true)

    assert_equal COUNTS[:plans], Plan.count
    assert_equal COUNTS[:ppgs], Ppg.count


    set_test_path("#{TESTFILE_PATH}#{DELETED_TESTFILE_NAME}")
    ret = fetch(1, 1.week, true)

    assert_equal COUNTS_DELETED[:plans],
      Plan.where(:is_deleted => true).count, "Plan deleted count"
    assert_equal COUNTS_DELETED[:ppgs],
      Ppg.where(:is_deleted => true).count, "Ppg deleted count"
    assert_equal COUNTS_DELETED[:goals],
      Goal.where(:is_deleted => true).count, "Goal deleted count"
    assert_equal COUNTS_DELETED[:outputs],
      Output.where(:is_deleted => true).count, "Output deleted count"
    assert_equal COUNTS_DELETED[:rights_groups],
      RightsGroup.where(:is_deleted => true).count, "Rights group deleted count"
    assert_equal COUNTS_DELETED[:indicator_data],
      IndicatorDatum.where(:is_deleted => true).count, "Indicator data deleted count"
    assert_equal COUNTS_DELETED[:problem_objectives],
      ProblemObjective.where(:is_deleted => true).count, "Problem Objective deleted count"
    assert_equal COUNTS_DELETED[:budgets],
      Budget.where(:is_deleted => true).count, "Budget data deleted count"
    assert_equal COUNTS_DELETED[:indicators],
      Indicator.where(:is_deleted => true).count, "Indicator deleted count"


  end

  test "find plan file" do

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
    assert_equal 2, recent_names.length, 'Should start with two files'

    plan_name = find_plan_file(id_new, 1.week)

    recent_names = Dir.glob(filename_glob(id_new))
    assert_equal 1, recent_names.length, 'Should only be one recent plan left'
    assert_equal recent_name, plan_name, 'Should have found the most recent file'


    old_names = Dir.glob(filename_glob(id_old))
    assert_equal 1, old_names.length, 'Should be one old file to start with'

    old_plan_name = find_plan_file(id_old, 1.week)

    old_names = Dir.glob(filename_glob(id_old))
    assert_equal 0, old_names.length, 'There should be no old files left'
    assert !old_plan_name, 'Should not have found a file'
  end
end
