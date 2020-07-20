module Foodtax
  class VaHead < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq
    after_initialize :default_values

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd

    DEFAULT_EMPTY_STRING = %w(return_bank return_branch return_acct_no biz_addr2 biz_addr3 biz_addr4 biz_tel_no cp_no home_tel_no in_vat_autocal_yn closure_dt closure_reason_type closure_reason_type_nm tax_office_acct_cd)
    NON_VALIDATABLE_ATTRIBUTES = %w(reg_date updt_date reg_user_id updt_user_id) + DEFAULT_EMPTY_STRING
    validates_presence_of Foodtax::VaHead.attribute_names.reject{ |attr| NON_VALIDATABLE_ATTRIBUTES.include?(attr) }

    def declare_file_plain_text
      result = Foodtax::VaHead.execute_procedure :sp_va_head_file_gen_cashnote,
        cmpy_cd: cmpy_cd,
        member_cd: member_cd,
        term_cd: term_cd,
        declare_seq: declare_seq,
        form_cd: "",
        login_user_id: "KCD",
        return_val: ""
      result.flatten.first["result"]
    end

    def declare_file
      Base64.encode64(declare_file_plain_text.encode("EUC-KR"))
    end

    def self.find_or_initialize_by_vat_return(vat_return)
      self.find_or_initialize_by(
        cmpy_cd: "00025",
        member_cd: vat_return.member_cd,
        term_cd: vat_return.term_cd,
      )
    end

    def import_general_form(form)
      mappings = YAML.load_file(Rails.root.join("app/libs/vat/mapping_columns.yml"))
      mappings["va_head"].each do |k, v|
        price_field_name = v["price"]
        vat_field_name = v["vat"]
        self[price_field_name] = form.value_price(k) if price_field_name.present?
        self[vat_field_name] = form.value_vat(k) if vat_field_name.present?
      end

      self.term_str_dt = form.period_start_date
      self.term_end_dt = form.period_end_date

      self.return_yn = self.real_paytax_amt < 0 ? "Y" : "N"

      self.declare_due_dt = vat_return_due_date(form.period_end_date.to_date).strftime("%Y%m%d")

      form.summaries["header"].each do |k, v|
        self[k] = v
      end

      self.yieldtax_amt = self.v_v010 - form.value_vat("19") - self.elec_declare_amt
      self.real_paytax_amt = form.value_vat("27")
      self.paytax_amt = form.value_vat("27")

      set_tax_payer(form)

      save!
    end

    private

    def set_tax_payer(form)
      business_address = form["tax_payer"]&.fetch("business_address")
      self.biz_addr4 = business_address.split[3..]&.join(" ")
      business_address.split.each_with_index do |address, index|
        break if index + 1 >= 4
        self["biz_addr#{index + 1}"] = address
      end

      self.return_bank = form.return_bank_code
      self.return_acct_no = form["tax_payer"]&.fetch("refund_bank_account") || ""

      h = form.vat_return.business.hometax_business
      tax_office = Foodtax::CmTaxOffice.find_by(tax_office_cd: h.official_code)
      self.tax_office_cd = h.official_code
      self.tax_office_acct_cd = tax_office.acct_cd if tax_office.present?
      self.self_hometax_id = h.login
      self.upjong_cd = form.primary_classification["code"]

      self.closure_dt = form["tax_payer"]&.fetch("business_closed_at")&.to_date&.strftime("%Y%m%d") || ""
      self.closure_yn = self.closure_dt.blank? ? "N" : "Y"
      self.closure_reason_type = ""
      self.closure_reason_type_nm = ""

      self.biz_tel_no = form["tax_payer"]&.fetch("business_phone_number") || ""
      self.cp_no = form["tax_payer"]&.fetch("cellphone_number") || ""
      self.home_tel_no = form["tax_payer"]&.fetch("phone_number") || ""

      if form.vat_return.exclude_covid19_deduction?
        self.smbiz_vat_gam_amt = 0
      else
        self.smbiz_vat_gam_amt = form.summaries.dig("covid19_deduction_summary", "gamtax_amt").to_i
      end
    end

    def default_values
      self.cmpy_cd ||= "00025"
      self.declare_seq ||= "1"
      self.declare_type = "1"

      self.easyvat_exempt_yn = "N"
      self.tax_type = "1"
      self.self_declare_yn = "Y"

      self.declare_dt = Date.current.strftime("%Y%m%d") if declare_dt.blank?

      DEFAULT_EMPTY_STRING.each do |column|
        self[column] = "" if self[column].blank?
      end

      self.close_yn = "Y"
      self.close_dt = Date.current.strftime("%Y%m%d")
      self.close_user_id = "KCD"

      self.file_make_yn = "N"
      self.file_make_dt = Date.current.strftime("%Y%m%d")
      self.file_make_cnt = 0
      self.file_make_user_id = "KCD"

      self.free_cash_sale_amt = 0
      self.zero_cash_sale_amt = 0

      self.cta_cmpy_cd = "40000"
    end
  end
end
