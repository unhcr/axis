require 'test_helper'

class ParametersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  def setup
    @user = users(:one)
    sign_in @user
  end

  @parameters = [Operation, Ppg, Goal, Output, ProblemObjective, Indicator,
    StrategyObjective, Office, RightsGroup]
  @parameters.each do |p|
    test "should block access for #{p.to_s} unauthenticated access" do
      @controller = "#{p}sController".constantize.new

      sign_out @user

      get :index

      assert_response :redirect
    end

    test "should block access for #{p.to_s} search unauthenticated access" do
      @controller = "#{p}sController".constantize.new

      sign_out @user

      get :search

      assert_response :redirect
    end

    test "should block access for #{p.to_s} show unauthenticated access" do
      @controller = "#{p}sController".constantize.new

      sign_out @user

      get :show, { :id => p.first.id }

      assert_response :redirect
    end

    test "should not block access for #{p.to_s} authenticated access" do
      @controller = "#{p}sController".constantize.new

      get :index

      assert_response :success
    end
  end

end

