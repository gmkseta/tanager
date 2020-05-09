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

    def self.initialize_with_business(business) # rubocop:disable Metrics/MethodLength
      return if business.hometax_business.blank?
      phone_number = business.hometax_business.phone_number || business.owner.phone_number
      self.biz_addr1 = business.hometax_business.address.split&.first
      self.biz_addr2 = business.hometax_business.address.split&.second
      self.cp_no1 = phone_number[0..2]
      self.cp_no2 = phone_number[3..6]
      self.cp_no3 = phone_number[7..]
      self.boss_jumin_no = "#{business.hometax_business.owner_birthday[2..]}0000001" if business.hometax_business.owner_birthday
      self.tax_type = foodtax_tax_type(business.hometax_business)
      self.corp_yn = (business.hometax_business.taxation_type == "법인사업자") ? "Y" : "N"
      self.biz_reg_no = business.registration_number
      self.trade_nm = business.hometax_business.name || business.name
      self.boss_nm = business.hometax_business.owner_name || business.owner.name
      self.open_dt = business.hometax_business.opened_at || Date.today.last_year.strftime("%Y%m%d")
      self.closure_dt = business.closed_at.strftime("%Y%m%d") if business.closed_at.present?

      return if business.hometax_business.classification_code.blank?
      division = Snowdon::HometaxBusinessClassification.find_by(code: business.hometax_business.classification_code)&.division
      self.uptae = division if division.present?
      self.jongmok = business.hometax_business.classification_name
      self.upjong_cd = business.hometax_business.classification_code
    end

    def business_id
      member_cd[1..]
    end

    private

    def default_values
      self.cmpy_cd ||= "00025"
      self.boss_jumin_no = "0000000000001" if boss_jumin_no.blank?
      self.combiz_yn = "N" if combiz_yn.blank?
      self.use_yn = "Y" if use_yn.blank?
      self.taxaccept_yn = "N" if taxaccept_yn.blank?
      self.closure_dt = "" if closure_dt.blank?
    end
  end
end
