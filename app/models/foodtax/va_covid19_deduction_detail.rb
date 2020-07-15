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
        seq_no: i
      )
    end

    def self.import_general_form!(form)      
      form.summaries["covid19_deduction_details"].each_with_index do |s, i|
        d = self.find_or_initialize_by_vat_form(form, i)
        s.collect { |k, v| d[k] = v }
        puts d.to_json
        d.save!
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
