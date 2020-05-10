class DeductiblePerson < ApplicationRecord
  self.table_name = "deductible_persons"
  self.ignored_columns = ["basic_livelihood"]
  include PersonalDeduction

  belongs_to :declare_user
  belongs_to :classification

  validate :valid_residence_number?
  validates :residence_number, presence: true, format: { with: /\A\d{13}\z/ }
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
    default_deduction_amount + additional_deduction_amount
  end

  class << self
    def dependants_count
      select{ |d| d.dependant? && !d.spouse? }.length
    end

    def has_dependant?
      dependants_count > 0
    end

    def dependant_children_count
      select{ |d| d.dependant_children? }.length
    end

    def has_dependant_children?
      dependant_children_count > 0
    end

    def has_spouse?
      select{ |d| d.classification_id == 1 }.length > 0
    end

    def elder_count
      select{ |d| d.elder? == true }.length
    end

    def disabled_count
      select{ |d| d.disabled == true }.length
    end

    def single_parent_count
      select{ |d| d.single_parent == true }.length
    end

    def woman_deduction_count
      select{ |d| d.woman_deduction == true }.length
    end
  end
end
