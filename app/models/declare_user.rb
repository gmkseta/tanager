class DeclareUser < ApplicationRecord
  extend AttrEncrypted
  enum status: %i(empty user deductible_persons business_expenses confirm done)

  belongs_to :user
  has_many :deductible_persons, dependent: :destroy
  has_many :business_expenses, dependent: :destroy
  has_many :simplified_bookkeepings, dependent: :destroy

  scope :individual_incomes, ->{ where(declare_type: "income") }

  validates :name, :residence_number, :address, :hometax_account, presence: true
  
  attr_encrypted :residence_number,
                 key: :encryption_key,
                 encode: true,
                 encode_iv: true,
                 encode_salt: true

  def encryption_key
    Rails.application.credentials.attr_encrypted[:encryption_key]
  end
end
