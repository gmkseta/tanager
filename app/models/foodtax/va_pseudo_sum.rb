module Foodtax
  class VaPseudoSum < Foodtax::ApplicationRecord
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq
    after_initialize :default_values, :default_dates, :default_user_id

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd

    def self.find_or_initialize_by_vat_form(form)
      self.find_or_initialize_by(
        cmpy_cd: "00025",
        member_cd: form.vat_return.member_cd,
        term_cd: form.vat_return.term_cd
      )
    end

    def self.import_general_form!(form)
      s = self.find_or_initialize_by_vat_form(form)

      form.etc_summaries["deemed_purchases_summary"].collect { |k, v| s[k] = v }

      s.C0010 = 0
      s.C0020 = form.value_price("32")
      s.C0030 = form.value_price("32")
      s.C0061 = 0
      s.C0062 = form.value_vat("43")
      s.C0060 = form.value_vat("43")
      s.C0070 = form.value_vat("43")
      s.C0080 = s.deduct_rate_nm[0]
      s.C0090 = form.value_vat("43")
      s.C0100 = 0
      s.C0110 = 0
      s.C0120 = 0 
      s.C0130 = form.value_vat("43")

      s.save!
    end

    private

    def default_values
      self.cmpy_cd ||= "00025"
      self.declare_seq ||= "1"

      self.autocal_yn = "Y" if autocal_yn.blank?
      self.deduct_biz_type = ""

      
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
