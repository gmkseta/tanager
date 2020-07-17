module Cashnote
  class GraphqlRequest
    extend Dry::Initializer

    param :query
    option :token

    def http_query
      header = {
        "X-Bluebird-Api-Key": Rails.application.credentials[Rails.env.to_sym].dig(:snowdon_api, :key),
        "Content-Type": "application/json",
      } if token.nil?
      header ||= { "Authorization": "Bearer #{token}", "Content-Type": "application/json" }      
      http_request(header, query)
    end

    private

    def http_request(header, query)
      uri = URI.parse(Rails.env.development? ? "https://staging-api.cashnote.kr/graphql" : "https://api.cashnote.kr/graphql")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = { query: query }.to_json
      response = http.request(request)
      raise Net::HTTPBadResponse unless response.code.eql?("200")
      JSON.parse(response.body)
    end
  end
end
