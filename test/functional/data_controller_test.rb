require 'test_helper'

class DataControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  def setup
    @user = users(:one)
    sign_in @user
  end

  @parameters = [Budget, Expenditure, IndicatorDatum, Narrative]
  @parameters.each do |p|
    test "should block access for #{p.to_s} unauthenticated access" do
      @controller = "#{p.to_s.pluralize}Controller".constantize.new

      sign_out @user

      get :index

      assert_response :redirect
    end

    test "should not block access for #{p.to_s} authenticated access" do
      @controller = "#{p.to_s.pluralize}Controller".constantize.new

      get :index

      assert_response :success
    end
  end

end


