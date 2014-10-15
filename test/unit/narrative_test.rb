require 'test_helper'

class NarrativeTest < ActiveSupport::TestCase
  def setup
    Narrative.index_name('test_' + Narrative.model_name.plural)
    Narrative.index.delete
    Narrative.create_elasticsearch_index

    one = self.send(Narrative.table_name, :one)
    two = self.send(Narrative.table_name, :two)
    Narrative.index.import [one, two]
    Narrative.index.refresh
  end

  test "total_characters" do

    result = Narrative.total_characters({ :operation_ids => ['BEN', 'LISA'] })
    assert_equal result.values[0][0].to_i, 7

  end

  test "narrative search - basic" do
    result = Narrative.search_models('*')

    assert_equal result.length, 2
  end

  test "narrative search - paged" do
    result = Narrative.search_models('*', {}, nil, nil, { :page => 2 })

    assert_equal result.length, 0

  end

  test "narrative search - year" do
    result = Narrative.search_models('*', {}, nil, 2012)

    assert_equal result.length, 1
  end

  test "narrative search - report" do
    result = Narrative.search_models('*', {}, 'reportone', nil)

    assert_equal result.length, 1
  end

  test "narrative search - txt" do
    result = Narrative.search_models('ben')

    assert_equal result.length, 1
  end

  test "narrative search - ids" do
    result = Narrative.search_models('ben', { :operation_ids => ['BEN'], :ppg_ids => ['MY', 'GOD'] })

    assert_equal result.length, 1

  end

  test "narrative search - empty query" do
    result = Narrative.search_models('')
    assert_equal result.length, 0

    result = Narrative.search_models(nil)
    assert_equal result.length, 0
  end
end
