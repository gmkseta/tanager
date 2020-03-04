require "graphql/client/http"

module Cashnote  
  HTTPAdapter = GraphQL::Client::HTTP.new("https://api.cashnote.kr/graphql") do
    def headers(context)
      headers = {
        "Content-Type" => "application/json",
      }
      headers["Authorization"] = "Bearer #{context[:jwt]}" if context[:jwt]
      headers
    end
  end

  Client = GraphQL::Client.new(
    schema: GraphQL::Client.load_schema(HTTPAdapter),
    execute: HTTPAdapter
  )
end
