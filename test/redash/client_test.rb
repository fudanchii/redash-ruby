require "test_helper"

describe Redash::Client do
  before do
    config = Redash::Configuration.new
    config.host = "https://redash.io"
    @client ||= Redash::Client.new(config)
  end

  it "has the right host config" do
    assert @client.config.host.eql?("https://redash.io")
  end

  it "has the right token config" do
    assert @client.config.api_token.nil?
  end
end
