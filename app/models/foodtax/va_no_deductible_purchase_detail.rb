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
      vendor_registration_numbers = form.vat_return.deductible_purchases.purchases_invoices.no_deductions.index_by(&:vendor_registration_number)
      invoices = begin
        form.vat_return.business.hometax_purchases_invoices
          .joins(:deductible_purchase)
          .where(written_at: form.date_range)
          .where.not(vat_return_deductible_purchases: { nodeduct_reason_id: nil })
          .group(:nodeduct_reason_id)
          .pluck(Arel.sql(<<~QUERY))
            MAX(hometax_purchases_invoices.vendor_registration_number),
            COUNT(*),
            SUM(price),
            SUM(tax)
          QUERY
      end

      no_deductible_purchases_details = invoices.map do |vendor_registration_number, count, price, vat|
        va_no_deduction_detail = Foodtax::VaNoDeductiblePurchaseDetail.find_or_initialize_by_vat_form(form)
        va_no_deduction_detail.nodeduct_type = vendor_registration_numbers[vendor_registration_number].nodeduct_reason_id - 1
        va_no_deduction_detail.C0010 = count
        va_no_deduction_detail.C0020 = price
        va_no_deduction_detail.C0030 = vat
        no_deductible_purchases_details
      end
      self.import!(no_deductible_purchases_details)
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
