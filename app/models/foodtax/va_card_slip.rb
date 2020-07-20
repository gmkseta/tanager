module Foodtax
  class VaCardSlip < Foodtax::ApplicationRecord
    enum slip_type: {
      personal_card: 1,
      hometax_card: 2,
      cash_receipt: 3,
    }
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq, :slip_seq, :slip_type
    after_initialize :default_values

    VALIDATABLE_ATTRIBUTES = %w(vend_biz_reg_no slip_cnt supply_amt vat_amt total_amt deduct_yn pseudo_buy_yn)
    validates_presence_of Foodtax::VaCardSlip.attribute_names.select{ |attr| VALIDATABLE_ATTRIBUTES.include?(attr) }

    def self.find_or_initialize_by_vat_form(form)
      self.find_or_initialize_by(
        cmpy_cd: "00025",
        member_cd: form.vat_return.member_cd,
        term_cd: form.vat_return.term_cd,
      )
    end

    def self.import_vat_return!(vat_return)
      sales = self.convert_card_slips(vat_return, vat_return.grouped_personal_cards)
      sales += self.convert_card_slips(vat_return, vat_return.grouped_hometax_card_purchases)
      sales += self.convert_card_slips(vat_return, vat_return.grouped_purchases_cash_receipts)

      self.import! sales
    end

    def self.convert_card_slips(vat_return, purchases)
      index = 0      
      purchases.map do |registration_number, name, card_number, purchased_at, amount, vat, price, count, deductible, deemed, type|
        v = self.find_or_initialize_by_vat_form(vat_return.form)
        index = index + 1
        v.slip_seq = index
        case type
        when "VatReturnPersonalCardPurchase"
          v.card_type = 8
          v.slip_type = :personal_card
          v.approve_dt = vat_return.form.period_start_date
          v.deduct_yn = "Y"
          v.vend_trade_nm = "개인카드 매입분"
        when "HometaxCardPurchase"
          v.card_type = 9
          v.slip_type = :hometax_card
          v.approve_dt = purchased_at&.strftime("%Y%m%d") || ""

          custom_deductible = vat_return.grouped_deductible_purchases.dig([registration_number, type], 0)&.deductible
          deduct = custom_deductible.nil? ? deductible : custom_deductible
          v.deduct_yn = deduct ? "Y" : "N"

          v.vend_trade_nm = name || "홈택스 카드 매입분"
        when "HometaxPurchasesCashReceipt"
          v.card_type = ""
          v.slip_type = :cash_receipt
          v.approve_dt = purchased_at.strftime("%Y%m%d")

          custom_deductible = vat_return.grouped_deductible_purchases.dig([registration_number, type], 0)&.deductible
          deduct = custom_deductible.nil? ? deductible : custom_deductible
          v.deduct_yn = deduct ? "Y" : "N"

          v.vend_trade_nm = name || "홈택스 현금영수증 매입분"
        end
        v.card_no = card_number || ""
        v.vend_biz_reg_no = registration_number
        v.slip_cnt = count
        v.supply_amt = price
        v.vat_amt = vat
        v.total_amt = amount

        custom_deemed = vat_return.deemed_purchases_deductibles.dig([registration_number, convert_deemed_type(type)], 0)&.deemed

        if vat.zero?
          pseudo_buy = custom_deemed.nil? ? (deemed || false) : custom_deemed
          v.pseudo_buy_yn = pseudo_buy ? "Y" : "N"
          v.deduct_yn = "Y" if v.pseudo_buy_yn == "Y"
        end

        v
      end
    end

    def self.convert_deemed_type(type)
      case type
      when "HometaxPurchasesCashReceipt"
        "cash_receipts"
      when "VatReturnPersonalCardPurchase"
        "personal_cards"
      when "HometaxCardPurchase"
        "business_cards"
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
      self.asset_type = 0
      self.approve_dt = "" if self.approve_dt.nil?

      self.middle_miss_yn = "N"
      self.common_buy_yn = "N"
      self.common_buy_amt = "N"
      self.asset_yn = "N"

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
