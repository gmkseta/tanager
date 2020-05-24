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

    def self.find_or_initialize_by_declare_user(declare_user)
      ic_head = self.find_or_initialize_by(
        cmpy_cd: "00025",
        person_cd: declare_user.person_cd,
        term_cd: "2019",
        declare_seq: "1",
        declare_type: "01"
      )
      ic_head
    end

    def import_by(declare_user, ic_person, calculated_tax)
      self.hometax_id = declare_user.hometax_account
      self.submit_yyyymm = Date.today.strftime("%Y%m")
      self.return_bank = declare_user.bank_code || ""
      self.return_acct_no = declare_user.bank_account_number || ""
      self.return_bank_type = ""
      self.self_declare_yn = "Y"
      self.cta_cmpy_cd = "40000"
      address = declare_user.hometax_address || declare_user.address
      split_address = address.split
      self.addr1 = split_address[0] || ""
      self.addr2 = split_address[1] || ""
      self.addr3 = split_address[2..]&.join(" ") || ""

      self.dong_cd = ""
      self.taxoffice_cd = ""
      self.jumin_location_nm = ""

      self.term_str_dt = 1.year.ago.beginning_of_year.strftime("%Y%m%d")
      self.term_end_dt = 1.year.ago.end_of_year.strftime("%Y%m%d")
      self.pre_term_str_dt = 2.year.ago.beginning_of_year.strftime("%Y%m%d")
      self.pre_term_end_dt = 2.year.ago.end_of_year.strftime("%Y%m%d")
      self.write_dt = "20200601"
      self.declare_due_dt = "20200601"
      self.simple_rate_yn = "N"
      self.addr_tel_no = ic_person.tel_no
      self.biz_tel_no = ic_person.tel_no
      self.cp_no = ic_person.tel_no
      self.email = ""
      self.gijang_declare_type = FoodtaxHelper.gijang_declare_type(declare_user)
      self.gijang_duty_type = FoodtaxHelper.gijang_duty_type(declare_user)
      self.daeri_type = "1"
      self.jumin_location_nm = ""

      self.resident_yn = "Y"
      self.resident_national_cd = "KR"
      self.foreign_yn = declare_user.is_local? ? "N" : "Y"
      self.foregn_simple_rate_yn = "N"
      self.employ_yn = "N"
      self.house_nonsep_force_yn = "N"
      self.house_lease_sep_yn = "X"
      self.house_cnt = "0"
      self.std_tax_deduct_yn = "N"

      self.biz_income_amt = [declare_user.total_income_amount, 0].max
      self.salary_sale_amt = "0"
      self.total_sale_amt = declare_user.business_incomes_sum
      self.income_amt = [declare_user.total_income_amount, 0].max

      self.deduct_amt = [declare_user.total_deduction_amount, self.income_amt].min
      self.income_standard_amt = calculated_tax.base_taxation
      self.income_rate = calculated_tax.tax_rate
      self.income_yieldtax_amt = calculated_tax.calculated_tax
      self.income_taxgam_amt = calculated_tax.limited_tax_exemption
      self.income_taxgong_amt = calculated_tax.limited_tax_credit

      self.income_decisiontax_jong_amt = calculated_tax.determined_tax
      self.income_decisiontax_sep_amt = 0
      self.income_decisiontax_amt = calculated_tax.determined_tax

      self.income_addtax_amt = declare_user.penalty_tax_sum
      self.income_addpaytax_amt = 0
      self.income_total_amt = calculated_tax.determined_tax


      self.income_prepay_amt = declare_user.hometax_individual_income.prepaid_tax
      self.income_paytax_amt = calculated_tax.payment_tax

      self.income_special_minus = 0
      self.income_special_add = 0
      self.income_septax_amt = 0
      self.income_due_paytax_amt = calculated_tax.payment_tax
      self.compare_cd = "1"


      self.addtax_deny_cd = ""
      self.addtax_gam_cd = 0
      self.autocal_yn_nogijang = "Y"
      self.autocal_yn_gijangdeduct = "X"
      self.close_yn = "N"
      self.close_dt = ""
      self.close_user_id = ""
      self.file_make_yn = "N"
      self.file_make_dt = ""
      self.file_make_cnt = 0
      self.file_make_user_id = ""
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
