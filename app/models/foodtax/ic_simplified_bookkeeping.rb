module Foodtax
  class IcSimplifiedBookkeeping < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd, :term_cd, :declare_seq, :seq_no
    self.table_name = "ic_1130"

    belongs_to :ic_person, foreign_key: :person_cd, primary_key: :person_cd

    def self.find_or_initialize_by_declare_user(declare_user)
      ic_pension_income_deduction = self.find_or_initialize_by(
        cmpy_cd: "00025",
        person_cd: declare_user.person_cd,
        term_cd: "2019",
        declare_seq: "1"
      )
      ic_pension_income_deduction
    end

    def self.import(declare_user, cm_member, ic_person, merged_bookkeepings)
      bookkeeping = self.find_or_initialize_by_declare_user(declare_user)
      bookkeeping.seq_no = "1"
      bookkeeping.member_cd = cm_member.member_cd

      bookkeeping.income_type = "40"
      bookkeeping.biz_reg_no = cm_member.biz_reg_no
      bookkeeping.addr = declare_user.hometax_address || declare_user.address
      bookkeeping.trade_nm = cm_member.trade_nm
      bookkeeping.upjong_cd = cm_member.upjong_cd
      bookkeeping.upjong_nm = cm_member.jongmok

      bookkeeping.book_sale_amt = declare_user.business_incomes_sum
      bookkeeping.book_etc_sale_amt = 0
      bookkeeping.book_sale_sum_amt = declare_user.business_incomes_sum
      bookkeeping.sale_except_amt = 0
      bookkeeping.sale_append_amt = 0
      bookkeeping.total_sale_amt = declare_user.business_incomes_sum

      bookkeeping.salecost_init = 0
      bookkeeping.salecost_purchase = merged_bookkeepings.sales_costs
      bookkeeping.salecost_stock = 0
      bookkeeping.salecost_amt = merged_bookkeepings.sales_costs

      bookkeeping.normal_salary = merged_bookkeepings.wages
      bookkeeping.normal_utilitybill = merged_bookkeepings.public_imposts
      bookkeeping.normal_rent = merged_bookkeepings.rentals
      bookkeeping.normal_interest = merged_bookkeepings.interests
      bookkeeping.normal_entertain = merged_bookkeepings.entertainments
      bookkeeping.normal_donate =  merged_bookkeepings.donations
      bookkeeping.normal_depre =  merged_bookkeepings.depreciations
      bookkeeping.normal_carmgmt = merged_bookkeepings.vehicle_maintenances
      bookkeeping.normal_commission = merged_bookkeepings.commissions
      bookkeeping.normal_consumable = merged_bookkeepings.supplies
      bookkeeping.normal_walfare = merged_bookkeepings.welfares
      bookkeeping.normal_transport = merged_bookkeepings.transportations
      bookkeeping.normal_advertise = merged_bookkeepings.advertisements
      bookkeeping.normal_traffic = merged_bookkeepings.travel_expenses
      bookkeeping.normal_etc = merged_bookkeepings.etcs
      bookkeeping.normal_sum = merged_bookkeepings.total_amount - merged_bookkeepings.sales_costs
      bookkeeping.book_cost_sum_amt = merged_bookkeepings.total_amount
      
      bookkeeping.cost_except_amt = 0
      bookkeeping.cost_append_amt = 0
      bookkeeping.total_cost_amt = merged_bookkeepings.total_amount
      bookkeeping.plusminus_income_amt = declare_user.total_income_amount
      bookkeeping.donate_limit_excess = 0
      bookkeeping.donate_cost_append = 0

      bookkeeping.year_income_amt = declare_user.total_income_amount
      bookkeeping.save!
    end
  end
end