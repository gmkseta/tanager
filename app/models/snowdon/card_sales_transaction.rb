class Snowdon::CardSalesTransaction < Snowdon::ApplicationRecord
  self.table_name = "new_card_sales_transactions"

  belongs_to :business

  APPROVED = <<-SQL.squish.freeze
    (purchase_id IS NOT NULL AND canceled_purchase_id IS NULL)
    OR
    (purchase_id IS NULL AND canceled_approval_id IS NULL)
  SQL

  scope :approved, -> { where(APPROVED) }
end
