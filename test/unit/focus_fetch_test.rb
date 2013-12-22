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

  def setup
    # Change directory for testing
    set_data_dir(TESTDATA_PATH)
  end

  def teardown
    FileUtils.rm_rf("#{TESTDATA_PATH}/.", secure: true)
    FileUtils.touch("#{TESTDATA_PATH}/.gitignore")
  end

  test "Fetching from FOCUS - max files 2" do
    if ENV['LDAP_USERNAME'] && ENV['LDAP_PASSWORD']
      ret = fetch(2)

      assert_equal 2, ret[:files_read]
      assert ret[:files_total] >= 2
    end
  end

  test "Mark fetched deleted" do
    if ENV['LDAP_USERNAME'] && ENV['LDAP_PASSWORD']
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

      set_test_path("#{testfile_path}#{testfile_name}")
      ret = fetch(1, 1.week, true)

      assert_equal counts[:plans], plan.count
      assert_equal counts[:ppgs], ppg.count


      set_test_path("#{testfile_path}#{deleted_testfile_name}")
      ret = fetch(1, 1.week, true)

      assert_equal counts_deleted[:plans],
        plan.where(:is_deleted => true).count, "plan deleted count"
      assert_equal counts_deleted[:ppgs],
        ppg.where(:is_deleted => true).count, "ppg deleted count"
      assert_equal counts_deleted[:goals],
        goal.where(:is_deleted => true).count, "goal deleted count"
      assert_equal counts_deleted[:outputs],
        output.where(:is_deleted => true).count, "output deleted count"
      assert_equal counts_deleted[:rights_groups],
        rightsgroup.where(:is_deleted => true).count, "rights group deleted count"
      assert_equal counts_deleted[:indicator_data],
        indicatordatum.where(:is_deleted => true).count, "indicator data deleted count"
      assert_equal counts_deleted[:problem_objectives],
        problemobjective.where(:is_deleted => true).count, "problem objective deleted count"
      assert_equal counts_deleted[:budgets],
        budget.where(:is_deleted => true).count, "budget data deleted count"
      assert_equal counts_deleted[:indicators],
        indicator.where(:is_deleted => true).count, "Indicator deleted count"
    end


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

  test "server_params" do
    ENV['LDAP_USERNAME'] = 'rudolph@unhcr.org'

    params_string = server_params

    hash = Hash[(params_string.split(';').map { |p| p.split('=') })]

    assert_equal 'rudolph@unhcr.org', hash["user"], 'must have user'
    assert hash["IP"], "must have ip"
    assert hash["type"], "must have type"
    assert hash["ver"], "must have version"
    ENV['LDAP_USERNAME'] = nil

  end
end
