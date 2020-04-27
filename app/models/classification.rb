class Classification < ApplicationRecord
  scope :relations, ->{ where(classification_type: "Relation") }
end
