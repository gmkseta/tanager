namespace :app do
  namespace :calculate do
    namespace :estimated_tax do
      desc "Estimated tax based on simplified bookkeping"
      task income_tax_bookkeeping: :environment do
        estimated_calulated_taxes = []
        hometax_individual_incomes =
          incomes_query_to_possible_declare("기준경비율")
        results = {}
        owner_ids = hometax_individual_incomes.map(&:owner_id)
        users = Snowdon::User.where(id: owner_ids)
                             .includes(:businesses)
                             .joins(:hometax_businesses)
        users.each do |u|
          amount = 0
          u.hometax_businesses.each do |h_b|
            next if (h_b.classification_code.nil?) || (ClassificationCodeCategory.find_by(classification_code: h_b.classification_code).nil?)
            calculated_expenses = h_b.business.calculate(nil).select {
              |d| d[:deductible] == true
              }.map{
                |c| c[:amount]
              }.sum
            amount += calculated_expenses
          end
          results.merge!({ "#{u.id}": amount })
        end
        hometax_individual_incomes.each do |h|
          income_deduction = 1500000 + h.personal_pension_deduction
          calculated_tax_by_bookkeeping = IndividualIncome::CalculatedTax.new(
            business_incomes: h.business_income_sum,
            expenses: results[:"#{h.owner_id}"] || 0,
            income_deduction: income_deduction,
            tax_exemption: 0,
            tax_credit: 70000,
            penalty_tax: 0,
            prepaid_tax: 0,
          )
          next if (calculated_tax_by_bookkeeping.business_incomes < calculated_tax_by_bookkeeping.expenses) ||
            (calculated_tax_by_bookkeeping.business_incomes * 0.1 < calculated_tax_by_bookkeeping.total_income)
          e = EstimatedCalulatedIncomeTax.new(
            calculated_tax_by_bookkeeping.as_json.merge({
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
        EstimatedCalulatedIncomeTax.import!(
          estimated_calulated_taxes,
          on_duplicate_key_update: {
            conflict_target: %i(owner_id year),
            columns: %i(business_incomes expenses total_income income_deduction calculated_tax determined_tax tax_credit payment_tax payment_local_tax updated_at),
          },
        )
      end
      desc "Estimated tax based on simple ratio"
      task income_tax_ratio: :environment do
        estimated_calulated_taxes = []
        hometax_individual_incomes =
          incomes_query_to_possible_declare("단순경비율")
        hometax_individual_incomes.each do |h|
          income_deduction = 1500000 + h.personal_pension_deduction
          calculated_tax_by_ratio = IndividualIncome::CalculatedTax.new(
            business_incomes: h.business_income_sum,
            expenses: h.expenses_sum_by_ratio,
            income_deduction: 1500000,
            tax_exemption: 0,
            tax_credit: 70000,
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
        EstimatedCalulatedIncomeTax.import!(
          estimated_calulated_taxes,
          on_duplicate_key_update: {
            conflict_target: %i(owner_id year),
            columns: %i(calculated_tax determined_tax tax_credit payment_tax payment_local_tax updated_at),
          },
        )
      end
    end
  end
end

def incomes_query_to_possible_declare(base_expense_rate)
  hometax_individual_incomes = 
    HometaxIndividualIncome.includes(:hometax_business_incomes)
      .where(<<-SQL.squish)
        account_type = '간편장부대상자'
        AND base_expense_rate = '#{base_expense_rate}'
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
end