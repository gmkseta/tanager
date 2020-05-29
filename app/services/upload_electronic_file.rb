class UploadElectronicFile < Service::Base
  option :owner_id
  option :year
  option :file_string

  def run
    query = <<~QUERY
      mutation {
        uploadIndividualIncomeTaxReturnElectronicFile(input: {
          userId: #{owner_id}
          year: #{year}
          file: "#{file_string}"
        }){
          result {
            ... on ExecutionError {
              message
            }
          }
        }
      }
    QUERY
    response = http_query(query)
    results = response.dig("data", "uploadIndividualIncomeTaxReturnElectronicFile")
    if results.dig("result", "message").present?
      Rails.logger.info("error_message : #{results.dig("result", "message")}")
      SendSlackMessageJob.perform_later(
        "⚠️⚠️⚠️*파일업로드 오류* owner_id: #{owner_id}, #{results.dig("result", "message")}",
        "#tax-ops"
      )
      return nil
    end    
  end

  def http_query(query)
    uri = URI.parse(Rails.env.development? ? "https://staging-api.cashnote.kr/graphql" : "https://api.cashnote.kr/graphql")
    header = {
      "X-Bluebird-Api-Key": Rails.application.credentials[Rails.env.to_sym].dig(:snowdon_api, :key),
      "Content-Type": "application/json",
    }
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
