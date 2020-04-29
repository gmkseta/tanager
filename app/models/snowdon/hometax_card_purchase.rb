class Snowdon::HometaxCardPurchase < Snowdon::ApplicationRecord
  belongs_to :business
  belongs_to :hometax_business

  scope :communications, -> { where(vendor_registration_number: %w(1028142945 1048137225 2208139938 1178113423 1048143391 2148618758)) }
  scope :electricity, -> { where(vendor_registration_number: "1208200052") }
  scope :last_year, -> {where(approved_at: 1.year.ago.all_year)}
end
