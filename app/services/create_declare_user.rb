class CreateDeclareUser < Service::Base
  param :user
  option :validate
  option :name, optional: true
  option :hometax_account, optional: true
  option :residence_number, optional: true
  option :address, optional: true
  option :declare_tax_type, optional: true
  option :disabled, optional: true
  option :single_parent, optional: true
  option :woman_deduction, optional: true
  option :status, optional: true
  option :married, optional: true

  def run
    ActiveRecord::Base.transaction do
      declare_user = DeclareUser.find_or_initialize_by(
        user_id: user.id,
        declare_tax_type: "income",
        taxation_month: 1.year.ago.beginning_of_year,
      )
      is_new_record = declare_user.new_record?
      declare_user.residence_number = residence_number
      declare_user.name = name
      declare_user.address = address
      declare_user.disabled = disabled
      declare_user.single_parent = single_parent
      declare_user.woman_deduction = woman_deduction
      declare_user.hometax_account = hometax_account
      declare_user.status = status || DeclareUser.statuses["user"]
      declare_user.married = married
      declare_user.save!(validate: validate)
      if is_new_record
        hometax_individual_incomes = HometaxIndividualIncome.where(owner_id: user.owner_id)
        hometax_individual_incomes.update(declare_user_id: declare_user.id)
        HometaxSocialInsurance.where(owner_id: user.owner_id).update(declare_user_id: declare_user.id)
        businesses = Snowdon::Business.where(owner_id: user.owner_id)
        businesses.each do |b|
          next if b.hometax_business.blank?
          simplified_bookkeepings = b.calculate(declare_user.id)
          SimplifiedBookkeeping.upsert(rows: simplified_bookkeepings)
        end
        BusinessExpense.create_insurances(
          declare_user.id,
          businesses.first.registration_number
        )
        BusinessExpense.create_wage(declare_user.id)
      end
      SendSlackMessageJob.perform_later(
        "*종소세* #{declare_user.name} 종소세 유저생성",
        "#tax-ops"
      )
      declare_user
    end
  end
end