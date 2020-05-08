class CreateDeclareUser < Service::Base
  param :user
  option :name
  option :residence_number
  option :address
  option :declare_tax_type, optional: true
  option :hometax_account, optional: true
  option :disabled, optional: true
  option :single_parent, optional: true
  option :woman_deduction, optional: true
  option :status, optional: true
  option :married, optional: true

  def run
    ActiveRecord::Base.transaction do
      hometax_account ||= user.hometax_account || "XXXXXX"
      declare_user = DeclareUser.find_or_initialize_by(
        user_id: user.id,
        declare_tax_type: "income",
      )
      declare_user.name = name
      declare_user.residence_number = residence_number
      declare_user.address = address
      declare_user.disabled = disabled
      declare_user.single_parent = single_parent
      declare_user.woman_deduction = woman_deduction
      declare_user.hometax_account = hometax_account
      declare_user.status = status || DeclareUser.statuses["user"]
      declare_user.married = married
      declare_user.save!

      if declare_user.new_record?
        hometax_individual_incomes = HometaxIndividualIncome.where(owner_id: user.owner_id)
        if hometax_individual_incomes.blank?
          SlackBot.ping("#{Rails.env.development? ? "[테스트] " : ""} *세금신고오류* #{declare_user.name}님 - 신고불가: 홈택스 데이터 없음)", channel: "#labs-ops")
          raise ActiveRecord::RecordInvalid.new(InvalidRecord.new)
        end
        hometax_individual_incomes.update_all(declare_user_id: declare_user.id)
        businesses = Snowdon::Business.where(owner_id: user.owner_id)
        businesses.each do |b|
          next if b.hometax_business.blank?
          simplified_bookkeepings = b.calculate(declare_user.id)
          SimplifiedBookkeeping.upsert(rows: simplified_bookkeepings)
        end
      end
      declare_user
    end
  end
end