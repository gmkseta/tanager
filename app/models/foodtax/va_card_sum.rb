module Foodtax
  class VaCardSum < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq
    after_initialize :default_values

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd

    private

    def default_values
      self.cmpy_cd ||= "00025"
      self.term_cd ||= "#{tax_declare_year}#{tax_declare_term}"
      self.declare_seq ||= "1"

      self.autocal_yn = "Y" if autocal_yn.blank?
      self.scrap_use_yn = "Y" if scrap_use_yn.blank?
    end
  end
end
