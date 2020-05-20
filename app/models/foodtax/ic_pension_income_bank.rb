module Foodtax
  class IcPensionIncomeBank < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :bank_cd
    self.table_name = "ic_1232_bank"
    after_initialize :default_dates, :default_user_id
    private

    def default_dates
    end

    def default_user_id
    end
  end
end