module Foodtax
  class VaInBillSum < Foodtax::ApplicationRecord
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq
    after_initialize :default_dates, :default_user_id, :default_values

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd

    NON_VALIDATABLE_ATTRIBUTES = %w(REG_DATE UPDT_DATE REG_USER_ID UPDT_USER_ID)
    validates_presence_of Foodtax::VaInBillSum.attribute_names.reject{ |attr| NON_VALIDATABLE_ATTRIBUTES.include?(attr)}

    def self.find_or_initialize_by_vat_form(form)
      self.find_or_initialize_by(
        cmpy_cd: "00025",
        member_cd: form.vat_return.member_cd,
        term_cd: form.vat_return.term_cd,
      )
    end

    def import_general_form!(form)      
      paper_invoices = form.vat_return.paper_invoices.purchases.tax_free
      hometax_invoices = form.vat_return.business.hometax_purchases_invoices.tax_free.where(written_at: form.date_range)

      self.biz_pti_vend_cnt = paper_invoices.group_by(&:trader_registration_number).length
      self.biz_pti_slip_cnt = paper_invoices.length
      self.biz_pti_supply_amt = paper_invoices.sum(&:price)

      self.biz_eti_vend_cnt = hometax_invoices.group_by(&:vendor_registration_number).length
      self.biz_eti_slip_cnt = hometax_invoices.length
      self.biz_eti_supply_amt = hometax_invoices.sum(&:price)
      save!
    end

    private

    def default_values
      self.cmpy_cd ||= "00025"
      self.declare_seq ||= "1"

      self.jumin_eti_vend_cnt = 0
      self.jumin_eti_slip_cnt = 0
      self.jumin_eti_supply_amt = 0

      self.jumin_pti_vend_cnt = 0
      self.jumin_pti_slip_cnt = 0
      self.jumin_pti_supply_amt = 0

      self.asset_pti_slip_cnt = 0
      self.asset_pti_supply_amt = 0
      self.asset_eti_slip_cnt = 0
      self.asset_eti_supply_amt = 0
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
