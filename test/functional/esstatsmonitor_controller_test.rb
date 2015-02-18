require 'test_helper'

class EsstatsmonitorControllerTest < ActionController::TestCase
  test "should get getstat" do
    get :getstat
    assert_response :success
  end

end
