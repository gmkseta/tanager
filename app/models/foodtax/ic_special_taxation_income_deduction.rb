module Foodtax
  class IcSpecialTaxationIncomeDeduction < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd, :term_cd, :declare_seq, :deduct_cd
    self.table_name = "ic_1061"

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd
    belongs_to :va_head, foreign_key: :member_cd, primary_key: :member_cd
  end
end