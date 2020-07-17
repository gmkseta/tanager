class Snowdon::BusinessStatusForm < Snowdon::ApplicationRecord
  validates :year, presence: true
  validates :period, uniqueness: { scope: %i(business year) }, inclusion: { in: [1, 2] }
  validates :self_rental, inclusion: { in: [true, false] }
  belongs_to :business

  def first_half?
    declare_period.eql?("first_half")
  end
end
