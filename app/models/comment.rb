class Comment < ApplicationRecord
  belongs_to :post, counter_cache: true, touch: true
  belongs_to :user

  has_many :reactions, as: :reactable

  validates :user_id, :body, presence: true

  scope :sorted, ->{ order(:created_at) }
end
