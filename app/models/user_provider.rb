class UserProvider < ApplicationRecord
  belongs_to :user
  has_one :declare_user, through: :user
  scope :cashnote, ->{ find_by(provider: "cashnote") }
end
