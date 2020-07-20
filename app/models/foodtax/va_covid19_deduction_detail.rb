module Foodtax
  class VaCovid19DeductionDetail < Foodtax::ApplicationRecord
    self.table_name = "va_smbiz_gam_d"
    
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq, :seq_no
    after_initialize :default_dates, :default_user_id, :default_values

    belongs_to :va_head, foreign_key: :member_cd, primary_key: :member_cd

    NON_VALIDATABLE_ATTRIBUTES = %w(REG_DATE UPDT_DATE REG_USER_ID UPDT_USER_ID)
    validates_presence_of Foodtax::VaCovid19DeductionDetail.attribute_names.reject{ |attr| NON_VALIDATABLE_ATTRIBUTES.include?(attr)}

    def self.find_or_initialize_by_vat_form(form, i)
      self.find_or_initialize_by(
        cmpy_cd: "00025",
        member_cd: form.vat_return.member_cd,
        term_cd: form.vat_return.term_cd,
        seq_no: i+1
      )
    end

    def self.import_general_form!(form)
      return if form.vat_return.exclude_covid19_deduction?

      summary = Foodtax::VaCovid19DeductionSummary.find_or_initialize_by(
        cmpy_cd: "00025",
        member_cd: form.vat_return.member_cd,
        term_cd: form.vat_return.term_cd,
      )

      form.summaries["covid19_deduction_details"].each_with_index do |summary, index|
        detail = self.find_or_initialize_by_vat_form(form, index)
        summary.collect { |k, v| detail[k] = v }        
        detail.save!
      end

      easyvat_sum = form.summaries["covid19_deduction_details"].sum { |s| s["easyvat_amt"] }
      if easyvat_sum != summary.difftax_amt
        detail = self.find_or_initialize_by_vat_form(form, 0)
        detail.easyvat_amt = detail.easyvat_amt + summary.difftax_amt - easyvat_sum
        detail.save!
      end
    end

    private

    def default_values
      self.cmpy_cd ||= "00025"
      self.declare_seq ||= "1"
      self.upjong_cd ||= ""
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
