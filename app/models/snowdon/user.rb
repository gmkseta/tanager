class Snowdon::User < Snowdon::ApplicationRecord
  has_many :businesses, foreign_key: "owner_id", class_name: "Business"
  has_many :hometax_businesses, through: :businesses
end
