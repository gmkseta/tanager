class SimplifiedBookkeeping < ApplicationRecord
  belongs_to :declare_user
  belongs_to :classification
  scope :card_approvals, ->{ where(purchase_type: "CardPurchasesApproval") }
  scope :hometax_cards, ->{ where(purchase_type: "HomataxCardPurchase") }

  PURCHASE_TYPES = %w(HomataxPurchasesInvoice HomataxPurchasesCashReceipt HomataxCardPurchase CardPurchasesApproval)

  class << self
    def upsert(rows:)
      SimplifiedBookkeeping.import!(
        rows,
        on_duplicate_key_update: {
            conflict_target: %i(registration_number vendor_registration_number purchase_type),
            index_predicate: "vendor_registration_number IS NOT NULL",
            columns: %i(account_classification_code classification_id amount purchases_count updated_at),
        },
      )
    end
  end
end
