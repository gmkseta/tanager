module Foodtax
  class IcFamily < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd, :term_cd, :declare_seq, :seq_no

    belongs_to :cm_member, foreign_key: :member_cd, primary_key: :member_cd
    belongs_to :va_head, foreign_key: :member_cd, primary_key: :member_cd


    def initialize_by_deductible_person(deductible_person,
                                        person_cd,
                                        seq_no)
      self.cmpy_cd = "00025"
      self.person_cd = person_cd
      self.term_cd = "2019"
      self.declare_seq = "1"
      self.seq_no = seq_no
      self.jumin_no = deductible_person.residence_number
      self.name = deductible_person.name
      self.relation_cd = deductible_person.classification.slug
      self.relation_nm = deductible_person.relation_name
      self.senior_yn = deductible_person.elder? ? "Y" : "N"
      self.disabled_yn = deductible_person.disabled ? "Y": "N"
      self.women_yn = deductible_person.woman_deduction? ? "Y" : "N"
      self.child6_yn = "N"
      self.oneparent_yn = deductible_person.single_parent? ? "Y" : "N"
      self.native_cd = "1"
      self.basic_yn = deductible_person.basic_yn? ? "Y" : "N"
      self.delivery_yn = deductible_person.new_born? ? "Y" : "N"
      self.partner_yn = deductible_person.spouse? ? "Y" : "N"
      self.resident_yn = "1"
      self.insu_yn = "N"
      self.medi_yn = "N"
      self.edu_yn = "N"
      self.card_yn = "N"
      self.children_yn = deductible_person.dependant_children? ? "Y" : "N"
      self.resident_national_cd = "KR"
    end
  end
end
