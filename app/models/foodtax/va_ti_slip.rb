module Foodtax
  class VaTiSlip < Foodtax::ApplicationRecord
    self.primary_keys = :member_cd, :cmpy_cd, :term_cd, :declare_seq, :slip_seq
    after_initialize :default_values

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd

    validates :member_cd, presence: true, uniqueness: { scope: %i(cmpy_cd term_cd declare_seq slip_seq) }
    NON_VALIDATABLE_ATTRIBUTES = %w(slip_no deal_dt vend_cd person_jumin_no vend_trade_nm vend_trade_nm reg_date updt_date reg_user_id updp_user_id)
    validates_presence_of Foodtax::VaTiSlip.attribute_names.reject{ |attr| NON_VALIDATABLE_ATTRIBUTES.include?(attr)}

    def self.import_vat_return!(vat_return)
      deemed_invoices = vat_return.deemed_purchases.invoices.index_by(&:vendor_registration_number)
      deemed_paper_invoices = vat_return.deemed_purchases.paper_invoices.index_by(&:vendor_registration_number)

      deductible_purchases = vat_return.deductible_purchases.purchases_invoices.index_by(&:vendor_registration_number)

      purchases_invoices = vat_return.grouped_hometax_purchases_invoices(vat_return.form.date_range) + vat_return.grouped_purchases_paper_invoices
      purchases = []
      index = 0
      purchases_invoices.each do |registration_number, business_name, wrriten_at, amount, vat, price, count, deductible, deemed, type|
        ti_slip = self.new(
          member_cd: vat_return.member_cd,
          cmpy_cd: "00025",
          term_cd: vat_return.term_cd,
          declare_seq: "1"
        )
        index = index + 1
        ti_slip.slip_seq = index
        ti_slip.slip_type = vat.zero? ? 2 : 1
        ti_slip.slip_cnt = count
        ti_slip.vend_biz_reg_no = registration_number
        ti_slip.vend_trade_nm = business_name&.truncate(50) || ""
        ti_slip.supply_amt = price
        ti_slip.vat_amt = vat
        ti_slip.total_amt = amount
        ti_slip.eti_yn = type == "VatReturnPaperInvoice" ? "N" : "Y"
        
        ti_slip.approve_dt = wrriten_at.strftime("%Y%m%d")
        ti_slip.slip_each_yn = "N"

        no_deductible_id = deductible_purchases[registration_number]&.nodeduct_reason_id
        if no_deductible_id.present?
          ti_slip.nodeduct_type = NoDeductReson.find(custom_no_deductible_id).code
          ti_slip.pseudo_buy_yn = "N"
          ti_slip.deduct_yn = "N"
        else
          custom_deemed = deemed_paper_invoices[registration_number]&.deemed
          custom_deductible = deductible_purchases[registration_number]&.deductible
        
          pseudo_buy = custom_deemed.nil? ? (deemed && vat.zero?) : custom_deemed
          ti_slip.pseudo_buy_yn = pseudo_buy ? "Y" : "N"

          slip_deductible = custom_deductible.nil? ? deductible : custom_deductible
          ti_slip.deduct_yn = pseudo_buy ? "Y" : slip_deductible ? "Y" : "N"

          ti_slip.nodeduct_type = 0
        end
        purchases << ti_slip
      end
      Foodtax::VaTiSlip.import! purchases

      sales_invoices = vat_return.grouped_hometax_sales_invoices + vat_return.grouped_sales_paper_invoices
      sales = sales_invoices.map do |registration_number, business_name, wrriten_at, amount, vat, price, count, _, _, type|
        ti_slip = self.new(
          member_cd: vat_return.member_cd,
          cmpy_cd: "00025",
          term_cd: vat_return.term_cd,
          declare_seq: "1"
        )
        index = index + 1
        ti_slip.slip_seq = index
        ti_slip.slip_type = vat.zero? ? 4 :3
        ti_slip.pseudo_buy_yn = vat.zero? ? "Y" : "N"
        ti_slip.deduct_yn = "Y"
        ti_slip.slip_cnt = count
        ti_slip.vend_biz_reg_no = registration_number
        ti_slip.vend_trade_nm = business_name&.truncate(50) || ""
        ti_slip.supply_amt = price
        ti_slip.vat_amt = vat
        ti_slip.total_amt = amount
        ti_slip.nodeduct_type = 0
        ti_slip.eti_yn = type == "VatReturnPaperInvoice" ? "N" : "Y"
        ti_slip.approve_dt = wrriten_at.strftime("%Y%m%d")
        ti_slip.slip_each_yn = "N"
        ti_slip
      end
      Foodtax::VaTiSlip.import sales
    end

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
      self.declare_seq ||= "1"
      self.approve_no = "XXXX" if approve_no.blank?

      self.recycle_yn = "N"

      self.dup_yn = "N"
      self.dup_amt = "N"

      self.person_yn = "N"
      self.person_jumin_no = ""
      self.nodeduct_type = 0 if nodeduct_type.blank?

      self.asset_yn = "N"
      self.asset_type = 0 if asset_type.blank?
    end
  end
end
