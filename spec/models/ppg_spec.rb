require 'spec_helper'

describe Ppg do
  fixtures :ppgs
  it "should sync models with no date" do
    models = Ppg.synced_models

    models[:deleted].count.should eq(0)
    models[:updated].count.should eq(0)
    models[:new].count.should eq(2)
  end
end
