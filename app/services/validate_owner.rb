class ValidateOwner < Service::Base
  option :token

  def run
    account = get_account_and_businesses(token)
    business_ids = account["businesses"]["edges"].map { |b| b["node"]["id"] }
    snowdon_businesses = Snowdon::Business.where(public_id: business_ids)
    if snowdon_businesses.length > 1
      SlackBot.ping("#{Rails.env.development? ? "[테스트] " : ""} *세금신고오류* #{snowdon_businesses.first.name}님 - 신고불가(사업장갯수: #{snowdon_businesses.size})", channel: "#labs-ops")
      return false
    end
    owner_id = snowdon_businesses.map{ |s| s.owner_id }.first
    Snowdon::User.find(owner_id)
  end

  GetAccountAndBusinesses = <<~QUERY
    query getAccountAndBusinesses {
      account {
        login
        name
        phoneNumber
        businesses {
          edges {
            node {
              id
              name
              registrationNumber
            }
          }
        }
      }
    }
  QUERY

  def get_account_and_businesses(token)
    results = http_query(token, GetAccountAndBusinesses)
    results["data"]["account"]
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
end
