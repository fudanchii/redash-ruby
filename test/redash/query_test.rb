require "test_helper"

describe Redash::Query do
  before do
    Redash.configure do |config|
      config.host = "https://redash.io"
      config.api_token = "test_token"
    end
    @faraday_response = Struct.new(:status, :body).new(
      200,
      "a,b,c\n1,2,3\n4,5,6\n"
    )
  end

  describe "get csv data" do
    before do
      @mock = MiniTest::Mock.new
      @mock.expect :call, @faraday_response, ["/api/queries/123/results.csv", nil]
      Redash.client.stub :get, @mock do
        @response = Redash::Query.get_csv(123).to_array
      end
    end

    it "call client.get" do
      assert_mock @mock
    end

    it "can parse csv data" do
      assert_equal 3, @response.count
    end
  end
end
