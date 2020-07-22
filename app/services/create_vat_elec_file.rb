class CreateVatElecFile < Service::Base
  param :vat_return_id
  
  def run
    vat_return = Snowdon::VatReturn.find(vat_return_id)
    cm_member = Foodtax::CmMember.find_or_initialize_by_vat_return(vat_return)
    cm_member.import_general_form!(vat_return.form)

    cm_charge = Foodtax::CmCharge.find_or_create_by!(
      cmpy_cd: "00025",
      member_cd: vat_return.member_cd
    )

    va_head = Foodtax::VaHead.find_or_initialize_by_vat_return(vat_return)
    va_head.import_general_form(vat_return.form)

    Foodtax::VaIncome.import_general_form!(vat_return.form)
    Foodtax::VaCardSum.import_general_form!(vat_return.form)
    Foodtax::VaCardSlip.import_vat_return!(vat_return)

    sales_bills_sum = Foodtax::VaOutBillSum.find_or_initialize_by_vat_form(vat_return.form)
    sales_bills_sum.import_general_form!(vat_return.form)
    sales_invoices_sum = Foodtax::VaOutTiSum.find_or_initialize_by_vat_form(vat_return.form)
    sales_invoices_sum.import_general_form!(vat_return.form)

    purchases_bills_sum = Foodtax::VaInBillSum.find_or_initialize_by_vat_form(vat_return.form)
    purchases_bills_sum.import_general_form!(vat_return.form)
    purchases_invoices_sum = Foodtax::VaInTiSum.find_or_initialize_by_vat_form(vat_return.form)
    purchases_invoices_sum.import_general_form!(vat_return.form)

    Foodtax::VaTiSlip.import_vat_return!(vat_return)

    va_penalty = Foodtax::VaPenalty.find_or_initialize_by_vat_form(vat_return.form)
    va_penalty.import_general_form!(vat_return.form)

    Foodtax::VaNoDeductiblePurchase.import_general_form!(vat_return.form)
    Foodtax::VaNoDeductiblePurchaseDetail.import_general_form!(vat_return.form)

    Foodtax::VaPseudoSum.import_general_form!(vat_return.form)

    Foodtax::VaCovid19DeductionSummary.import_general_form!(vat_return.form)
    Foodtax::VaCovid19DeductionDetail.import_general_form!(vat_return.form)

    status_form = vat_return.business.status_forms.find_by(year: vat_return.year, period: vat_return.period)
    business_status_form = Foodtax::VaBusinessStatusForm.find_or_initialize_by_vat_form(vat_return.form)
    business_status_form.import_status_form!(status_form)
    
    file = va_head.declare_file
    raise ActiveRecord::Rollback if file.blank?
    file
  end
end
