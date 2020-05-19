module IndividualIncome
  class MergedBookkeeping
    extend Dry::Initializer
    option :classifications_with_business_expenses
    option :classifications_with_bookkeepings
    option :classifications_with_paper_and_personal_cards

    BUSINESS_EXPENSE_RENTAL = 12
    BUSINESS_EXPENSE_PUBLIC_IMPOST =13
    BUSINESS_EXPENSE_WAGE = 14
    BUSINESS_EXPENSE_ENTERTAINMENT = 15
    BUSINESS_EXPENSE_BUSINESS_INTERESTS =16
    BUSINESS_EXPENSE_BUSINESS_INSURANCE = 17
    BUSINESS_EXPENSE_LOCAL_INSURANCE = 20
    
    BOOKKEEPING_PUBLIC_IMPOST = 21
    BOOKKEEPING_RENTAL = 22
    BOOKKEEPING_VEHICLE = 23
    BOOKKEEPING_COMMISSION =24
    BOOKKEEPING_SUPPLY = 25
    BOOKKEEPING_WELFARE = 26
    BOOKKEEPING_TRANSPORTATION = 27
    BOOKKEEPING_ADVERTISEMENT = 28
    BOOKKEEPING_TRAVEL_EXPENSE = 29
    BOOKKEEPING_ENTERTAINMENT = 30
    BOOKKEEPING_SALES_COST = 31
    BOOKKEEPING_ETC = 32

    def wages
      business_expenses_by_expense_classification(BUSINESS_EXPENSE_WAGE)
    end

    def public_imposts
      bookkeeping_and_paper_by_account_classification(
          BOOKKEEPING_PUBLIC_IMPOST
        ) + business_expenses_by_expense_classification(
              BUSINESS_EXPENSE_PUBLIC_IMPOST
            )
    end

    def rentals
      bookkeeping_and_paper_by_account_classification(
          BOOKKEEPING_RENTAL
        ) + business_expenses_by_expense_classification(
              BUSINESS_EXPENSE_RENTAL
            )
    end

    def interests # business_expenses only
      business_expenses_by_expense_classification(
          BUSINESS_EXPENSE_BUSINESS_INTERESTS
        )
    end

    def entertainments
      bookkeeping_and_paper_by_account_classification(
          BOOKKEEPING_ENTERTAINMENT
        ) + business_expenses_by_expense_classification(
              BUSINESS_EXPENSE_ENTERTAINMENT
            )
    end

    def donations
      0
    end

    def depreciations
      0
    end

    def vehicle_maintenances
      bookkeeping_and_paper_by_account_classification(
        BOOKKEEPING_VEHICLE
      )
    end

    def commissions
      bookkeeping_and_paper_by_account_classification(
        BOOKKEEPING_COMMISSION
      )
    end

    def supplies
      bookkeeping_and_paper_by_account_classification(
        BOOKKEEPING_SUPPLY
      )
    end

    def welfares
      bookkeeping_and_paper_by_account_classification(
        BOOKKEEPING_WELFARE
      )
    end

    def transportations
      bookkeeping_and_paper_by_account_classification(
        BOOKKEEPING_TRANSPORTATION
      )

    end

    def advertisements
      bookkeeping_and_paper_by_account_classification(
        BOOKKEEPING_ADVERTISEMENT
      )
      
    end

    def travel_expenses
      bookkeeping_and_paper_by_account_classification(
        BOOKKEEPING_TRAVEL_EXPENSE
      )
    end

    def sales_costs
      bookkeeping_and_paper_by_account_classification(
        BOOKKEEPING_SALES_COST
      )
    end

    def insurances # business_expenses only
      business_expenses_by_expense_classification(        
        BUSINESS_EXPENSE_LOCAL_INSURANCE
      ) + business_expenses_by_expense_classification(
            BUSINESS_EXPENSE_BUSINESS_INSURANCE
          )
    end

    def etcs
      insurances + 
        bookkeeping_and_paper_by_account_classification(
          BOOKKEEPING_ETC
        )
    end

    def bookkeeping_and_paper_by_account_classification(account_classification_id)
      classifications_with_bookkeepings.select { |c|
          c["id"] == account_classification_id
        }.sum { |c| c["amount"] } +

        classifications_with_paper_and_personal_cards.select { |c|
            c["id"] == account_classification_id
          }.sum { |c| c["amount"] }
    end

    def business_expenses_by_expense_classification(expense_classification_id)
      classifications_with_business_expenses.select { |c|
          c["id"] == expense_classification_id
        }.sum { |c| c["amount"] }
    end

    def total_amount
      supplies + wages + rentals + public_imposts + interests +
        entertainments + welfares + commissions + donations +
          sales_costs + depreciations + transportations + etcs +
            vehicle_maintenances + advertisements + travel_expenses
    end

    def as_json
      {
        "상품": supplies,
        "급여": wages,
        "임차비": rentals,
        "제세공과금": public_imposts,
        "지급이자": interests,
        "접대비": entertainments,
        "복리후생비": welfares,
        "지급수수료": commissions,
        "기부금": donations,
        "소모품비": sales_costs,
        "감가상각비": depreciations,
        "운반비": transportations,
        "차량유지비": vehicle_maintenances,
        "광고선전비": advertisements,
        "여비교통비": travel_expenses,
        "기타": etcs,
      }
    end
  end
end
