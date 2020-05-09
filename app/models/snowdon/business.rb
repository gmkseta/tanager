class Snowdon::Business < Snowdon::ApplicationRecord
  has_one :hometax_business

  has_many :cards
  has_many :card_purchases_approvals

  has_many :hometax_cards
  has_many :hometax_card_purchases
  has_many :hometax_purchases_cash_receipts
  has_many :hometax_purchases_invoices
  has_many :hometax_wht_declarations

  def excluded_cards
    exclude = hometax_cards

    if exclude.empty?
      cards
    else
      cards.where.not(hometax_cards.include_number_query)
    end
  end

  def vendor_classification_codes(results)
    results
        .reject {|x| x.vendor_classification_code.nil? }
        .pluck(:vendor_classification_code)
        .map{|c| c[0..1] }
        .uniq
  end

  def account_classification_rules(classification, vendor_classification_codes)
    AccountClassificationRule
        .where(category: classification.category)
        .where(classification_code: vendor_classification_codes)
        .group_by(&:classification_code).map { |k, vs| [k, vs.first] }.to_h
  end

  def add_account_classification_code(classification, results, declare_user_id)
    rules = account_classification_rules(classification, vendor_classification_codes(results))
    user_rules = UserAccountClassificationRule.where(declare_user_id: declare_user_id).group_by{ |r| "#{r.vendor_registration_number}:#{r.purchase_type}" }
    results.map do |h|
      merge_data = {
        declare_user_id: declare_user_id,
        business_id: id,
        registration_number: registration_number,
      }
      user_rule = user_rules["#{h.vendor_registration_number}:#{h.purchase_type}"]
      if user_rule.present?
        merge_data[:classification_id] = user_rule.first.classification_id
        merge_data[:account_classification_code] = ''
      else
        rule = h[:vendor_classification_code].nil? ? nil : rules[h[:vendor_classification_code][0..1]]
        account_classification_code =
          if rule.nil?
            h[:purchase_type] == "CardPurchasesApproval" ? nil : "812033"
          else
            rule.account_classification_code
          end
        merge_data[:classification_id] = rule&.classification_id || 32
        merge_data[:account_classification_code] = account_classification_code
      end
      h.attributes.merge(merge_data).symbolize_keys
    end
  end

  def add_user_account_classification_code(classification, declare_user_id)
    rules = account_classification_rules(classification, vendor_classification_codes(results))

    results.map do |h|
      rule = h[:vendor_classification_code].nil? ? nil : rules[h[:vendor_classification_code][0..1]]

      account_classification_code =
        if rule.nil?
          h[:purchase_type] == "CardPurchasesApproval" ? nil : "812033"
        else
          rule.account_classification_code
        end

      h.attributes.merge({
        declare_user_id: declare_user_id,
        account_classification_code: account_classification_code,
        classification_id: rule&.classification_id || 32,
        business_id: id,
        registration_number: registration_number
      })
    end
  end

  def add_classification_code(results)
    need_lookup, not_need_lookup = results.partition { |h| h[:vendor_classification_code].nil? }

    lookup = RegistrationNumberClassificationCode
      .where(registration_number: need_lookup.pluck(:vendor_registration_number))
      .group_by(&:registration_number).map {|k, vs| [k, vs.first]}.to_h

    others = need_lookup.map do |h|
      h[:vendor_classification_code] = lookup[h[:vendor_registration_number]]&.classification_code
      h
    end

    others + not_need_lookup
  end

  def wage
    rows = hometax_wht_declarations
        .where(imputed_at: 1.year.ago.all_year)
        .to_a

    max_declared_ats = rows
        .group_by {|r| r.imputed_at }
        .map {|k, vs| [k, vs.map(&:declared_at).max]}.to_h

    rows
        .select { |r| r.declared_at == max_declared_ats[r.imputed_at]}
        .map { |r| (r.fulltime_employees_payments || 0) + (r.parttime_employees_payments || 0) }
        .reduce(:+)
  end

  def balance(results)
    welfare = Classification.find_by(name: "복리후생비")
    etc = Classification.find_by(name: "기타비용")

    if wage == 0
      results.map do |row|
        row[:classification_id] = (row[:classification_id] == welfare.id) ? etc.id : row[:classification_id]
      end
    else
      matched, others = results.partition {|row| row[:classification_id] == welfare.id }
      matched_sum = matched.map{|r| r[:amount]}.reduce(:+)

      ratio = matched_sum / wage.to_f

      if ratio < 0.3
        matched + others
      else
        sorted = matched.sort_by{|r| r[:amount]}

        replaces = []
        while !sorted.empty? && matched_sum > wage * 0.3
          current = sorted.shift
          current[:classification_id] = etc.id
          replaces << current
        end

        replaces + sorted + others
      end
    end
  end

  def calculate(declare_user_id)
    classification =
        ClassificationCodeCategory.find_by(classification_code: hometax_business.classification_code)

    raise "#{hometax_business.inspect} is not allowed for individual_income" if classification.nil?

    excluded_card_ids = excluded_cards.pluck(:id)

    results = hometax_card_purchases_grouped
        .union(hometax_purchases_cash_receipts_grouped)
        .union(hometax_purchases_invoices_grouped)
        .union(card_purchases_approvals_grouped(excluded_card_ids))

    with_classification_codes = add_classification_code(results)
    with_account_classification_codes =
        add_account_classification_code(classification, with_classification_codes, declare_user_id)

    balance(with_account_classification_codes)
  end

  def hometax_card_purchases_grouped
    hometax_card_purchases
        .last_year
        .group("COALESCE(vendor_registration_number, vendor_business_name)")
        .select(<<-SQL.squish
          COALESCE(vendor_registration_number, vendor_business_name) as vendor_registration_number,
          MAX(vendor_business_name) as vendor_business_name,
          MAX(vendor_business_classification_code) as vendor_classification_code,
          SUM(amount) as amount,
          COUNT(*) as purchases_count,
          'HomataxCardPurchase' as purchase_type
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
          SUM(amount) as amount,
          COUNT(*) as purchases_count,
          'HomataxPurchasesCashReceipt' as purchase_type
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
          SUM(amount) as amount,
          COUNT(*) as purchases_count,
          'HomataxPurchasesInvoice' as purchase_type
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
          SUM(amount) as amount,
          COUNT(*) as purchases_count,
          'CardPurchasesApproval' as purchase_type
        SQL
        )

  end
end