class DeductiblePerson < ApplicationRecord
   belongs_to :declare_user
   belongs_to :classification
end
