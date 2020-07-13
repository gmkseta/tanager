module Foodtax
  class VaNoDeductiblePurchase < Foodtax::ApplicationRecord    
    self.table_name = "VA_V153_M"
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq
    after_initialize :default_dates, :default_user_id, :default_values

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd

    NON_VALIDATABLE_ATTRIBUTES = %w(nodeduct_cal_type REG_DATE UPDT_DATE REG_USER_ID UPDT_USER_ID)
    validates_presence_of Foodtax::VaNoDeductiblePurchase.attribute_names.reject{ |attr| NON_VALIDATABLE_ATTRIBUTES.include?(attr)}

    def self.find_or_initialize_by_vat_form(form)
      self.find_or_initialize_by(
        cmpy_cd: "00025",
        member_cd: form.vat_return.member_cd,
        term_cd: form.vat_return.term_cd,
      )
    end

    def self.import_general_form!(form)
      no_deductions = form.vat_return.deductible_purchases.purchases_invoices.no_deductions
      vendor_registration_numbers = no_deductions.index_by(&:vendor_registration_number)
      invoices = begin
        form.vat_return.business.hometax_purchases_invoices
          .where(written_at: form.date_range)
          .where(vendor_registration_number: vendor_registration_numbers.keys)
      end
      va_no_deduction = Foodtax::VaNoDeductiblePurchase.find_or_initialize_by_vat_form(form)
      va_no_deduction.C0010 = invoices.count
      va_no_deduction.C0020 = invoices.sum(:price)
      va_no_deduction.C0030 = invoices.sum(:tax)
      va_no_deduction.save!
    end

    private

    def default_values
      self.cmpy_cd ||= "00025"
      self.declare_seq ||= "1"
      self.C0040 = 0
      self.C0050 = 0
      self.C0060 = 0
      self.C0070 = 0
      self.C0080 = 0
      self.C0090 = 0
      self.C0100 = 0
      self.nodeduct_cal_type = ""
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
