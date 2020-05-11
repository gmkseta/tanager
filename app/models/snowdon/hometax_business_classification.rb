class Snowdon::HometaxBusinessClassification < Snowdon::ApplicationRecord
  belongs_to :kic, class_name: "BusinessClassification", primary_key: :code, foreign_key: :kic_code
  belongs_to :ksic, class_name: "StandardIndustrialClassification", primary_key: :code, foreign_key: :kic_code

  validates :code, presence: true, uniqueness: true
  validates :division, presence: true
  validates :section, presence: true
  validates :segment, presence: true
  validates :name, presence: true
  validates :category, presence: true
  validates :item, presence: true
end
