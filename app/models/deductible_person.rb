class DeductiblePerson < ApplicationRecord
  self.table_name = "deductible_persons"
  belongs_to :declare_user
  belongs_to :classification
end
