module Cashnote
  class GraphqlRequest
    def self.http_query(query, token=nil)
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
      json_body = JSON.parse(response.body)
      Rails.logger.info("response json : #{json_body}")
      json_body
    end
  end
end
