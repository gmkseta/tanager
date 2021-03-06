class HometaxController < ApplicationController
  before_action :authorize_owl_request

  def scraped_callback
    if params[:owner_id].present?
      owner_id = params[:owner_id]
      hometax_individual_income = HometaxIndividualIncome.find_by(
        owner_id: owner_id,
        declare_year: "#{Date.today.last_year.year}01"
      )
      available = hometax_individual_income.present? && hometax_individual_income.declarable?
      hometax_businesses = Snowdon::User.find(owner_id).hometax_businesses

      if available && hometax_businesses.count == 1
        hometax_business = hometax_businesses.first
        opened_at = hometax_business.opened_at || "20190101"
        available = opened_at.to_date.year != Date.today.year

        available = available && hometax_individual_income.hometax_business_incomes
          .where.not(registration_number: hometax_business.business.registration_number)
          .none?
      else
        availalbe = false
      end

      year = 1.year.ago.year
      query = <<~QUERY
        mutation {
          updateIndividualIncomeTaxReturnProxyAvailability(input: {
            userId: #{owner_id}
            year: #{year}
            available: #{available}
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
      results = response.dig("data", "updateIndividualIncomeTaxReturnProxyAvailability")
      if results.dig("result", "message").present?
        message = results.dig("result", "message")
        Rails.logger.info("updateIndividualIncomeTaxReturnProxyAvailability message : #{message}")
        SendSlackMessageJob.perform_later(
          "⚠️*종소세 수집오류* #{message}",
          "#tax-ops"
        )
      end
      EstimateIncomeTaxJob.perform_later(owner_id) if available
      head :ok
    else
      head :unprocessable_entity
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
