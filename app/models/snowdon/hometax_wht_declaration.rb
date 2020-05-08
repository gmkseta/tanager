class Snowdon::HometaxWhtDeclaration < Snowdon::ApplicationRecord
  belongs_to :business

  validates :declared_at, presence: true
  validates :imputed_at, presence: true
  validates :paid_at, presence: true

  validates :declare_type, presence: true, uniqueness: { scope: %i(business declared_at imputed_at paid_at) }
  validates :declare_period, presence: true

  with_options numericality: true do
    validates :total_amount
    validates :collected_income_tax
    validates :collected_special_tax
    validates :collected_additional_tax
    validates :refunded_tax
    validates :paid_income_tax
    validates :paid_special_tax
  end

  with_options numericality: { greater_than_or_equal_to: 0 } do
    validates :fulltime_employees_count
    validates :parttime_employees_count
    validates :freelancers_count
    validates :etc_employees_count
  end
end
