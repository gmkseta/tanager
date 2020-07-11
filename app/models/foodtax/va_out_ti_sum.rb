module Foodtax
  class VaOutTiSum < Foodtax::ApplicationRecord
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq
    after_initialize :default_dates, :default_user_id, :default_values

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd

    NON_VALIDATABLE_ATTRIBUTES = %w(REG_DATE UPDT_DATE REG_USER_ID UPDT_USER_ID)
    validates_presence_of Foodtax::VaOutTiSum.attribute_names.reject{ |attr| NON_VALIDATABLE_ATTRIBUTES.include?(attr)}

    def self.find_or_initialize_by_vat_form(form)
      self.find_or_initialize_by(
        cmpy_cd: "00025",
        member_cd: form.vat_return.member_cd,
        term_cd: form.vat_return.term_cd,
      )
    end

    def import_general_form!(form)

      paper_invoices = form.vat_return.paper_invoices.sales.taxation
      hometax_invoices = form.vat_return.business.hometax_sales_invoices.taxation.where(written_at: form.date_range)

      self.biz_pti_vend_cnt = paper_invoices.group_by(&:trader_registration_number).length
      self.biz_pti_slip_cnt = paper_invoices.length
      self.biz_pti_supply_amt = paper_invoices.sum(&:price)
      self.biz_pti_vat_amt = paper_invoices.sum(&:vat)

      # TODO: 주민번호/사업자 구분 기준 체크
      issued_by_business = hometax_invoices.select{ |h| h.customer_registration_number.length <= 10 }
      issued_by_owner = hometax_invoices.select{ |h| h.customer_registration_number.length > 10 }

      self.biz_eti_vend_cnt = issued_by_business.group_by(&:customer_registration_number).length
      self.biz_eti_slip_cnt = issued_by_business.length
      self.biz_eti_supply_amt = issued_by_business.sum(&:price)
      self.biz_eti_vat_amt = issued_by_business.sum(&:tax)

      self.jumin_eti_vend_cnt = issued_by_owner.group_by(&:customer_registration_number).length
      self.jumin_eti_slip_cnt = issued_by_owner.length
      self.jumin_eti_supply_amt = issued_by_owner.sum(&:price)
      self.jumin_eti_vat_amt = issued_by_owner.sum(&:tax)
      save!
    end

    private

    def default_values
      self.cmpy_cd ||= "00025"
      self.declare_seq ||= "1"

      self.jumin_pti_vend_cnt = 0
      self.jumin_pti_slip_cnt = 0
      self.jumin_pti_supply_amt = 0
      self.jumin_pti_vat_amt = 0

      self.zero_supply_amt = 0
      self.tax_miss_supply_amt = 0
      self.tax_miss_vat_amt = 0
      self.zero_miss_supply_amt = 0
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
