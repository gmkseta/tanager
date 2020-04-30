class SimplifiedBookkeeping < ApplicationRecord
  belongs_to :declare_user
  belongs_to :classification

  class << self
    def upsert(rows:)
      SimplifiedBookkeeping.import!(
        rows,
        on_duplicate_key_update: {
            conflict_target: %i(registration_number vendor_registration_number purchase_type),
            columns: %i(account_classification_code classification_id amount purchases_count updated_at),
        },
      )
    end
  end
end
