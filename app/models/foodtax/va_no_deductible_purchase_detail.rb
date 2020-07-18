module Foodtax
  class VaNoDeductiblePurchaseDetail < Foodtax::ApplicationRecord    
    self.table_name = "VA_V153_D1"
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq, :nodeduct_type
    after_initialize :default_dates, :default_user_id, :default_values

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd

    NON_VALIDATABLE_ATTRIBUTES = %w(REG_DATE UPDT_DATE REG_USER_ID UPDT_USER_ID)
    validates_presence_of Foodtax::VaNoDeductiblePurchaseDetail.attribute_names.reject{ |attr| NON_VALIDATABLE_ATTRIBUTES.include?(attr)}

    def self.find_or_initialize_by_vat_form(form)
      self.find_or_initialize_by(
        cmpy_cd: "00025",
        member_cd: form.vat_return.member_cd,
        term_cd: form.vat_return.term_cd,
      )
    end

    def self.import_general_form!(form)
      deductible_purchases = form.vat_return.deductible_purchases
      vendor_registration_numbers = deductible_purchases.purchases_invoices.no_deductions.index_by(&:vendor_registration_number)
      return if vendor_registration_numbers.blank?

      invoices = begin
        form.vat_return.business.hometax_purchases_invoices
          .where(vendor_registration_number: vendor_registration_numbers.keys)
          .where(written_at: form.date_range)
          .where.not(tax: 0)
          .group(:vendor_registration_number)
          .pluck(Arel.sql(<<~QUERY))
            MAX(vendor_registration_number),
            COUNT(*),
            SUM(price),
            SUM(tax)
          QUERY
      end

      no_deductible_purchases = begin
        index = 0
        invoices.map do |vendor_registration_number, count, price, vat|
          next if vendor_registration_numbers[vendor_registration_number].nil?
          index = index + 1
          va_no_deduction_detail = Foodtax::VaNoDeductiblePurchaseDetail.find_or_initialize_by_vat_form(form)
          va_no_deduction_detail.declare_seq = index
          va_no_deduction_detail.nodeduct_type = vendor_registration_numbers[vendor_registration_number].code
          va_no_deduction_detail.C0010 = count
          va_no_deduction_detail.C0020 = price
          va_no_deduction_detail.C0030 = vat

          va_no_deduction_detail
        end
      end

      return if no_deductible_purchases.compact.blank?

      self.import!(no_deductible_purchases.compact)
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
