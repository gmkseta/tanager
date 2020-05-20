module Foodtax
  class IcFamily < Foodtax::ApplicationRecord
    include FoodtaxHelper
    self.primary_keys = :cmpy_cd, :person_cd, :term_cd, :declare_seq, :seq_no

    belongs_to :ic_person, foreign_key: :person_cd, primary_key: :person_cd

    def self.import(declare_user)
      self.import_self(declare_user)
      declare_user
        .deductible_persons
        .to_a
        .each_with_index
        .map {| p, i | self.find_or_initialize_by_deductible_person(
          p,
          declare_user.person_cd,
          "#{1.year.ago.year}",
          "1",
          "#{i + 2}").save!
      }
    end

    def self.import_self(declare_user)
      ic_family = self.find_or_initialize_by(
          cmpy_cd: "00025",
          person_cd: declare_user.person_cd,
          term_cd: "#{1.year.ago.year}",
          declare_seq: "1",
          seq_no: "1")
      ic_family.seq_no = "1"
      ic_family.jumin_no = declare_user.residence_number
      ic_family.name = declare_user.name
      ic_family.relation_cd = "0"
      ic_family.relation_nm = "소득자의 본인"
      ic_family.senior_yn = declare_user.elder? ? "Y" : "N"
      ic_family.disabled_yn = declare_user.disabled ? "Y": "N"
      ic_family.women_yn = declare_user.woman_deduction? ? "Y" : "N"
      ic_family.child6_yn = "N"
      ic_family.oneparent_yn = declare_user.single_parent? ? "Y" : "N"
      ic_family.native_cd = "1"
      ic_family.basic_yn = "Y"
      ic_family.delivery_yn = "0"
      ic_family.partner_yn = "N"
      ic_family.resident_yn = "1"
      ic_family.insu_yn = "N"
      ic_family.medi_yn = "N"
      ic_family.edu_yn = "N"
      ic_family.card_yn = "N"
      ic_family.children_yn = "N"
      ic_family.resident_national_cd = "KR"
      ic_family.save!
    end

    def self.find_or_initialize_by_deductible_person(deductible_person,
                                        person_cd,
                                        term_cd,
                                        declare_seq,
                                        seq_no)
      ic_family = self.find_or_initialize_by(
          cmpy_cd: "00025",
          person_cd: person_cd,
          term_cd: term_cd,
          declare_seq: declare_seq,
          seq_no: seq_no)
      ic_family.seq_no = seq_no
      ic_family.jumin_no = deductible_person.residence_number
      ic_family.name = deductible_person.name
      ic_family.relation_cd = deductible_person.classification.slug
      ic_family.relation_nm = deductible_person.relation_name
      ic_family.senior_yn = deductible_person.elder? ? "Y" : "N"
      ic_family.disabled_yn = deductible_person.disabled ? "Y": "N"
      ic_family.women_yn = deductible_person.woman_deduction? ? "Y" : "N"
      ic_family.child6_yn = "N"
      ic_family.oneparent_yn = deductible_person.single_parent? ? "Y" : "N"
      ic_family.native_cd = "1"
      ic_family.basic_yn = "Y"
      ic_family.delivery_yn = deductible_person.new_born? ? "#{declare_user.new_born_children_or_adopted_count}" : "0"
      ic_family.partner_yn = deductible_person.spouse? ? "Y" : "N"
      ic_family.resident_yn = "1"
      ic_family.insu_yn = "N"
      ic_family.medi_yn = "N"
      ic_family.edu_yn = "N"
      ic_family.card_yn = "N"
      ic_family.children_yn = deductible_person.dependant_children? ? "Y" : "N"
      ic_family.resident_national_cd = "KR"
      ic_family
    end
  end
end
