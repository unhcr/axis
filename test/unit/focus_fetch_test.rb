require 'test_helper'

class FocusFetchTest < ActiveSupport::TestCase
  fixtures :all
  include FocusFetch

  TESTDATA_PATH = "#{Rails.root}/test/files/focus"
  def setup
  end

  def teardown
    FileUtils.rm_rf("#{TESTDATA_PATH}/.", secure: true)
  end

  test "Fetching from FOCUS - max files 2" do
    ret = fetch(2)

    assert_equal 2, ret[:files_read]
    assert ret[:files_total] >= 2
  end

  test "find plan file" do

    id_new = 'recent'
    id_old = 'old'

    # Change directory for testing
    FocusFetch::DIR = TESTDATA_PATH

    f = File.new("#{DIR}/#{PLAN_PREFIX}#{id_old}__#{(Time.now - 2.weeks).to_i}#{PLAN_SUFFIX}", 'w')
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
