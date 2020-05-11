class HometaxSocialInsurance < ApplicationRecord
  belongs_to :declare_user

  scope :local, ->{ where(registration_number: [nil, '']) }
  scope :businesses, ->{ where.not(registration_number: [nil, '']) }
  scope :last_year, ->{ where(year: Date.today.last_year.year) }

  def self.local_insurances_sum
    local.sum(:amount)
  end

  def self.businesses_insurances_sum
    businesses.sum(:amount)
  end
end
