class DeductiblePerson < ApplicationRecord
  self.table_name = "deductible_persons"
  extend AttrEncrypted
  include PersonalDeduction

  belongs_to :declare_user
  belongs_to :classification

  validate :valid_residence_number?
  validates :residence_number, presence: true, format: { with: /\A\d{13}\z/ }
  validates :classification_id, presence: true, inclusion: { in: Classification.relations.ids, message: :invalid_type }
  validates :name, presence: true

  attr_encrypted :residence_number,
                 key: :encryption_key,
                 encode: true,
                 encode_iv: true,
                 encode_salt: true

  def encryption_key
    Rails.application.credentials.attr_encrypted[:encryption_key]
  end

  def spouse?
    classification_id == 1
  end

  def basic_yn?
    classification_id == 8
  end

  def single_parent?
    single_parent
  end

  def woman_deduction?
    woman_deduction
  end

  def dependant_children?
    20 >= age && [2, 8].any?(classification_id)
  end

  def deduction_amount
    default_deduction_amount + additional_deduction_amount
  end

  def relation_name
    classification.name
  end

  class << self
    def dependants_count
      select{ |d| (d.dependant? && !d.spouse?) }.length
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
      select{ |d| d.single_parent? }.length
    end

    def woman_deduction_count
      select{ |d| d.woman_deduction? }.length
    end
  end
end
