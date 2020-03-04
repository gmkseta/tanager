class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :user

  has_many :post_categories
  has_many :categories, through: :post_categories

  has_many :comments
  has_many :users, through: :comments

  accepts_nested_attributes_for :post_categories
  accepts_nested_attributes_for :comments
  

  validates :user_id, :title, presence: true
  validates_associated :comments

  scope :sorted, ->{ order(updated_at: :desc) }
end
