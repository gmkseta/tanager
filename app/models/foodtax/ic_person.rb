module Foodtax
  class IcPerson < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq
    self.table_name = "VA_ELEC_FILE_CONTENTS"
    after_initialize :default_user_id

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd
    belongs_to :va_head, foreign_key: :member_cd, primary_key: :member_cd

    private

    def default_user_id
    end
  end
end
