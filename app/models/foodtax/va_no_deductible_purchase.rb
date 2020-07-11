module Foodtax
  class VaNoDeductiblePurchase < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.table_name = "VA_V153_D1"
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq, :nodeduct_type
    after_initialize :default_dates, :default_user_id, :default_values

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd

    NON_VALIDATABLE_ATTRIBUTES = %w(REG_DATE UPDT_DATE REG_USER_ID UPDT_USER_ID)
    validates_presence_of Foodtax::VaNoDeductiblePurchase.attribute_names.reject{ |attr| NON_VALIDATABLE_ATTRIBUTES.include?(attr)}

    def self.find_or_initialize_by_vat_form(form)
      self.find_or_initialize_by(
        cmpy_cd: "00025",
        member_cd: form.vat_return.member_cd,
        term_cd: form.vat_return.term_cd,
      )
    end

    def self.import_form!(form)
      period = vat_return_period_datetime_range(
        taxation_type: form.vat_return.business.taxation_type,
        year: form.vat_return.year,
        period: form.vat_return.period,
      )
      no_deductions = Snowdon::VatReturnDeductiblePurchase.no_deductions.where(vat_return_id: form.vat_return_id)
      vendor_registration_numbers = no_deductions.index_by(&:vendor_registration_number)
      invoices = begin
        Snowdon::HometaxPurchasesInvoice.where(written_at: period)
          .where(vendor_registration_number: vendor_registration_numbers.keys)
          .group(:vendor_registration_number)
          .pluck(Arel.sql(<<~QUERY))
            vendor_registration_number,
            COUNT(*),
            SUM(price),
            SUM(tax)
          QUERY
      end
      results = []
      invoices.each do |i|
        va_no_deduction = Foodtax::VaNoDeductiblePurchase.find_or_initialize_by_vat_form(form)
        va_no_deduction.nodeduct_type = vendor_registration_numbers[i[0]].nodeduct_reason_id - 1
        va_no_deduction.C0010 = i[1]
        va_no_deduction.C0020 = invoices[2] || 0
        va_no_deduction.C0030 = invoices[3] || 0
        results << va_no_deduction
      end
      Foodtax::VaNoDeductiblePurchase.import!(results)
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
