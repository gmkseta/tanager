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
    has_one :va_penalty, foreign_key: :member_cd, primary_key: :member_cd
    has_one :va_pseudo_sum, foreign_key: :member_cd, primary_key: :member_cd

    DEFAULT_EMPTY_STRING = %w(tax_type_change_dt biz_dong_cd open_dt closure_dt bank_cd acct_no email biz_addr1 biz_addr2 biz_addr3 biz_addr4 cp_no1 cp_no2 cp_no3 biz_tel_no1 biz_tel_no2 biz_tel_no3)
    NON_VALIDATABLE_ATTRIBUTES = %w(reg_date updt_date reg_user_id updt_user_id) + DEFAULT_EMPTY_STRING
    validates_presence_of Foodtax::CmMember.attribute_names.reject{ |attr| NON_VALIDATABLE_ATTRIBUTES.include?(attr) }

    def self.find_or_initialize_by_vat_return(vat_return)
      self.find_or_initialize_by(
        cmpy_cd: "00025",
        member_cd: vat_return.member_cd
      )
    end

    def import_general_form!(form)
      self.tax_type = "1"
      self.biz_reg_no = form["tax_payer"]&.fetch("registration_number") || ""
      self.trade_nm = form["tax_payer"]&.fetch("business_name") || ""
      self.boss_nm = form["tax_payer"]&.fetch("owner_name")
      date = form["tax_payer"]&.fetch("owner_birthday").to_date
      self.boss_jumin_no = "#{date.strftime("%y%m%d")}0000001"
      self.email = form["tax_payer"]&.fetch("email") || ""

      business_address = form["tax_payer"]&.fetch("business_address")
      self.biz_addr4 = business_address.split[3..]&.join(" ")
      business_address.split.each_with_index do |address, index|
        break if index + 1 >= 4
        self["biz_addr#{index + 1}"] = address
      end

      h = form.vat_return.business.hometax_business
      self.corp_yn = (h.taxation_type == "법인사업자") ? "Y" : "N"
      tax_office = Foodtax::CmTaxOffice.find_by(tax_office_cd: h.official_code)
      self.alloc_tax_office_cd = h.official_code
      self.alloc_tax_office_nm = tax_office.tax_office_nm

      self.uptae = form.primary_classification["name"]
      self.jongmok = form.primary_classification["item"]
      self.upjong_cd = form.primary_classification["code"]

      self.open_dt = form.vat_return.business.opened_at&.strftime("%Y%m%d") || form.vat_return.business.card_merchant_signed_up_at&.strftime("%Y%m%d") || ""
      self.closure_dt = form["tax_payer"]&.fetch("business_closed_at")&.strftime("%Y%m%d") || ""

      cellphone_number = form["tax_payer"]&.fetch("cellphone_number")
      if cellphone_number
        self.cp_no1 = cellphone_number[0..2]
        self.cp_no2 = cellphone_number[3..6]
        self.cp_no3 = cellphone_number[7..]
      end
      save!
    end

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
      begin
        business.name.encode("EUC-KR")
        cm_member.trade_nm = business.name
      rescue Encoding::UndefinedConversionError => e
        cm_member.trade_nm = declare_user.name
      end
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
      self.taxaccept_yn = "N" if taxaccept_yn.blank?

      self.bangi_yn = "X" if bangi_yn.blank?
      self.biz_yn = "Y" if biz_yn.blank?
      self.use_yn = "Y" if use_yn.blank?

      DEFAULT_EMPTY_STRING.each do |column|
        self[column] = "" if self[column].blank?
      end
    end
  end
end
