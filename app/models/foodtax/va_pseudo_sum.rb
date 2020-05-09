module Foodtax
  class VaPseudoSum < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq
    after_initialize :default_values, :default_dates, :default_user_id

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd

    private

    def default_values
      self.cmpy_cd ||= "00025"
      self.term_cd ||= "#{tax_declare_year}#{tax_declare_term}"
      self.declare_seq ||= "1"

      self.autocal_yn = "Y" if autocal_yn.blank?
      self.deduct_rate_cd = "5" if deduct_rate_cd.blank?
    end

    def default_dates
      self.REG_DATE ||= Time.now.strftime("%F %T")
      self.UPDT_DATE ||= Time.now.strftime("%F %T")
    end

    def default_user_id
      self.REG_USER_ID = "KCD" if self.REG_USER_ID.blank?
      self.UPDT_USER_ID = "KCD" if self.UPDT_USER_ID.blank?
    end
  end
end
