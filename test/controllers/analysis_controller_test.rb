require "test_helper"

class AnalysisControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get analysis_index_url
    assert_response :success
  end
end
