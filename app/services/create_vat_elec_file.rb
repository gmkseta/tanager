class CreateVatElecFile < Service::Base
  param :vat_return_id
  
  def run
    vat_return = Snowdon::VatReturn.find(vat_return_id)
    ActiveRecord::Base.transaction do
      Foodtax::CmCharge.create!(member_cd: vat_return.member_cd)

      cm_member = Foodtax::CmMember.new(member_cd: vat_return.member_cd)
      cm_member.initialize_with_business(vat_return.business)
      cm_member.save!

      va_head = Foodtax::VaHead.new(
        member_cd: vat_return.business.member_cd,
        declare_type: "1",
        declare_due_dt: tax_declare_due_date,
        declare_dt: Date.current.strftime("%Y%m%d")
      )
      va_head.declare_file
    end
  end
end