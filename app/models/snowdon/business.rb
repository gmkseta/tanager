class Snowdon::Business < Snowdon::ApplicationRecord
  has_one :hometax_business

  has_many :cards
  has_many :card_purchases_approvals

  has_many :hometax_cards
  has_many :hometax_card_purchases
  has_many :hometax_purchases_cash_receipts
  has_many :hometax_purchases_invoices

  def excluded_cards
    exclude = hometax_cards

    if exclude.empty?
      cards
    else
      cards.where.not(hometax_cards.include_number_query)
    end
  end

  def add_account_classification_code(results)
    classification =
        ClassificationCodeCategory.find_by(classification_code: hometax_business.classification_code)

    raise "#{hometax_business.inspect} is not allowed for individual_income" if classification.nil?

    rules = AccountClassificationRule
        .where(category: classification.category)
        .where(classification_codes: results.pluck(:vendor_classification_code).map{|c| c[0..1]})
        .group_by(&:classification_code).map { |k, vs| [k, vs.first] }.to_h

    results.map do |h|
      rule = rules[h[:vendor_classification_code]]
      account_classification_code =
        if rule.nil?
          h[:type] == "CardPurchasesApproval" ? nil : "812033"
        else
          rule.account_classification_code
        end

      h.attributes.merge({account_classification_code: account_classification_code})
    end
  end

  def add_classification_code(results)
    need_lookup, not_need_lookup =
        results.partition { |h| h[:vendor_registration_number].nil? }

    lookup = RegistrationNumberClassificationCode
      .where(registration_number: need_lookup.pluck(:vendor_registration_number))
      .group_by(&:registration_number)

    others = need_lookup.map do |h|
      h[:vendor_classification_code] = lookup[h[:registration_number]]
    end

    others + not_need_lookup
  end

  def calculate
    excluded_card_ids = excluded_cards.pluck(:id)

    results = hometax_card_purchases_grouped
        .union(hometax_purchases_cash_receipts_grouped)
        .union(hometax_purchases_invoices_grouped)
        .union(card_purchases_approvals_grouped(excluded_card_ids))
        # .order(sum_amount: :desc)
        # .paginate(page: page)

    with_codes = add_classification_code(results)
    add_account_classification_code(with_codes)
  end

  def hometax_card_purchases_grouped
    hometax_card_purchases
        .last_year
        .group("COALESCE(vendor_registration_number, vendor_business_name)")
        .select(<<-SQL.squish
          COALESCE(vendor_registration_number, vendor_business_name) as vendor_registration_number,
          MAX(vendor_business_name) as vendor_business_name,
          MAX(vendor_business_classification_code) as vendor_classification_code,
          SUM(amount) as sum_amount,
          'HomataxCardPurchase' as type
        SQL
        )
  end

  def hometax_purchases_cash_receipts_grouped
    hometax_purchases_cash_receipts
        .last_year
        .group("COALESCE(vendor_registration_number, vendor_business_name)")
        .select(<<-SQL.squish
          COALESCE(vendor_registration_number, vendor_business_name) as vendor_registration_number,
          MAX(vendor_business_name) as vendor_business_name,
          MAX(vendor_business_code) as vendor_classification_code,
          SUM(amount) as sum_amount,
          'HomataxPurchasesCashReceipt' as type
        SQL
        )
  end

  def hometax_purchases_invoices_grouped
    hometax_purchases_invoices
        .last_year
        .group("COALESCE(vendor_registration_number, vendor_business_name)")
        .select(<<-SQL.squish
          COALESCE(vendor_registration_number, vendor_business_name) as vendor_registration_number,
          MAX(vendor_business_name) as vendor_business_name,
          null as vendor_classification_code,
          SUM(amount) as sum_amount,
          'HomataxPurchasesInvoice' as type
        SQL
        )
  end

  def card_purchases_approvals_grouped(excluded_card_ids)
    card_purchases_approvals
        .where(id: excluded_card_ids)
        .last_year
        .group("COALESCE(vendor_registration_number, vendor_business_name)")
        .select(<<-SQL.squish
          COALESCE(vendor_registration_number, vendor_business_name) as vendor_registration_number,
          MAX(vendor_business_name) as vendor_business_name,
          null as vendor_classification_code,
          SUM(amount) as sum_amount,
          'CardPurchasesApproval' as type
        SQL
        )

  end
end