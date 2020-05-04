class UpdateSimplifiedBookkeeping < Service::Base
  option :simplified_bookkeeping
  option :params

  def run
    ActiveRecord::Base.transaction do
      simplified_bookkeeping.update!(params)
      rule = UserAccountClassificationRule.find_or_initialize_by(
        declare_user_id: simplified_bookkeeping.declare_user_id,
        vendor_registration_number: simplified_bookkeeping.vendor_registration_number,
        purchase_type: simplified_bookkeeping.purchase_type,
      )
      rule.classification_id = params[:classification_id]
      rule.deductible = params[:deductible]
      rule.save!
      simplified_bookkeeping
    end
  end
end
