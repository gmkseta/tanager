class Snowdon::Business < Snowdon::ApplicationRecord
  has_many :cards
  has_many :card_purchases_approvals

  has_many :hometax_cards
  has_many :hometax_card_purchases
  has_many :hometax_purchases_cash_receipts
  has_many :hometax_purchases_invoices
end