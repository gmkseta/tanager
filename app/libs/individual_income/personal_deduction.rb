module IndividualIncome
  class PersonalDeduction
    def is_local?(residence_number)
      (residence_number[6] == "5" || residence_number(6) == "6")
    end

    def dependants?(age)
      20 >= age || age >= 60
    end

    def child?(age)
    end
  end
end
