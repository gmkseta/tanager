class CreateIncomeFoodtax < Service::Base
  param :declare_user_id
  
  def run
    declare_user = DeclareUser.find(declare_user_id)
    ActiveRecord::Base.transaction do
      cm_member = Foodtax::CmMember.find_or_initialize_by_declare_user(declare_user)
      cm_member.save!
      cm_charge = Foodtax::CmCharge.find_or_initialize_by_declare_user(declare_user)
      cm_charge.save!
      ic_person = Foodtax::IcPerson.import(declare_user)
      ic_family = Foodtax::IcFamily.import(declare_user)
      calculated_tax = declare_user.calculated_tax
      ic_head = Foodtax::IcHead.find_or_initialize_by_declare_user(
        declare_user
      )
      ic_head.import_by(declare_user, ic_person, calculated_tax)
      ic_head.save!
      ic_income = Foodtax::IcIncome.find_or_initialize_by_declare_user(
        declare_user,
        cm_member,
        calculated_tax
      )
      ic_income.save!

      ic_income_deduction = 
        Foodtax::IcIncomeDeduction.import_deductions(
          declare_user,
          calculated_tax.total_income
        )

      ic_income_details_sum = Foodtax::IcIncomeDetailsSum
        .find_or_initialize_by_declare_user(
          declare_user
        )
      ic_income_details_sum.save!

      ic_tax_credit_exemption = Foodtax::IcTaxCreditExemption.import(
        declare_user,
        calculated_tax
      )

      ic_prepaid_tax = Foodtax::IcPrepaidTax.import_prepaid_tax(
        declare_user
      )

      if declare_user.apply_bookkeeping?
        ic_simplified_bookkeeping = Foodtax::IcSimplifiedBookkeeping.import(
          declare_user,
          cm_member,
          ic_person,
          declare_user.merged_bookkeepings
        )
      else
        if declare_user.hometax_individual_income.is_simple_ratio?
          ic_simplerate = Foodtax::IcSimplerate.find_or_initialize_by_declare_user(
            declare_user,
            cm_member
          )
          ic_simplerate.save!
        end
      end
    end
  end
end