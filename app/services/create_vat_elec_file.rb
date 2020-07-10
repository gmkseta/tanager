class CreateVatElecFile < Service::Base
  param :vat_return_id
  
  def run
    vat_return = Snowdon::VatReturn.find(vat_return_id)
    ActiveRecord::Base.transaction do
      cm_member = Foodtax::CmMember.find_or_initialize_by_vat_return(vat_return)
      cm_member.import_general_form(vat_return.form)

      cm_charge = Foodtax::CmCharge.create!(
        cmpy_cd: "00025",
        member_cd: vat_return.member_cd
      )

      va_penalty = Foodtax::VaPenalty.find_or_initialize_by_vat_form(vat_return.form)
      va_penalty.import_general_form(vat_return.form)

      va_head = Foodtax::VaHead.find_or_initialize_by_vat_return(vat_return)      
      va_head.import_general_form(vat_return.form)
      va_head.declare_file
    end
  end
end
