module Foodtax
  class IcTaxPenalty < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd, :term_cd, :declare_seq, :addtax_cd
    self.table_name = "ic_1090"

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd
  end
end