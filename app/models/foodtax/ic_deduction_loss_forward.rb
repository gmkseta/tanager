module Foodtax
  class IcDeductionLossForward < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd, :term_cd, :declare_seq, :income_type, :seq_no
    self.table_name = "ic_1050"    
  end
end
