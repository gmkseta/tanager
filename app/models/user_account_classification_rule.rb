class UserAccountClassificationRule < ApplicationRecord
  belongs_to :declare_user

  validates :vendor_registration_number, presence: true
  validates :purchase_type, presence: true
end
