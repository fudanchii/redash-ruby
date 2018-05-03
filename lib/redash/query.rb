require "tempfile"

module Redash
  class Query
    class << self
      def get_csv(query_id, key = nil)
        get(query_id, :csv, key)
      end

      def get_json(query_id, key = nil)
        get(query_id, :json, key)
      end

      private

      def get(query_id, format, key)
        new(format: format, query_id: query_id, key: key)
      end
    end

    def initialize(config)
      @format = config [:format]
      @query_id = config[:query_id]
      @key = config[:key]
      @http_timeout = ENV.fetch("HTTP_TIMEOUT", config[:timeout] || 30).to_i
    end

    def to_file(filename)
      tempfile = Tempfile.open
      tempfile.write(fetch.body)
      tempfile.fsync
      File.rename(tempfile.path, filename)
    end

    def to_array
      fn = "#{@format.to_s}_to_array"
      send(fn)
    end

    def to_string
      fetch.body
    end

    private

    def ok?(response)
      (response.status.to_i / 100) == 2
    end

    def fetch
      params = { key: @key } if @key
      response = Redash.client
        .get("/api/queries/#{@query_id}/results.#{@format.to_s}", params) do |req|
        req.options.timeout = @http_timeout
      end
      raise ClientError.new(response) unless ok?(response)
      response
    end

    def csv_to_array
      require "csv"
      CSV
        .parse(fetch.body, headers: true, return_headers: false)
        .by_row!
        .to_a
    end

    def json_to_array
      MultiJson.load(fetch.body)
    end
  end
end
