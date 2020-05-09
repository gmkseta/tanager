module Foodtax
  class VaCardSlip < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq
    after_initialize :default_values

    def with_card_purchase(card_purchase) # rubocop:disable Metrics/MethodLength
      self.slip_type = 2
      self.card_type = 8
      self.slip_cnt = 1

      self.card_no = card_purchase.card_number
      self.vend_biz_reg_no = card_purchase.vendor_registration_number
      self.vend_trade_nm = card_purchase.vendor_business_name.truncate(50)

      self.supply_amt = card_purchase.price
      self.vat_amt = card_purchase.vat
      self.total_amt = card_purchase.amount

      if card_purchase.hometax_purchase_tag
        self.asset_yn = card_purchase.hometax_purchase_tag.fixed_asset ? "Y" : "N"
        self.pseudo_buy_yn = card_purchase.hometax_purchase_tag.deemed_input_tax ? "Y" : "N"
        self.deduct_yn = (card_purchase.hometax_purchase_tag.deductible || pseudo_buy_yn == "Y") ? "Y" : "N"
      else
        self.pseudo_buy_yn = if %w(금융 자동차).any? { |n| card_purchase.vendor_business_category&.include? n }
                               "N"
                             else
                               (card_purchase.vat == 0) ? "Y" : "N"
                             end
        self.deduct_yn = (card_purchase.deductible || pseudo_buy_yn == "Y") ? "Y" : "N"
      end
      self.asset_type = 0
      self.approve_dt = card_purchase.purchased_at.strftime("%Y%m%d")
    end

    def with_purchases_cash_receipt(purchases_cash_receipt, section) # rubocop:disable Metrics/MethodLength
      self.slip_type = 3
      self.slip_cnt = 1

      self.approve_no = purchases_cash_receipt.authorization_number
      self.vend_biz_reg_no = purchases_cash_receipt.vendor_registration_number
      self.vend_trade_nm = purchases_cash_receipt.vendor_business_name.truncate(50)

      self.supply_amt = purchases_cash_receipt.price
      self.vat_amt = purchases_cash_receipt.vat
      self.total_amt = purchases_cash_receipt.amount

      if purchases_cash_receipt.hometax_purchase_tag
        self.asset_yn = purchases_cash_receipt.hometax_purchase_tag.fixed_asset ? "Y" : "N"
        self.pseudo_buy_yn = purchases_cash_receipt.hometax_purchase_tag.deemed_input_tax ? "Y" : "N"
        self.deduct_yn = (purchases_cash_receipt.hometax_purchase_tag.deductible || pseudo_buy_yn == "Y") ? "Y" : "N"
      else
        self.pseudo_buy_yn = if %w(금융 자동차).any? { |n| section&.include? n }
                               "N"
                             else
                               (purchases_cash_receipt.vat == 0) ? "Y" : "N"
                             end
        self.deduct_yn = (purchases_cash_receipt.tax_deductible || pseudo_buy_yn == "Y") ? "Y" : "N"
      end
      self.asset_type = 0
      self.approve_dt = purchases_cash_receipt.purchased_at.strftime("%Y%m%d")
    end

    private

    def default_values
      self.cmpy_cd ||= "00025"
      self.term_cd ||= "#{tax_declare_year}#{tax_declare_term}"
      self.declare_seq ||= "1"
    end
  end
end
