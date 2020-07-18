module Foodtax
  class VaCardSum < Foodtax::ApplicationRecord
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

    def self.import_general_form!(form)
      c = self.find_or_initialize_by_vat_form(form)

      form.summaries["card_and_cash_summary"].collect { |k, v| c[k] = v }

      c.deduct_target_amt = form.value_price("19")
      c.deduct_rate_nm = form.value_vat("19") > 0 ? "1.3" : ""
      c.deduct_amt = form.value_vat("19")

      c.save!
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

      self.zero_cashslip_sale_amt = 0
      self.free_cashslip_sale_amt = 0

      self.ti_dup_sale_amt = 0
      self.bill_dup_sale_amt = 0
      self.card_service_amt = 0
      self.cashslip_service_amt = 0
    end
  end
end
