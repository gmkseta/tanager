module Foodtax
  class VaHead < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq
    after_initialize :default_values

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd

    def declare_file_plain_text
      result = Foodtax::VaHead.execute_procedure :sp_va_head_file_gen_cashnote,
        cmpy_cd: cmpy_cd,
        member_cd: member_cd,
        term_cd: term_cd,
        declare_seq: declare_seq,
        form_cd: '',
        login_user_id: 'KCD',
        return_val: ''
      result.flatten.first["result"]
    end

    def declare_file
      Base64.encode64(declare_file_plain_text.encode("EUC-KR"))
    end

    def initialize_with_business(business)
      return if business.hometax_business.blank?
      self.biz_addr1 = business.hometax_business.address.split&.first
      self.biz_addr2 = business.hometax_business.address.split&.second
      self.cp_no = business.hometax_business.phone_number || business.owner.phone_number
      self.tax_type = foodtax_tax_type(business.hometax_business.taxation_type)
      self.upjong_cd = business.hometax_business.classification_code if business.hometax_business.classification_code
      self.closure_yn = "Y" if business.closed_at.present?
      self.closure_dt = business.closed_at.strftime("%Y%m%d") if business.closed_at.present?
      self.tax_office_cd = business.hometax_business.official_code

      tax_office = Foodtax::CmTaxOffice.find_by(tax_office_cd: business.hometax_business.official_code)
      self.tax_office_acct_cd = tax_office.acct_cd if tax_office.present?
      self.self_hometax_id = business.hometax_business.login

      self.term_str_dt = tax_declare_duration(business).first.strftime("%Y%m%d") if term_str_dt.blank?
      self.term_end_dt = tax_declare_duration(business).last.strftime("%Y%m%d") if term_end_dt.blank?
    end

    def declare_year
      term_cd[0..3]
    end

    def declare_term
      term_cd.last
    end

    private

    def default_values
      self.cmpy_cd ||= "00025"
      self.term_cd ||= "#{tax_declare_year}#{tax_declare_term}"
      self.declare_seq ||= "1"

      self.declare_due_dt = Date.today.strftime("%Y%m%d") if declare_due_dt.blank?

      self.close_yn = "Y" if close_yn.blank?
      self.file_make_yn = "N" if file_make_yn.blank?
      self.self_declare_yn = "Y" if self_declare_yn.blank?
    end
  end
end
