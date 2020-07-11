module Foodtax
  class VaTiSlip < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq, :slip_seq
    after_initialize :default_values

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd

    def with_purchases_invoice(purchases_invoice)
      self.slip_type = purchases_invoice.tax_invoice ? 1 : 2
      self.slip_cnt = 1

      self.vend_biz_reg_no = purchases_invoice.vendor_registration_number
      self.vend_trade_nm = purchases_invoice.vendor_business_name.truncate(50)

      self.supply_amt = purchases_invoice.price
      self.vat_amt = purchases_invoice.tax
      self.total_amt = purchases_invoice.amount

      if purchases_invoice.hometax_purchase_tag
        self.nodeduct_type = purchases_invoice.hometax_purchase_tag.nodeduct_reason_id if deduct_yn == "N"
        self.asset_yn = purchases_invoice.hometax_purchase_tag.fixed_asset ? "Y" : "N"
        self.pseudo_buy_yn = purchases_invoice.hometax_purchase_tag.deemed_input_tax ? "Y" : "N"
        self.deduct_yn = (purchases_invoice.hometax_purchase_tag.deductible || pseudo_buy_yn == "Y") ? "Y" : "N"
      else
        self.deduct_yn = "Y"
        self.pseudo_buy_yn = if %w(금융 자동차).any? { |n| purchases_invoice.vendor_business_category&.include? n }
                               "N"
                             else
                               purchases_invoice.tax_invoice ? "N" : "Y"
                             end
      end
      self.approve_dt = purchases_invoice.written_at.strftime("%Y%m%d")
    end

    def with_sales_invoice(sales_invoice)
      self.slip_type = sales_invoice.tax_invoice ? 3 : 4
      self.slip_cnt = sales_invoice.sales_count

      self.vend_biz_reg_no = sales_invoice.customer_registration_number
      self.vend_trade_nm = sales_invoice.customer_business_name.truncate(50)

      self.supply_amt = sales_invoice.sum_price
      self.vat_amt = sales_invoice.sum_tax
      self.total_amt = sales_invoice.sum_amount

      self.deduct_yn = "Y"
      self.pseudo_buy_yn = sales_invoice.tax_invoice ? "N" : "Y"
      self.approve_dt = sales_invoice.written_at.strftime("%Y%m%d")
    end

    def with_paper_invoice(paper_invoice) # rubocop:disable Metrics/MethodLength
      case paper_invoice.invoice_type
      when "PurchaseTaxInvoice"
        self.slip_type = 1
        self.deduct_yn = "Y"
        if paper_invoice.hometax_purchase_tag
          self.nodeduct_type = paper_invoice.hometax_purchase_tag.nodeduct_reason_id if deduct_yn == "N"

          self.asset_yn = paper_invoice.hometax_purchase_tag.fixed_asset ? "Y" : "N"
          self.pseudo_buy_yn = paper_invoice.hometax_purchase_tag.deemed_input_tax ? "Y" : "N"
          self.deduct_yn = (paper_invoice.hometax_purchase_tag.deductible || pseudo_buy_yn == "Y") ? "Y" : "N"
        else
          self.pseudo_buy_yn = (paper_invoice.sum_vat == 0) ? "Y" : "N"
        end
      when "PurchaseInvoice"
        self.slip_type = 2
        self.deduct_yn = "Y"
        if paper_invoice.hometax_purchase_tag
          self.deduct_yn = paper_invoice.hometax_purchase_tag.deductible ? "Y" : "N"
          self.nodeduct_type = paper_invoice.hometax_purchase_tag.nodeduct_reason_id if deduct_yn == "N"

          self.asset_yn = paper_invoice.hometax_purchase_tag.fixed_asset ? "Y" : "N"
          self.pseudo_buy_yn = paper_invoice.hometax_purchase_tag.deemed_input_tax ? "Y" : "N"
        else
          self.deduct_yn = "Y"
          self.pseudo_buy_yn = (paper_invoice.sum_vat == 0) ? "N" : "Y"
        end
      when "SaleTaxInvoice"
        self.slip_type = 3
        self.deduct_yn = "Y"
        self.pseudo_buy_yn = "N"
      when "SaleInvoice"
        self.slip_type = 4
        self.deduct_yn = "Y"
        self.pseudo_buy_yn = "Y"
      end

      self.slip_cnt = paper_invoice.total_count

      self.vend_biz_reg_no = paper_invoice.trader_registration_number
      self.vend_trade_nm = paper_invoice.trader_business_name

      self.supply_amt = paper_invoice.sum_price
      self.vat_amt = paper_invoice.sum_vat
      self.total_amt = paper_invoice.sum_amount
      self.approve_dt = paper_invoice.issued_at.strftime("%Y%m%d")
    end

    private

    def default_values
      self.cmpy_cd ||= "00025"
      self.term_cd ||= "#{tax_declare_year}#{tax_declare_term}"
      self.declare_seq ||= "1"

      self.deduct_yn = "Y" if deduct_yn.blank?
      self.asset_type = "0" if asset_type.blank?
      self.approve_no = "XXXX" if approve_no.blank?
      self.nodeduct_type = "0" if nodeduct_type.blank?
    end
  end
end
