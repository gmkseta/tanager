module Foodtax
  class CmCharge < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :member_cd, :cmpy_cd, :user_id
    after_initialize :default_values

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd

    private

    def default_values
      self.cmpy_cd ||= "00025"
      self.user_id ||= "KCD"

      self.charge_yn = "Y" if charge_yn.blank?
      self.select_yn = "N" if select_yn.blank?
      self.update_yn = "N" if update_yn.blank?
    end
  end
end
