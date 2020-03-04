class Category < ApplicationRecord
  
  extend FriendlyId
  friendly_id :name, use: :slugged

  scope :sorted, ->{ order(id: :asc) }

  validates :name, :slug, :color, presence: true

  def color
    colour = super
    colour.start_with?("#") ? colour : "##{colour}"
  end
end
