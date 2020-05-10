module Foodtax
  class IcBusinessIncomeWht < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd, :term_cd, :declare_seq, :seq_no
    self.table_name = "ic_1022"    
  end
end
