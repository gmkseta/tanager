module Foodtax
  class IcBusinessIncomeWht < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd, :term_cd, :declare_seq, :seq_no
    self.table_name = "ic_1022"

    def initialize(declare_user, cm_member)
      self.cmpy_cd = "00025"
      self.person_cd = "P#{"%06d" % declare_user.id}"
      self.term_cd = "2019"
      self.declare_seq = "1"
      self.seq_no = "1"
      self.trade_nm = cm_member.biz_trade_nm
      self.biz_reg_no = cm_member.biz_reg_no
      self.jumin_no = declare_user.residence_number
      self.withholding_income = 0
      self.withholding_local = 0
      self.withholding_nong = 0
      self.biz_yn = "Y"
    end
  end
end
