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
      SendSlackMessageJob.perform_later(
        "⚠️*결제계좌 요청 오류* #{error_message}",
        "#tax-ops"
      )
      return nil
    end
    individual_income_tax_return = {}
    account = response.dig("data", "account")
    status = account&.dig("individualIncomeTaxReturn", "status")
    if ["PAID", "FINISHED"].any?(status)
      individual_income_tax_return.merge!({
        declared_date:  account&.dig("individualIncomeTaxReturn", "finishedAt") || "#{Date.today.strftime}"
      })
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
            payment_due_date: local_tax["paymentDueBy"] || "2020-08-31",
            payment_account_numbers: local_tax["paymentAccounts"]&.map {
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
    {}
  end
end