class Snowdon::HometaxBusinessClassification < Snowdon::ApplicationRecord
  VAT_RETURN_UNSUPPORTED_CODES = %w(
    701101 701102 701103 701104 701301 701201 701202
    701203 701204 701300 701501 701502 921404 701400
    701503 701504 451102 451103 703011 703012 703014
    703016 703021 703022 703023 703024 703015 703017
    505001 505002 851113 851114 851102 851103 851101
    851201 851202 851203 851204 851205 851206 851207
    851209 851219 851211 851212 851208 851905 851909
    863000 851911 851902 851903 851904 851908 851901
    851906 851907 930301 930901 940915 552201 552202
    552203 552204 552206 552207
  ).freeze

  validates :code, presence: true, uniqueness: true
  validates :division, presence: true
  validates :section, presence: true
  validates :segment, presence: true
  validates :name, presence: true
  validates :category, presence: true

  scope :deemed_purchasable, -> { where(deemed_purchasable: true) }

  class << self
    def deemed_purchasable_codes
      deemed_purchasable.pluck(:code)
    end

    def supports_vat_return?(code)
      VAT_RETURN_UNSUPPORTED_CODES.exclude?(code) && exists?(code: code)
    end
  end
end
