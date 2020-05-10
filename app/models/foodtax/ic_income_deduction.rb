module Foodtax
  class IcIncomeDeduction < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd, :term_cd, :declare_seq, :gonggam_cd
    self.table_name = "ic_1060"
    after_initialize :default_user_id

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd
    belongs_to :va_head, foreign_key: :member_cd, primary_key: :member_cd

    private

    def default_user_id
    end
  end
end
