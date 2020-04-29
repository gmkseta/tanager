class Snowdon::HometaxCard < Snowdon::ApplicationRecord
  belongs_to :business
  belongs_to :hometax_business

  validates :issuer, presence: true
  validates :number, format: { with: /\A\d{12,19}\z/ }, uniqueness: { scope: %i(business issuer) }

  def start_digits
    number.split("********").first
  end

  def end_digits
    number.split("********").last
  end

  def self.include_number_query
    all.map{ |c| "(number LIKE '#{c.start_digits}%' AND number LIKE '%#{c.end_digits}')"}.join(" OR ")
  end
end
