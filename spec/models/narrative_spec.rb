require 'spec_helper'
require 'fakeredis'
require 'open3'

describe Narrative do

  before(:all) do
   ResqueSpec.reset!
   Redis.current = Redis.new
  end

  it "should summarize a narrative" do
    allow(Open3).to receive('popen3').and_return 'dummy'

    ids = { :operation_ids => ['BEN'] }

    token = Narrative.summarize ids

    expect(SummarizeJob).to have_queued(token, ids.merge({ :report_type => 'Mid Year Report', :year => Time.now.year }) )

    ResqueSpec.perform_next(:summarize)

    summary = Redis.current.get token
    processing = Redis.current.get "#{token}_#{SummarizeJob::PROCESSING}"

    expect(summary).to eq('')
    processing.should be_nil

    ttl = Redis.current.ttl(token)
    ttl.should be_between(0, 1.week)
  end

end

