class DeleteFoodtaxVatForm < Service::Base
  param :vat_return_id
  
  def run
    vat_return = Snowdon::VatReturn.find(vat_return_id)

    cm_member = Foodtax::CmMember.find_or_initialize_by_vat_return(vat_return)
    cm_member&.delete

    cm_charge = Foodtax::CmCharge.find_or_initialize_by(
      cmpy_cd: "00025",
      member_cd: vat_return.member_cd
    )
    cm_charge&.delete if cm_charge.persisted?

    va_head = Foodtax::VaHead.find_or_initialize_by_vat_return(vat_return)
    va_head&.delete

    va_incomes = Foodtax::VaIncome.where(
      cmpy_cd: "00025",
      member_cd: vat_return.member_cd,
      term_cd: vat_return.term_cd
    )
    va_incomes&.delete_all

    va_card_sum = Foodtax::VaCardSum.find_or_initialize_by(
      cmpy_cd: "00025",
      member_cd: vat_return.member_cd,
      term_cd: vat_return.term_cd
    )
    va_card_sum&.delete

    va_card_slips = Foodtax::VaCardSlip.where(
      cmpy_cd: "00025",
      member_cd: vat_return.member_cd,
      term_cd: vat_return.term_cd
    )
    va_card_slips&.delete_all

    sales_bills_sum = Foodtax::VaOutBillSum.find_or_initialize_by_vat_form(vat_return.form)
    sales_bills_sum&.delete

    sales_invoices_sum = Foodtax::VaOutTiSum.find_or_initialize_by_vat_form(vat_return.form)
    sales_invoices_sum&.delete

    purchases_bills_sum = Foodtax::VaInBillSum.find_or_initialize_by_vat_form(vat_return.form)
    purchases_bills_sum&.delete

    purchases_invoices_sum = Foodtax::VaInTiSum.find_or_initialize_by_vat_form(vat_return.form)
    purchases_invoices_sum&.delete

    va_ti_slips = Foodtax::VaTiSlip.where(
      cmpy_cd: "00025",
      member_cd: vat_return.member_cd,
      term_cd: vat_return.term_cd
    )
    va_ti_slips&.delete_all

    va_penalty = Foodtax::VaPenalty.find_or_initialize_by_vat_form(vat_return.form)
    va_penalty&.delete

    va_nodeductible_purchase = Foodtax::VaNoDeductiblePurchase.find_or_initialize_by_vat_form(vat_return.form)
    va_nodeductible_purchase&.delete

    va_nodeductible_purchase_detail = Foodtax::VaNoDeductiblePurchaseDetail.find_or_initialize_by_vat_form(vat_return.form)
    va_nodeductible_purchase_detail&.delete

    va_pseudo_sum = Foodtax::VaPseudoSum.find_or_initialize_by_vat_form(vat_return.form)
    va_pseudo_sum&.delete

    covid19_summary = Foodtax::VaCovid19DeductionSummary.find_or_initialize_by(
      cmpy_cd: "00025",
      member_cd: vat_return.member_cd
    )
    covid19_summary&.delete

    covid19_summary_details = Foodtax::VaCovid19DeductionDetail.where(
      cmpy_cd: "00025",
      member_cd: vat_return.member_cd
    )
    covid19_summary_details&.delete_all
    
    business_status_form = Foodtax::VaBusinessStatusForm.find_or_initialize_by_vat_form(vat_return.form)
    business_status_form&.delete

    va_head
  end
end

    