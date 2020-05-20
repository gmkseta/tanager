namespace :app do
  namespace :calculate do
    namespace :estimated_tax do
      desc "Estimated tax based on simple ratio"
      task income_tax: :environment do
        estimated_calulated_taxes = []
        hometax_individual_incomes = 
          HometaxIndividualIncome.where(<<-SQL.squish)
            account_type = '간편장부대상자'
            AND base_expense_rate = '단순경비율'
            AND declare_year = '201901' 
            AND interest_income IS FALSE 
            AND dividend_income IS FALSE 
            AND wage_single_income IS FALSE 
            AND wage_multiple_income IS FALSE 
            AND pension_income IS FALSE 
            AND other_income IS FALSE 
            AND religions_income IS FALSE 
            AND yearend_settlement_income IS FALSE 
            AND unfaithful_report_invoice_amount = 0 
            AND not_register_cash_receipts = '' 
            AND not_issued_cash_receipts_amount = 0 
            AND decline_cards_amount = 0
            AND decline_cards_count = 0
            AND decline_cash_receipts_amount = 0
            AND decline_cash_receipts_count = 0
            AND unfaithful_business_report_amount = 0
            AND no_business_account_penalty = ''
            AND id IN (
              SELECT hometax_individual_income_id
              FROM hometax_business_incomes
              WHERE hometax_individual_income_id NOT IN 
                (
                  SELECT DISTINCT(hometax_individual_income_id)
                    FROM hometax_business_incomes
                    WHERE (
                        hometax_business_incomes.classficaition_code IN ('701101', '701102', '701103' ,'701104', '701301')
                      )
                      OR (business_type = '공동') 
                      OR (registration_number = '') 
                    GROUP BY hometax_business_incomes.hometax_individual_income_id
                    HAVING COUNT(DISTINCT(registration_number)) = 1
                )
            )
          SQL
        hometax_individual_incomes.each do |h|
          calculated_tax_by_ratio = IndividualIncome::CalculatedTax.new(
            business_incomes: h.business_income_sum,
            expenses: h.expenses_sum_by_ratio,
            income_deduction: 1500000,
            tax_exemption: 0,
            tax_credit: 90000,
            penalty_tax: 0,
            prepaid_tax: 0,
          )
          e = EstimatedCalulatedIncomeTax.new(
            calculated_tax_by_ratio.as_json.merge({
              account_type: h.account_type,
              base_expense_rate: h.base_expense_rate,
              base_ratio: h.base_ratio_basic,
              simple_ratio: h.simple_ratio_basic,
              owner_id: h.owner_id,
              year: 2019,
              income_deduction: 1500000,
              personal_deduction: 1500000,
              online_declare_credit_amount: 20000,
            })
            
          )
          estimated_calulated_taxes << e
        end
        EstimatedCalulatedIncomeTax.import!(estimated_calulated_taxes)
      end
    end
  end
end