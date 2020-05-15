module Foodtax
  class IcIncome < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd, :term_cd, :declare_seq, :seq_no
    self.table_name = "VA_ELEC_FILE_CONTENTS"
    after_initialize :default_user_id

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd
    belongs_to :va_head, foreign_key: :member_cd, primary_key: :member_cd

    def initialize(declare_user,
                   cm_member)
      self.cmpy_cd = "00025"
      self.person_cd = "P#{"%06d" % declare_user.id}"
      self.term_cd = "2019"
      self.declare_seq = "1"
      self.seq_no = "1"
      self.member_cd = cm_member.member_cd
      self.income_type = "40"
      self.biz_addr = declare_user.hometax_address
      self.biz_native_yn = "Y"
      self.biz_national_cd = "KR"
      self.biz_trade_nm = cm_member.biz_trade_nm
      self.biz_reg_no = cm_member.biz_reg_no
      self.term_str_dt = "20190101"
      self.term_end_dt = "20191231"
      self.biz_tel_no = "--"
      self.gijang_declare_type = declare_user.gijang_declare_type
      self.gijang_duty_type = declare_user.gijang_duty_type
      self.upjong_cd = cm_member.upjong_cd
      self.total_sale_amt = declare_user.business_incomes_sum
      self.total_cost_amt = declare_user.expenses_sum
      self.income_amt = declare_user.total_income_amount
      self.combiz_yn = cm_member.combiz_yn
      self.comboss_yn = "N"
      self.comboss_jumin_no = ""
      self.comboss_type = ""
      self.comboss_name = ""
      self.withholding_income = 0
      self.withholding_nong = 0
      self.biz_yn = "Y"
      self.apply_yn = "Y"
    end
  end
end
