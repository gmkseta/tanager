class DeductiblePerson < ApplicationRecord
  self.table_name = "deductible_persons"
  self.ignored_columns = ["basic_livelihood"]
  belongs_to :declare_user
  belongs_to :classification
end
