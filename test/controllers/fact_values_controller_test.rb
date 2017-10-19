require 'test_helper'

class FactValuesControllerTest < ActionController::TestCase
  let(:host) { FactoryGirl.create(:host) }
  let(:fact_name) { FactoryGirl.create(:fact_name)}
  let(:fact_value) do
    FactoryGirl.create(:fact_value, :fact_name => fact_name, :host => host)
  end

  def setup
    fact_value.save!
    User.current = nil
  end

  def test_index
    get :index, {}, set_session_user
    assert_response :success
    assert_template FactValue.unconfigured? ? 'welcome' : 'index'
    assert_not_nil :fact_values
  end

  test 'user with viewer rights should succeed in viewing facts' do
    as_admin do
      users(:one).roles = [Role.default, Role.find_by_name('Viewer')]
    end
    get :index, {}, set_session_user.merge(:user => users(:one).id)
    assert_response :success
  end

  describe 'CSV Export' do
    test 'csv export works' do
      get :index, {format: :csv}, set_session_user
      assert_response :success
      body = response.body
      assert_equal 2, body.lines.size
      assert_match fact_name.name, body
    end

    test 'csv exports nested values ' do
      child_fact_name_name = [fact_name.name, "child"].join(FactName::SEPARATOR)
      as_admin do
        child_fact = FactoryGirl.create(:fact_name, :parent => fact_name,
                                        :name => child_fact_name_name)
        fact_name.update_attribute(:compose, true)
        fact_value.update_attribute(:fact_name, child_fact)
      end
      get :index, {format: :csv}, set_session_user
      body = response.body
      assert_response :success
      assert_equal 2, body.lines.size
      assert_match child_fact_name_name, body.to_s
    end
  end
end
