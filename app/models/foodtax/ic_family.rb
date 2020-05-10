module Foodtax
  class IcFamily < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq, :seq_no    

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd
    belongs_to :va_head, foreign_key: :member_cd, primary_key: :member_cd
  end
end
