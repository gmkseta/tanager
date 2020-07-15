class Snowdon::HometaxCardSale < Snowdon::ApplicationRecord
  belongs_to :business

  attribute :month, :month

  validates :month, presence: true, uniqueness: { scope: :business }
  validates :count, numericality: { greater_than_or_equal_to: 0 }

  with_options numericality: true do
    validates :amount
    validates :credit_card_amount
    validates :purchase_only_card_amount
    validates :service
  end
end
