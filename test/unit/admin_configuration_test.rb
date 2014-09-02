require 'test_helper'

class AdminConfigurationTest < ActiveSupport::TestCase
  def setup
    AdminConfiguration.delete_all
  end

  test "Should only be able to create 1 admin configuration" do
    c = AdminConfiguration.new
    assert c.save

    c2 = AdminConfiguration.new
    assert !c2.save
  end

  test "Should not be able to have startyear before 2012 or after 2018" do
    c = AdminConfiguration.new :startyear => 2011
    assert !c.save

    c = AdminConfiguration.new :startyear => 2019
    assert !c.save
  end

  test "Should not be able to have endyear before 2012 or after 2018" do
    c = AdminConfiguration.new :endyear => 2011
    assert !c.save

    c = AdminConfiguration.new :endyear => 2019
    assert !c.save
  end

  test "startyear has to be less than endyear" do
    c = AdminConfiguration.new :startyear => 2014, :endyear => 2013
    assert !c.save

    c = AdminConfiguration.new :startyear => 2013, :endyear => 2013
    assert !c.save

    c = AdminConfiguration.new :startyear => 2013, :endyear => 2014
    assert c.save
  end

  test "default_reported_type has to be myr or yer" do
    c = AdminConfiguration.new :default_reported_type => 'abc'
    assert !c.save

    c = AdminConfiguration.new :default_reported_type => 'myr'
    assert c.save
  end

  test "default_aggregation_type has to be a parameter" do
    c = AdminConfiguration.new :default_aggregation_type => 'abc'
    assert !c.save

    c = AdminConfiguration.new :default_aggregation_type => 'operations'
    assert c.save
  end
end

