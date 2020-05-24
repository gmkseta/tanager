module Foodtax
  class IcIncome < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd, :term_cd, :declare_seq, :seq_no
    self.table_name = "ic_income"
    after_initialize :default_user_id

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd
    belongs_to :ic_person, foreign_key: :person_cd, primary_key: :person_cd

    def self.find_or_initialize_by_declare_user(declare_user, cm_member, calculated_tax)
      ic_income = self.find_or_initialize_by(
        cmpy_cd: "00025",
        person_cd: declare_user.person_cd,
        term_cd: "2019",
        declare_seq: "1",
        member_cd: cm_member.member_cd,
      )
      ic_income.cmpy_cd = "00025"
      ic_income.person_cd = declare_user.person_cd
      ic_income.term_cd = "2019"
      ic_income.declare_seq = "1"
      ic_income.seq_no = "1"
      ic_income.member_cd = cm_member.member_cd
      ic_income.income_type = "40"
      ic_income.biz_addr = "#{cm_member.biz_addr1} #{cm_member.biz_addr2}"
      ic_income.biz_native_yn = "Y"
      ic_income.biz_national_cd = "KR"
      ic_income.biz_trade_nm = cm_member.trade_nm
      ic_income.biz_reg_no = cm_member.biz_reg_no
      ic_income.term_str_dt = "20190101"
      ic_income.term_end_dt = "20191231"
      ic_income.biz_tel_no = "--"
      ic_income.gijang_declare_type = FoodtaxHelper.gijang_declare_type(declare_user)
      ic_income.gijang_duty_type = FoodtaxHelper.gijang_duty_type(declare_user)
      ic_income.upjong_cd = cm_member.upjong_cd
      ic_income.total_sale_amt = declare_user.business_incomes_sum
      ic_income.total_cost_amt = calculated_tax.expenses
      ic_income.income_amt = declare_user.total_income_amount
      ic_income.combiz_yn = cm_member.combiz_yn
      ic_income.comboss_yn = "N"
      ic_income.comboss_jumin_no = ""
      ic_income.comboss_type = ""
      ic_income.comboss_name = ""
      ic_income.withholding_income = 0
      ic_income.withholding_nong = 0
      ic_income.biz_yn = "Y"
      ic_income.apply_yn = "Y"
      ic_income
    end
  end
end
