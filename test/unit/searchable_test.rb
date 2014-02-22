require 'test_helper'

class SearchableTest < ActiveSupport::TestCase

  def setup
    @searchables = [Operation, Ppg, Goal, Output, ProblemObjective, Indicator]

  end

  test 'paged search max results' do

    max_results = 1

    @searchables.each do |clazz|
      results = clazz.search_models('*', { :per_page => max_results })
      assert_equal max_results, results.length, "Should have found #{max_results} for #{clazz.to_s}"
    end

    max_results += 1
    @searchables.each do |clazz|
      results = clazz.search_models('*', { :per_page => max_results })
      assert_equal max_results, results.length, "Should have found #{max_results} for #{clazz.to_s}"
    end

  end

  test 'empty query return nothing' do
    @searchables.each do |clazz|
      results = clazz.search_models('')
      assert_equal 0, results.length
    end

  end

end
