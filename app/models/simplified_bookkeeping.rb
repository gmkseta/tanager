class SimplifiedBookkeeping < ApplicationRecord
  belongs_to :delcare_user

  class << self
    def upsert(rows:)
      SimplifiedBookkeeping.import!(
        rows,
        on_duplicate_key_update: {
            conflict_target: %i(registration_number vendor_registration_number purchase_type),
            columns: %i(account_classification_code account_classification_name amount purchases_count updated_at),
        },
      )
    end
  end
end
