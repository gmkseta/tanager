class DeclareUser < ApplicationRecord
  extend AttrEncrypted
  include PersonalDeduction
  enum status: %i(empty user deductible_persons business_expenses confirm done)
  JSON_FIELD = %i(id name residence_number address phone_number status)

  belongs_to :user
  has_many :deductible_persons, dependent: :destroy
  has_many :business_expenses, dependent: :destroy
  has_many :simplified_bookkeepings, dependent: :destroy
  has_many :user_account_classification_rules, dependent: :destroy
  has_one :hometax_individual_income, dependent: :destroy

  scope :individual_incomes, ->{ where(declare_type: "income") }

  validate :valid_residence_number?
  validates :residence_number, presence: true, length: { is: 13 }
  validates :declare_tax_type, presence: true
  validates :name, presence: true
  validates :address, presence: true
  
  attr_encrypted :residence_number,
                 key: :encryption_key,
                 encode: true,
                 encode_iv: true,
                 encode_salt: true

  def encryption_key
    Rails.application.credentials.attr_encrypted[:encryption_key]
  end

  def deduction_amount
    amount = default_amount + 1500000
    amount -= 1500000 if dependant?
    amount
  end

  def applicable_single_parent?
    !deductible_persons.has_spouse? && deductible_persons.has_dependant_children?
  end

  def applicable_woman_deduction?
    female? && !deductible_persons.has_spouse? && deductible_persons.has_dependant?
  end
end
