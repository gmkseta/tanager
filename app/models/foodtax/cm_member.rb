module Foodtax
  class CmMember < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :member_cd
    after_initialize :default_values

    has_one :cm_charge, foreign_key: :member_cd, primary_key: :member_cd
    has_many :va_ti_slips, foreign_key: :member_cd, primary_key: :member_cd
    has_many :va_card_slips, foreign_key: :member_cd, primary_key: :member_cd
    has_one :va_card_sum, foreign_key: :member_cd, primary_key: :member_cd
    has_one :va_head, foreign_key: :member_cd, primary_key: :member_cd
    has_one :va_elec_file_content, foreign_key: :member_cd, primary_key: :member_cd
    has_one :va_pseudo_sum, foreign_key: :member_cd, primary_key: :member_cd

    def self.find_or_initialize_by_declare_user(declare_user)
      cm_member = self.find_or_initialize_by(
        cmpy_cd: "00025",
        member_cd: declare_user.member_cd
      )
      phone_number = declare_user.user.phone_number
      business = declare_user.businesses.first
      cm_member.member_cd = declare_user.member_cd
      cm_member.biz_addr1 = business.address.split&.first
      cm_member.biz_addr2 = business.address.split&.second
      if phone_number
        cm_member.cp_no1 = phone_number[0..2]
        cm_member.cp_no2 = phone_number[3..6]
        cm_member.cp_no3 = phone_number[7..]
      end
      cm_member.boss_jumin_no = declare_user.residence_number
      cm_member.tax_type = FoodtaxHelper.foodtax_tax_type(business.taxation_type)
      cm_member.corp_yn = (business.taxation_type == "법인사업자") ? "Y" : "N"
      cm_member.biz_reg_no = business.registration_number
      cm_member.trade_nm = business.name
      cm_member.boss_nm = declare_user.name
      cm_member.open_dt = business.opened_at&.strftime("%Y%m%d") || Date.today.last_year.strftime("%Y%m%d")
      cm_member.closure_dt = business.closed_at || ""

      return if business.hometax_classification_code.blank?
      division = Snowdon::HometaxBusinessClassification.find_by(code: business.hometax_classification_code)&.division
      cm_member.uptae = division if division.present?
      cm_member.jongmok = business.hometax_classification_name
      cm_member.upjong_cd = business.hometax_classification_code
      cm_member
    end

    def business_id
      member_cd[1..]
    end

    private

    def default_values
      self.cmpy_cd ||= "00025"
      self.combiz_yn = "N" if combiz_yn.blank?
      self.use_yn = "Y" if use_yn.blank?
      self.taxaccept_yn = "N" if taxaccept_yn.blank?
    end
  end
end
