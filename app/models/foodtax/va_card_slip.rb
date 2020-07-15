module Foodtax
  class VaCardSlip < Foodtax::ApplicationRecord
    enum slip_type: {
      personal_card: 1,
      hometax_card: 2,
      cash_receipt: 3,
    }
    include FoodtaxHelper
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq, :slip_seq, :slip_type
    after_initialize :default_values

    VALIDATABLE_ATTRIBUTES = %w(vend_biz_reg_no vend_trade_nm slip_cnt supply_amt vat_amt total_amt deduct_yn pseudo_buy_yn approve_dt)
    validates_presence_of Foodtax::VaCardSlip.attribute_names.select{ |attr| VALIDATABLE_ATTRIBUTES.include?(attr)}

    def self.find_or_initialize_by_vat_form(form)
      self.find_or_initialize_by(
        cmpy_cd: "00025",
        member_cd: form.vat_return.member_cd,
        term_cd: form.vat_return.term_cd,
      )
    end

    def self.import_vat_return!(vat_return)
      sales = self.convert_card_slips(vat_return, vat_return.grouped_personal_cards, :personal_card)
      sales += self.convert_card_slips(vat_return, vat_return.grouped_hometax_card_purchases, :hometax_card)
      sales += self.convert_card_slips(vat_return, vat_return.grouped_purchases_cash_receipts, :cash_receipt)
      self.import! sales
    end

    def self.convert_card_slips(vat_return, purchases, type)
      index = 0      
      purchases.map do |registration_number, name, purchased_at, amount, vat, price, count, deductible|
        v = self.find_or_initialize_by_vat_form(vat_return.form)
        index = index + 1
        v.slip_seq = index
        v.slip_type = type
        case type
        when :personal_card
          v.card_type = 8
          v.card_no = name
          v.vend_trade_nm = ""
          v.approve_dt = ""
          v.deduct_yn = "Y"
        when :hometax_card
          v.card_type = 9
          v.card_no = ""
          v.vend_trade_nm = name
          v.approve_dt = purchased_at.strftime("%Y%m%d")
          v.deduct_yn = vat_return.grouped_deductible_purchases.dig([registration_number, "사업용카드"], 0)&.deductible ? "Y" : "N"
        when :cash_receipt
          v.card_type = ""
          v.card_no = ""
          v.vend_trade_nm = name
          v.approve_dt = purchased_at.strftime("%Y%m%d")
          v.deduct_yn = vat_return.grouped_deductible_purchases.dig([registration_number, "현금영수증"], 0)&.deductible ? "Y" : "N"
        end
        v.vend_biz_reg_no = vendor_registration_number
        v.slip_cnt = count
        v.supply_amt = price
        v.vat_amt = vat
        v.total_amt = amount
        v.pseudo_buy_yn = vat_return.deemed_purchases_deductibles.dig([registration_number, type], 0)&.deemed ? "Y" : "N"
        v
      end
    end
    

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
      self.declare_seq ||= "1"

      self.slip_no = ""
      self.approve_no = ""
      self.vend_cd = ""
      self.card_cd = ""
      self.service_amt = 0
      self.approve_dt = "" if self.approve_dt.nil?

      self.middle_miss_yn = "N"
      self.common_buy_yn = "N"
      self.common_buy_amt = "N"
      self.asset_yn = "N"
      self.asset_type = "0"

      self.recycle_yn = "N"

      self.rmk = ""
      self.uptae = ""
      self.jongmok = ""
      self.card_cmpy_nm = ""

      self.vend_tax_type = ""
      self.nts_vend_tax_type_nm = ""
    end
  end
end
