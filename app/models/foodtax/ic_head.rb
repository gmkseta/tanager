module Foodtax
  class IcHead < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd, :term_cd, :declare_seq
    after_initialize :initialize_local_taxes
    after_initialize :initialize_rural_taxes

    def declare_file      
      results = Foodtax::IcHead.execute_procedure :sp_ic_head_file_gen_only_hometax,
        cmpy_cd: cmpy_cd,
        person_cd: person_cd,
        term_cd: term_cd,
        declare_seq: declare_seq,
        form_cd: '',
        login_user_id: 'KCD',
        return_val1: ''
      Base64.encode64(results.flatten.first["result"].force_encoding("UTF-8").encode("EUC-KR"))
    end

    def self.find_or_initialize_by_declare_user(ic_person, declare_user, calculated_tax)
      ic_head = self.find_or_initialize_by(
        cmpy_cd: "00025",
        person_cd: declare_user.person_cd,
        term_cd: "2019",
        declare_seq: "1",
        declare_type: "01"
      )
      ic_head.hometax_id = declare_user.hometax_account
      ic_head.submit_yyyymm = Date.today.strftime("%Y%m")
      ic_head.return_bank = declare_user.bank_code || ""
      ic_head.return_acct_no = declare_user.bank_account_number || ""
      ic_head.return_bank_type = ""
      ic_head.self_declare_yn = "Y"
      ic_head.cta_cmpy_cd = "40000"
      address = declare_user.hometax_address || declare_user.address
      split_address = address.split
      ic_head.addr1 = split_address[0] || ""
      ic_head.addr2 = split_address[1] || ""
      ic_head.addr3 = split_address[2..]&.join(" ") || ""

      ic_head.dong_cd = ""
      ic_head.taxoffice_cd = ""
      ic_head.jumin_location_nm = ""

      ic_head.term_str_dt = 1.year.ago.beginning_of_year.strftime("%Y%m%d")
      ic_head.term_end_dt = 1.year.ago.end_of_year.strftime("%Y%m%d")
      ic_head.pre_term_str_dt = 2.year.ago.beginning_of_year.strftime("%Y%m%d")
      ic_head.pre_term_end_dt = 2.year.ago.end_of_year.strftime("%Y%m%d")
      ic_head.write_dt = "20200601"
      ic_head.declare_due_dt = "20200601"
      ic_head.simple_rate_yn = "N"
      ic_head.addr_tel_no = ic_person.tel_no
      ic_head.biz_tel_no = ic_person.tel_no
      ic_head.cp_no = ic_person.tel_no
      ic_head.email = ""
      ic_head.gijang_declare_type = FoodtaxHelper.gijang_declare_type(declare_user)
      ic_head.gijang_duty_type = FoodtaxHelper.gijang_duty_type(declare_user)
      ic_head.daeri_type = "1"
      ic_head.jumin_location_nm = ""

      ic_head.resident_yn = "Y"
      ic_head.resident_national_cd = "KR"
      ic_head.foreign_yn = declare_user.is_local? ? "Y" : "N"
      ic_head.foregn_simple_rate_yn = "N"
      ic_head.employ_yn = "N"
      ic_head.house_nonsep_force_yn = "N"
      ic_head.house_lease_sep_yn = "N"
      ic_head.house_cnt = "0"
      ic_head.std_tax_deduct_yn = "Y"

      ic_head.biz_income_amt = declare_user.business_incomes_sum
      ic_head.salary_sale_amt = "0"
      ic_head.total_sale_amt = declare_user.expenses_sum
      ic_head.income_amt = declare_user.total_income_amount
      ic_head.deduct_amt = declare_user.total_deduction_amount
      ic_head.income_standard_amt = calculated_tax.base_taxation
      ic_head.income_rate = calculated_tax.tax_rate
      ic_head.income_yieldtax_amt = calculated_tax.calculated_tax
      ic_head.income_taxgam_amt = calculated_tax.limited_tax_exemption
      ic_head.income_taxgong_amt = calculated_tax.limited_tax_credit

      ic_head.income_decisiontax_jong_amt = calculated_tax.determined_tax
      ic_head.income_decisiontax_sep_amt = 0
      ic_head.income_decisiontax_amt = calculated_tax.determined_tax

      ic_head.income_addtax_amt = declare_user.penalty_tax_sum
      ic_head.income_addpaytax_amt = 0
      ic_head.income_total_amt = calculated_tax.determined_tax


      ic_head.income_prepay_amt = declare_user.hometax_individual_income.prepaid_tax
      ic_head.income_paytax_amt = calculated_tax.payment_tax

      ic_head.income_special_minus = 0
      ic_head.income_special_add = 0
      ic_head.income_septax_amt = 0
      ic_head.income_due_paytax_amt = calculated_tax.payment_tax
      ic_head.compare_cd = "1"


      ic_head.addtax_deny_cd = ""
      ic_head.addtax_gam_cd = 0
      ic_head.autocal_yn_nogijang = "Y"
      ic_head.autocal_yn_gijangdeduct = "X"
      ic_head.close_yn = "N"
      ic_head.close_dt = ""
      ic_head.close_user_id = ""
      ic_head.file_make_yn = "N"
      ic_head.file_make_dt = ""
      ic_head.file_make_cnt = 0
      ic_head.file_make_user_id = ""
      ic_head
    end

    private

    def initialize_rural_taxes
      self.nong_standard_amt = 0
      self.nong_rate = 0
      self.nong_yieldtax_amt = 0
      self.nong_decisiontax_jong_amt = 0
      self.nong_decisiontax_sep_amt = 0
      self.nong_decisiontax_amt = 0
      self.nong_addtax_amt = 0
      self.nong_refund_amt = 0
      self.nong_total_amt = 0
      self.nong_prepay_amt = 0
      self.nong_paytax_amt = 0
      self.nong_septax_amt = 0
      self.nong_due_paytax_amt = 0
    end

    def initialize_local_taxes
      self.local_standard_amt = 0
      self.local_rate = 0
      self.local_taxgam_amt = 0
      self.local_taxgong_amt = 0
      self.local_yieldtax_amt = 0
      self.local_decisiontax_jong_amt = 0
      self.local_decisiontax_sep_amt = 0
      self.local_decisiontax_amt = 0
      self.local_nor_nondeclare_addtax_amt = 0
      self.local_den_nondeclare_addtax_amt = 0
      self.local_nor_mindeclare_addtax_amt = 0
      self.local_den_mindeclare_addtax_amt = 0
      self.local_declare_addtax_amt = 0
      self.local_delay_day_cnt = 0
      self.local_delay_addtax_amt = 0
      self.local_nogigang_addtax_amt = 0
      self.local_etc_addtax_amt = 0
      self.local_etc_addtax_sum_amt = 0
      self.local_addtax_sum_amt = 0
      self.local_special_prepay_amt = 0
      self.local_random_prepay_amt = 0
      self.local_realpay_amt = 0
      self.local_addpaytax_amt = 0
      self.local_total_amt = 0
    end
  end
end
