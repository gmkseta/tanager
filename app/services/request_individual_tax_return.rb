class RequestIndividualTaxReturn < Service::Base
  option :token

  GetIndividualIncomeTaxReturn = <<~QUERY
    query getIndividualIncomeTaxReturn {
      account {
        individualIncomeTaxReturn(year: #{2019}) {
          status
        }
      }
    }
  QUERY

  def run
    response = http_query(token, GetIndividualIncomeTaxReturn)
    error_message = response.dig("errors")
    if error_message.present?
      Rails.logger.info("error_message : #{error_message}")
      return nil
    end
    account = response.dig("data", "account")
    status = account&.dig("individualIncomeTaxReturn", "status")
    return "declare" if "PAID".eql?(status)
    return "done" if "FINISHED".eql?(status)
  end
end

def http_query(token, query)
  uri = URI.parse(Rails.env.development? ? "https://staging-api.cashnote.kr/graphql" : "https://api.cashnote.kr/graphql")
  header = { "Authorization": "Bearer #{token}", "Content-Type": "application/json" }
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Post.new(uri.request_uri, header)
  request.body = { query: query }.to_json
  response = http.request(request)
  json_body = JSON.parse(response.body)
  Rails.logger.info("response json : #{json_body}")
  json_body
end