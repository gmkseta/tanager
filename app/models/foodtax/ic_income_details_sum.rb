module Foodtax
  class IcIncomeDetailsSum < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd, :term_cd, :declare_seq, :income_type
    self.table_name = "ic_1040"

    belongs_to :ic_person, foreign_key: :person_cd, primary_key: :person_cd
    def self.find_or_initialize_by_declare_user(declare_user)
      ic_income_detail_sum = self.find_or_initialize_by(
        cmpy_cd: "00025",
        person_cd: declare_user.person_cd,
        term_cd: "2019",
        declare_seq: "1",
        income_type: "40"
      )
      ic_income_detail_sum.C0010 = declare_user.total_income_amount
      ic_income_detail_sum.C0020 = 0
      ic_income_detail_sum.C0030 = 0
      ic_income_detail_sum.C0040 = 0
      ic_income_detail_sum.C0050 = [declare_user.total_income_amount, 0].max
      ic_income_detail_sum
    end
  end
end
