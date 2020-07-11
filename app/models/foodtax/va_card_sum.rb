module Foodtax
  class VaCardSum < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq
    after_initialize :default_values

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd

    def self.find_or_initialize_by_vat_form(form)
      self.find_or_initialize_by(
        cmpy_cd: "00025",
        member_cd: form.vat_return.member_cd,
        term_cd: form.vat_return.term_cd,
      )
    end

    def import_form!(form)
      begin
                
      end
      self.tax_in_card_vend_cnt
      self.tax_in_card_slip_cnt
      self.tax_in_card_supply_amt
      self.tax_in_card_vat_amt

      self.free_in_card_slip_cnt
      self.free_in_card_supply_amt

      self.tax_in_bizcard_vend_cnt
      self.tax_in_bizcard_slip_cnt
      self.tax_in_bizcard_supply_amt
      self.tax_in_bizcard_vat_amt

      self.free_in_bizcard_slip_cnt
      self.free_in_bizcard_supply_amt

      self.tax_in_cashslip_vend_cnt
      self.tax_in_cashslip_slip_cnt
      self.tax_in_cashslip_supply_amt
      self.tax_in_cashslip_vat_amt

      self.free_in_cashslip_slip_cnt
      self.free_in_cashslip_supply_amt

      self.tax_card_sale_amt
      self.tax_card_vat_amt
      
      self.tax_cashslip_sale_amt
      self.tax_cashslip_vat_amt
      self.zero_cashslip_sale_amt
      self.free_cashslip_sale_amt

      self.tax_elecpay_sale_amt
      self.tax_elecpay_vat_amt
      self.zero_elecpay_sale_amt
      self.free_elecpay_sale_amt

      
      self.tax_out_miss_supply_amt
      self.tax_out_miss_vat_amt
      self.zero_out_miss_supply_amt
      self.tax_in_miss_supply_amt
      self.tax_in_miss_vat_amt

      self.deduct_target_amt
      self.deduct_rate_nm
      self.deduct_amt
    end

    private

    def default_values
      self.cmpy_cd ||= "00025"
      self.declare_seq ||= "1"

      self.autocal_yn = "N" if autocal_yn.blank?
      self.scrap_use_yn = "Y" if scrap_use_yn.blank?

      self.card_asset_slip_cnt = 0
      self.card_asset_supply_amt = 0
      self.card_asset_vat_amt = 0
      self.bizcard_asset_slip_cnt = 0
      self.bizcard_asset_supply_amt = 0
      self.bizcard_asset_vat_amt = 0
      self.cashslip_asset_slip_cnt = 0
      self.cashslip_asset_supply_amt = 0
      self.cashslip_asset_vat_amt = 0

      self.zero_card_sale_amt = 0
      self.free_card_sale_amt = 0

      self.ti_dup_sale_amt = 0
      self.bill_dup_sale_amt = 0
      self.card_service_amt = 0
      self.cashslip_service_amt = 0
    end
  end
end
