require 'test_helper'

class NarrativeTest < ActiveSupport::TestCase

  test "total_characters" do

    result = Narrative.total_characters({ :operation_ids => ['BEN', 'LISA'] })
    assert_equal result.values[0][0].to_i, 7

  end
end
