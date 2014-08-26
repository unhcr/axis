require 'test_helper'

class StrategyObjectivesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    StrategyObjective.index_name('test_' + StrategyObjective.model_name.plural)
    StrategyObjective.index.delete
    StrategyObjective.create_elasticsearch_index


    StrategyObjective.index.import [strategy_objectives(:one), strategy_objectives(:two)]
    StrategyObjective.index.refresh
    @user = users(:one)
    sign_in @user
  end

  test 'Should get index' do
    get :index

    assert_response :success

    so = JSON.parse(response.body)
    assert_equal so.length, 2
  end

  test 'Should get index with where parameter' do
    so = strategy_objectives(:one)
    so.strategy_id = 3
    so.save

    get :index, { :where => { :strategy_id => 3 } }
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal json.length, 1
    assert_equal json[0]['id'], so.id
  end

  test 'Should get strategy objetctive show' do
    so = strategy_objectives(:one)

    get :show, { :id => so.id }

    assert_response :success
    json = JSON.parse(response.body)

    assert_equal json['id'], so.id
  end

  test 'Search strategy objectives' do

    get :search, { :query => 'Boy' }

    assert_response :success
    json = JSON.parse(response.body)

    assert_equal json.length, 1
    assert_equal json[0]['id'].to_i, StrategyObjective.where(:name => 'Boys').first.id
  end
  test 'Search strategy objectives with quote' do

    get :search, { :query => 'Boy"' }

    assert_response :success
    json = JSON.parse(response.body)

    assert_equal json.length, 1
    assert_equal json[0]['id'].to_i, StrategyObjective.where(:name => 'Boys').first.id
  end

end

