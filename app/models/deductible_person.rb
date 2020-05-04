class DeductiblePerson < ApplicationRecord
  self.table_name = "deductible_persons"
  self.ignored_columns = ["basic_livelihood"]
  include PersonalDeduction

  belongs_to :declare_user
  belongs_to :classification

  validate :valid_residence_number?
  validates :residence_number, presence: true, length: { is: 13, message: :invalid }
  validates :classification_id, presence: true, inclusion: { in: Classification.relations.ids, message: :invalid_type }
  validates :name, presence: true
  validates :residence_number, uniqueness: {scope: [:declare_user_id], message: :taken}

  def spouse?
    classification_id == 1
  end

  def dependant_children?
    20 >= age && [2, 8].any?(classification_id)
  end

  def deduction_amount
    amount = default_amount
    if spouse?
      amount += 1500000
      amount -= 1500000 if dependant?
    end
    amount
  end

  def self.has_spouse?
    select{ |d| d.classification_id == 1 }.length > 0
  end

  def self.has_dependant_children?
    select{ |d| d.dependant_children? }.length > 0
  end

  def self.has_dependant?
    select{ |d| d.dependant? && !d.spouse? }.length > 0
  end
end
