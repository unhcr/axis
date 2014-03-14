require 'test_helper'

class ExportModulesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @user = users(:one)
    sign_in @user

    @user.export_modules << export_modules(:one)
  end

  test 'export module create' do
    post :create, { :export_module =>
      {
        :title => 'title',
        :description => 'descrip',
        :state => { :year => 2012,
                    :amount_type => 'a type',
                    :selected => {
                      :plan_ids => {
                        'abc' => true
                      }

                    }
                  },
        :figure_config => { :data => [{ :value => 1 }] }
      }
    }

    assert_response :success

    r = JSON.parse(response.body)
    m = ExportModule.find(r['id'])

    assert_equal '2012', m.state['year'], 'Year should be 2012'
    assert_equal 'a type', m.state['amount_type'], 'Amount type should "a type"'
    assert m.state['selected']['plan_ids']['abc'], 'plan_id abc should be true'
    assert_equal '1', m.figure_config['data'][0]['value']
    assert_equal m.user.id, @user.id, 'Should belong to the user signed in'
    assert_equal m.include_parameter_list, false, 'Default parameter list value'
    assert_equal m.include_explaination, false, 'Default explaination value'
  end

  test 'export module update' do
    post :create, {}
    r = JSON.parse(response.body)
    m = ExportModule.find(r['id'])

    post :update, { :id => m.id, :export_module =>
      {
        :title => 'title',
        :description => 'descrip',
        :state => { :year => 2012,
                    :amount_type => 'a type',
                    :selected => {
                      :plan_ids => {
                        'abc' => true
                      }

                    }
                  },
        :figure_config => { :data => [{ :value => 1 }] }
      }
    }

    m.reload

    assert_equal '2012', m.state['year'], 'Year should be 2012'
    assert_equal 'a type', m.state['amount_type'], 'Amount type should "a type"'
    assert m.state['selected']['plan_ids']['abc'], 'plan_id abc should be true'
    assert_equal '1', m.figure_config['data'][0]['value']
    assert_equal m.user.id, @user.id, 'Should belong to the user signed in'
    assert_equal m.include_parameter_list, false, 'Default parameter list value'
    assert_equal m.include_explaination, false, 'Default explaination value'
  end

  test 'should not be able to create export module' do
    sign_out @user

    get :create, { :export_module =>
      {
        :title => 'title',
        :description => 'descrip',
        :state => { :year => 2012,
                    :amount_type => 'a type',
                    :selected => {
                      :plan_ids => {
                        'abc' => true
                      }

                    }
                  },
        :figure_config => { :data => [{ :value => 1 }] }
      }
    }

    assert_response :found
  end

  test 'should get list of export modules' do
    get :index

    r = JSON.parse(response.body)
    assert_equal 1, r.length
    assert_equal r[0]['title'], export_modules(:one).title
  end

end

