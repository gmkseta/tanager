class SimplifiedBookkeeping < ApplicationRecord
  self.per_page = 10000
  belongs_to :declare_user
  belongs_to :classification
  scope :card_approvals, ->{ where(purchase_type: "CardPurchasesApproval") }
  scope :hometax_cards, ->{ where(purchase_type: "HomataxCardPurchase") }
  scope :deductibles, ->{ where(deductible: [true, nil]) }

  PURCHASE_TYPES = %w(HomataxPurchasesInvoice HomataxPurchasesCashReceipt HomataxCardPurchase CardPurchasesApproval)

  class << self
    def upsert(rows:)
      SimplifiedBookkeeping.import!(
        rows,
        on_duplicate_key_update: {
            conflict_target: %i(registration_number vendor_registration_number purchase_type),
            index_predicate: "vendor_registration_number IS NOT NULL",
            columns: %i(account_classification_code classification_id amount purchases_count updated_at deductible),
        },
      )
    end
  end

  def classification_name
    classification.name
  end

  def purchase_type_name
    purchase_type_name = case purchase_type
      when "CardPurchasesApproval"
        "개인카드"
      when "HomataxCardPurchase"
        "사업용카드"
      when "HomataxPurchasesInvoice"
        "세금계산서"
      when "HomataxPurchasesCashReceipt"
        "현금영수증"
      end
    purchase_type_name
  end
end
