require 'test_helper'

class SearchableTest < ActiveSupport::TestCase

  def setup
    @searchables = [Operation, Indicator]

  end

  test 'paged search max results' do

    max_results = 1

    @searchables.each do |clazz|
      results = clazz.paged('*', { :per_page => max_results })
      assert_equal max_results, results.length
    end

    max_results += 1
    @searchables.each do |clazz|
      results = clazz.paged('*', { :per_page => max_results })
      assert_equal max_results, results.length
    end

  end

  test 'empty query return nothing' do
    @searchables.each do |clazz|
      results = clazz.paged('')
      assert_equal 0, results.length
    end

  end

end
