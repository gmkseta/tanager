module IndividualIncome
  class AccountClassificationClassifier
    # ActiveRecordRelation
    def initialize(classification_code_category,
                   cards,
                   hometax_cards,
                   hometax_card_purchases,
                   hometax_purchases_cash_receipts,
                   hometax_purchases_invoices,
                   card_purchases_approvals
                   )
      @classification_code_category = classification_code_category
      @cards = cards
      @hometax_cards = hometax_cards
      @hometax_card_purchases = hometax_card_purchases
      @hometax_purchases_cash_receipts = hometax_purchases_cash_receipts
      @hometax_purchases_invoices = hometax_purchases_invoices
      @card_purchases_approvals = card_purchases_approvals
    end

    def excluded_cards
      @hometax_cards.empty? ? @cards : @cards.where.not(@hometax_cards.include_number_query)
    end

    def group_records
      excluded_card_ids = excluded_cards.pluck(:id)

      hometax_card_purchases_grouped
          .union(hometax_purchases_cash_receipts_grouped)
          .union(hometax_purchases_invoices_grouped)
          .union(card_purchases_approvals_grouped(excluded_card_ids))
    end

    def hometax_card_purchases_grouped
      @hometax_card_purchases
          .last_year
          .group("COALESCE(vendor_registration_number, vendor_business_name)")
          .select(hometax_card_purchases_select)
    end

    def hometax_purchases_cash_receipts_grouped
      @hometax_purchases_cash_receipts
          .last_year
          .group("COALESCE(vendor_registration_number, vendor_business_name)")
          .select(hometax_purchases_cash_receipts_select)
    end

    def hometax_purchases_invoices_grouped
      @hometax_purchases_invoices
          .last_year
          .group("COALESCE(vendor_registration_number, vendor_business_name)")
          .select(hometax_purchases_invoices_select)
    end

    def card_purchases_approvals_grouped(excluded_card_ids)
      @card_purchases_approvals
          .where(id: excluded_card_ids)
          .last_year
          .group("COALESCE(vendor_registration_number, vendor_business_name)")
          .select(card_purchases_approvals_select)
    end

    def hometax_card_purchases_select
      <<-SQL.squish
          COALESCE(vendor_registration_number, vendor_business_name) as vendor_registration_number,
          MAX(vendor_business_name) as vendor_business_name,
          MAX(vendor_business_classification_code) as vendor_classification_code,
          SUM(amount) as amount,
          COUNT(*) as purchases_count,
          'HomataxCardPurchase' as purchase_type
      SQL
    end

    def hometax_purchases_cash_receipts_select
      <<-SQL.squish
          COALESCE(vendor_registration_number, vendor_business_name) as vendor_registration_number,
          MAX(vendor_business_name) as vendor_business_name,
          MAX(vendor_business_code) as vendor_classification_code,
          SUM(amount) as amount,
          COUNT(*) as purchases_count,
          'HomataxPurchasesCashReceipt' as purchase_type
      SQL
    end

    def hometax_purchases_invoices_select
      <<-SQL.squish
          COALESCE(vendor_registration_number, vendor_business_name) as vendor_registration_number,
          MAX(vendor_business_name) as vendor_business_name,
          null as vendor_classification_code,
          SUM(amount) as amount,
          COUNT(*) as purchases_count,
          'HomataxPurchasesInvoice' as purchase_type
      SQL
    end

    def card_purchases_approvals_select
      <<-SQL.squish
          COALESCE(vendor_registration_number, vendor_business_name) as vendor_registration_number,
          MAX(vendor_business_name) as vendor_business_name,
          null as vendor_classification_code,
          SUM(amount) as amount,
          COUNT(*) as purchases_count,
          'CardPurchasesApproval' as purchase_type
      SQL
    end

  end
end
