module Foodtax
  class VaCovid19DeductionSummary < Foodtax::ApplicationRecord
    self.table_name = "va_smbiz_gam_m"
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq
    after_initialize :default_dates, :default_user_id, :default_values

    belongs_to :va_head, foreign_key: :member_cd, primary_key: :member_cd

    NON_VALIDATABLE_ATTRIBUTES = %w(REG_DATE UPDT_DATE REG_USER_ID UPDT_USER_ID)
    validates_presence_of Foodtax::VaCovid19DeductionSummary.attribute_names.reject{ |attr| NON_VALIDATABLE_ATTRIBUTES.include?(attr)}

    def self.find_or_initialize_by_vat_form(form)
      self.find_or_initialize_by(
        cmpy_cd: "00025",
        member_cd: form.vat_return.member_cd,
        term_cd: form.vat_return.term_cd,
      )
    end

    def self.import_general_form!(form)
      return create_empty_table(form) if form.vat_return.exclude_covid19_deduction?
      s = self.find_or_initialize_by_vat_form(form)

      form.summaries["covid19_deduction_summary"].collect{ |k, v| s[k] = v }

      s.paytax_fix_amt = form.value_vat("100")
      s.gong_fix_amt = form.value_vat("20")
      s.gam_target_amt = [s.paytax_fix_amt - s.gong_fix_amt, 0].max
      s.paytax_amt = s.gam_target_amt
      s.save!
    end

    def create_empty_table(form)
      s = self.find_or_initialize_by_vat_form(form)
      form.summaries["covid19_deduction_summary"].collect{ |k, v| s[k] = 0 }
      s.paytax_fix_amt = 0
      s.gong_fix_amt = 0
      s.gam_target_amt = 0
      s.paytax_amt = 0
      s.save!
    end

    private

    def default_values
      self.cmpy_cd ||= "00025"
      self.declare_seq ||= "1"
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
