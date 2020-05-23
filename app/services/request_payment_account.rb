class RequestPaymentAccount < Service::Base
  option :token

  GetIndividualIncomeTaxReturn = <<~QUERY
    query getIndividualIncomeTaxReturn {
      account {
        individualIncomeTaxReturn(year: #{2019}) {
          status
          nationalTaxPayment {
            amount
            paymentDueBy
            paymentAccounts {
              bankName
              accountNumber
            }
          }
          localTaxPayment {
            amount
            paymentDueBy
            paymentAccounts {
              bankName
              accountNumber
            }
          }
        }
      }
    }
  QUERY

  def run
    response = Cashnote::GraphqlRequest.http_query(token, GetIndividualIncomeTaxReturn)
    error_message = response.dig("errors")
    if error_message.present?
      Rails.logger.info("error_message : #{error_message}")
      SlackBot.ping("#{Rails.env.development? ? "[테스트] " : ""} ⚠️*결제계좌 요청 오류* #{error_message}", channel: "#tax-ops")
      return nil
    end
    individual_income_tax_return = {}
    account = response.dig("data", "account")
    status = account&.dig("individualIncomeTaxReturn", "status")
    if ["PAID", "FINISHED"].any?(status)
      national_tax = account&.dig("individualIncomeTaxReturn","nationalTaxPayment")
      if national_tax
        individual_income_tax_return.merge!(
          national_tax: {
            tax_payment: national_tax["amount"],
            payment_due_date: national_tax["paymentDueBy"] || "2020-08-31",
            payment_account_numbers: national_tax["paymentAccounts"]&.map {
              |n| {
                    "bank_name": n["bankName"],
                    "account_number": n["accountNumber"]
                  }
                } || [],
              }
          )
      else
        individual_income_tax_return.merge!(national_tax: nil)
      end
      local_tax = account&.dig("individualIncomeTaxReturn","localTaxPayment")
      if local_tax
        individual_income_tax_return.merge!(
          local_tax: {
            tax_payment: local_tax["amount"],
            payment_due_date: national_tax["paymentDueBy"] || "2020-08-31",
            payment_account_numbers: national_tax["paymentAccounts"]&.map {
              |n| {
                    "bank_name": n["bankName"],
                    "account_number": n["accountNumber"]
                  }
                } || [],
              }
          )
      else
        individual_income_tax_return.merge!(local_tax: nil)
      end
      return individual_income_tax_return
    end
    nil
  end
end