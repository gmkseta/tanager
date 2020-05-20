module Foodtax
  class IcSimplerate < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd, :term_cd, :declare_seq, :income_seq_no

    self.table_name = "ic_simplerate"

    belongs_to :ic_person, foreign_key: :person_cd, primary_key: :person_cd

    def self.find_or_initialize_by_declare_user(declare_user, cm_member)
      ic_simplerate = self.find_or_initialize_by(
        cmpy_cd: "00025",
        person_cd: declare_user.person_cd,
        term_cd: "#{1.year.ago.year}",
        declare_seq: "1",
        income_seq_no: "1"
      )

      ic_simplerate.income_seq_no = "1"
      ic_simplerate.income_type = "40"
      ic_simplerate.biz_reg_no = cm_member.biz_reg_no
      ic_simplerate.addr = declare_user.hometax_address || declare_user.address
      ic_simplerate.upjong_cd = cm_member.upjong_cd
      ic_simplerate.upjong_nm = cm_member.jongmok
      ic_simplerate.jata_type = "T"

      ic_simplerate.jaga_rate = declare_user.hometax_individual_income.base_ratio_self
      ic_simplerate.taga_rate = declare_user.hometax_individual_income.base_ratio_basic

      ic_simplerate.sale_amt = declare_user.business_incomes_sum
      ic_simplerate.cost_amt = declare_user.hometax_individual_income.expenses_sum_by_ratio
      ic_simplerate.income_amt = declare_user.total_income_amount
      ic_simplerate
    end
  end
end
