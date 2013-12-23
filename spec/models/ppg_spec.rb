require 'spec_helper'

describe Ppg do
  fixtures :ppgs
  it "should sync models with no date" do
    i = [ppgs(:one), ppgs(:two)]

    i.map(&:save)

    models = Ppg.synced_models

    models[:deleted].count.should eq(0)
    models[:updated].count.should eq(0)
    models[:new].count.should eq(3)
  end
end
