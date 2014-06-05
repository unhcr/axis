require 'test_helper'

class ParserTest < ActiveSupport::TestCase

  include Parsers
  def setup
    @parser = Parsers::Parser.new
  end

  test 'Replace nulls' do
    row = {
      :a => Parsers::Parser::NULL,
      :b => 'something',
      :c => nil,
      :d => 2,
      :e => true,
    }
    mapped = @parser.replace_nulls row

    assert_nil mapped[:a]
    assert_equal mapped[:b], 'something'
    assert_nil mapped[:c]
    assert_equal mapped[:d], 2
    assert mapped[:e]
  end
end
