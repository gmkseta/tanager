# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_04_12_165214) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

# Could not dump table "declare_users" because of following StandardError
#   Unknown type 'decalre_tax_type' for column 'declare_tax_type'

  create_table "individual_additional_taxes", force: :cascade do |t|
    t.bigint "individual_declare_id"
    t.string "additional_tax_code", limit: 14, null: false, comment: "가산세코드"
    t.integer "denominator", default: 0, null: false, comment: "가산세적용분모수"
    t.integer "numerator", default: 0, null: false, comment: "가산세적용분자수"
    t.integer "apply_date_count", default: 0, null: false, comment: "가산세적용일수"
    t.integer "base_amount", default: 0, null: false, comment: "기준금액"
    t.integer "amount", default: 0, null: false, comment: "가산세액"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["individual_declare_id"], name: "index_additional_taxes_on_declare_default_id"
  end

  create_table "individual_business_income_whts", force: :cascade do |t|
    t.bigint "individual_declare_id"
    t.string "business_residence_number", limit: 13, null: false, comment: "사업자 주민등록번호"
    t.string "serinal_number", limit: 6, null: false, comment: "일련번호"
    t.string "business_name", limit: 60, null: false, comment: "상호"
    t.integer "income_tax", comment: "소득세"
    t.integer "farming_tax", null: false, comment: "농특세"
    t.boolean "is_business", null: false, comment: "사업자주민구분"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["individual_declare_id"], name: "index_business_income_whts_on_declare_default_id"
  end

  create_table "individual_business_incomes", force: :cascade do |t|
    t.bigint "individual_declare_id"
    t.bigint "declare_user_id"
    t.string "income_code", limit: 2, default: "40", null: false, comment: "소득구분코드"
    t.string "serial_number", limit: 6, null: false, comment: "일련번호"
    t.string "business_address", limit: 70, null: false, comment: "사업장소재지"
    t.boolean "local", null: false, comment: "사업장 국내/국외"
    t.string "country_code", limit: 2, default: "KR", null: false, comment: "사업장 소재지국코드"
    t.string "business_name", limit: 60, null: false, comment: "상호"
    t.string "registration_number", limit: 10, null: false, comment: "사업자번호"
    t.string "business_phone_number", limit: 10, comment: "사업장 전화번호"
    t.string "account_type", limit: 2, null: false, comment: "기장 의무 (01: 복식부기, 02: 간편장부)"
    t.string "declare_type", limit: 2, null: false, comment: "신고 유형"
    t.string "classification_code", limit: 6, null: false, comment: "주업종코드"
    t.integer "incomes", null: false, comment: "총수입금액"
    t.integer "expenses", null: false, comment: "필요경비"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["declare_user_id"], name: "index_individual_business_incomes_on_declare_user_id"
    t.index ["individual_declare_id"], name: "index_business_income_on_declare_default_id"
  end

  create_table "individual_calculated_taxes", force: :cascade do |t|
    t.bigint "individual_declare_id"
    t.integer "total_income", default: 0, null: false, comment: "종합소득금액"
    t.integer "income_deduction", default: 0, null: false, comment: "소득공제"
    t.integer "base_taxation", default: 0, null: false, comment: "종합소득세 과세표준"
    t.float "tax_rate", null: false, comment: "종합소득세 세율"
    t.integer "calculated_tax", default: 0, null: false, comment: "종합소득세 산출세액"
    t.integer "tax_exemption", default: 0, null: false, comment: "종합소득세 세액감면"
    t.integer "tax_credit_amount", default: 0, null: false, comment: "종합소득세 세액공제"
    t.integer "determined_tax_taxation", default: 0, null: false, comment: "종합소득세 결정세액 종합과세"
    t.integer "determined_tax_estate_income", default: 0, null: false, comment: "종합소득세 결정세액 분리과세주택임대소득"
    t.integer "determined_tax_sum", default: 0, null: false, comment: "종합소득세 결정세액 합계"
    t.integer "additional_tax", default: 0, null: false, comment: "종합소득세 가산세"
    t.integer "extra_tax", default: 0, null: false, comment: "종합소득세 추가납부세액"
    t.integer "total_amount", default: 0, null: false, comment: "종합소득세 합계"
    t.integer "prepaid_amount", default: 0, null: false, comment: "종합소득세 기납부세액"
    t.integer "payment_tax", default: 0, null: false, comment: "종합소득세 납부할세액"
    t.integer "payment_deducted_tax", default: 0, null: false, comment: "종합소득세 납부할세액 차감"
    t.integer "payment_additional_tax", default: 0, null: false, comment: "종합소득세 납부할세액 가산"
    t.integer "installment_tax", default: 0, null: false, comment: "종합소득세 분납할세액"
    t.integer "declare_period_payment_tax", default: 0, null: false, comment: "종합소득세 신고기한내 납부할세액"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["individual_declare_id"], name: "index_calculated_taxes_on_declare_default_id"
  end

  create_table "individual_declares", force: :cascade do |t|
    t.bigint "declare_user_id", null: false
    t.bigint "tax_account_id"
    t.string "declare_code", limit: 2, null: false, comment: "신고구분상세코드"
    t.boolean "individual", null: false, comment: "개인단체구분코드"
    t.string "civil_appeal_code", limit: 5, null: false, comment: "민원종류코드"
    t.date "declare_date", null: false, comment: "과세기간_년월"
    t.datetime "submit_at", null: false, comment: "제출년월"
    t.string "bank_code", limit: 3, comment: "은행코드(국세환급금)"
    t.string "bank_account", limit: 20, comment: "계좌번호(국세환급금)"
    t.string "bank_type", limit: 20, comment: "예금종류"
    t.date "declare_start_date", null: false, comment: "당해과세기간시작"
    t.date "declare_end_date", null: false, comment: "당해과세기간종료"
    t.datetime "written_at", null: false, comment: "작성일자"
    t.string "declare_type", limit: 2, null: false, comment: "신고유형"
    t.string "account_type", limit: 2, null: false, comment: "기장의무구분(소득세)"
    t.string "residence_code", limit: 1, null: false, comment: "거주자구분코드"
    t.string "country_code", limit: 2, default: "KR", null: false, comment: "거주지국코드(영문대문자)"
    t.string "foreign_tax_rate_code", default: "2", null: false, comment: "외국인단일세율적용구분코드"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["declare_user_id"], name: "index_individual_declares_on_declare_user_id"
    t.index ["tax_account_id"], name: "index_individual_declares_on_tax_account_id"
  end

  create_table "individual_income_deductions", force: :cascade do |t|
    t.bigint "individual_declare_id"
    t.string "deduction_code", limit: 2, null: false, comment: "공제감면코드"
    t.integer "deduction_amount", null: false, comment: "공제금액"
    t.integer "personal_deduction_count", comment: "인적공제명수"
    t.integer "personal_deduction_amount", comment: "인적기본공제금액"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["individual_declare_id"], name: "index_income_deductions_on_declare_default_id"
  end

  create_table "individual_personal_deductions", force: :cascade do |t|
    t.bigint "individual_declare_id"
    t.string "residence_number", limit: 13, null: false, comment: "주민등록번호"
    t.string "name", limit: 30, null: false, comment: "성명"
    t.string "relation_code", limit: 1, null: false, comment: "관계코드"
    t.string "relation_name", limit: 20, null: false, comment: "관계"
    t.boolean "elder", default: false, null: false, comment: "경로자여부"
    t.boolean "disabled", default: false, null: false, comment: "장애인여부"
    t.boolean "woman_deduction", default: false, null: false, comment: "부녀자여부"
    t.boolean "child", default: false, null: false, comment: "6세이하자여부"
    t.boolean "single_parent", default: false, null: false, comment: "한부모가족공제여부"
    t.boolean "foreign", default: false, null: false, comment: "내외국구분코드"
    t.boolean "default_deduction", default: false, null: false, comment: "기본공제여부"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["individual_declare_id"], name: "index_personal_deductions_on_declare_default_id"
  end

  create_table "individual_prepaid_taxes", force: :cascade do |t|
    t.bigint "individual_declare_id"
    t.string "interim_prepayment", limit: 14, null: false, comment: "중간예납세액 소득"
    t.string "sales_land_prepaid_amont", limit: 14, null: false, comment: "토지등매매차익예정신고납부세액_소득"
    t.string "sales_land_pre_notice_amont", limit: 14, null: false, comment: "토지등매매차익예정고지세액_소득"
    t.string "frequently_assessed_amount", limit: 14, null: false, comment: "수시부과세_소득"
    t.string "interest_income_wht", limit: 14, null: false, comment: "원천징수 이자소득"
    t.string "dividend_income_wht", limit: 14, null: false, comment: "원천징수 배당소득"
    t.string "business_income_wht", limit: 14, null: false, comment: "원천징수 사업소득"
    t.string "wage_income_wht", limit: 14, null: false, comment: "원천징수 근로소득"
    t.string "pension_income_wht", limit: 14, null: false, comment: "원천징수 연금소득"
    t.string "other_income_wht", limit: 14, null: false, comment: "원천징수 기타소득"
    t.string "sum_prepaid_amount", limit: 14, null: false, comment: "기납부세액합계_소득"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["individual_declare_id"], name: "index_prepaid_taxes_on_declare_default_id"
  end

  create_table "individual_special_taxation_income_deductions", force: :cascade do |t|
    t.bigint "individual_declare_id"
    t.integer "serinal_number", default: 1, null: false, comment: "일련번호"
    t.string "deduction_code", limit: 3, null: false, comment: "소득공제코드"
    t.integer "deduction_amount", default: 0, null: false, comment: "공제세액"
    t.string "registration_number", limit: 10, null: false, comment: "사업자등록번호"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["individual_declare_id"], name: "index_special_taxation_income_on_declare_default_id"
  end

  create_table "individual_tax_credits", force: :cascade do |t|
    t.bigint "individual_declare_id"
    t.integer "serinal_number", default: 1, null: false, comment: "일련번호"
    t.string "tax_credit_code", limit: 3, null: false, comment: "세액공제코드"
    t.integer "base_amount", default: 0, null: false, comment: "공제대상금액"
    t.integer "amount", default: 0, null: false, comment: "공제금액"
    t.string "registration_number", limit: 10, null: false, comment: "사업자등록번호"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["individual_declare_id"], name: "index_tax_credits_on_declare_default_id"
  end

  create_table "individual_tax_exemptions", force: :cascade do |t|
    t.bigint "individual_declare_id"
    t.integer "serinal_number", default: 1, null: false, comment: "일련번호"
    t.string "tax_exemption_code", limit: 3, null: false, comment: "세액감면코드"
    t.integer "tax_exemption_amount", default: 0, null: false, comment: "세액감면"
    t.string "registration_number", limit: 10, null: false, comment: "사업자등록번호"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["individual_declare_id"], name: "index_tax_exemptions_on_declare_default_id"
  end

  create_table "individual_wage_pensions", force: :cascade do |t|
    t.bigint "individual_declare_id"
    t.string "income_code", null: false, comment: "소득구분코드"
    t.string "serinal_number", null: false, comment: "일련번호"
    t.string "employer_business_name", comment: "소득지급자_상호"
    t.string "employer_registration_number", comment: "소득지급자_사업자등록번호"
    t.integer "income_amount", null: false, comment: "총수입금액(총급여액)"
    t.integer "profit_amount", null: false, comment: "필요경비(근로소득공제)"
    t.integer "income", null: false, comment: "소득금액"
    t.integer "wht_income_tax", null: false, comment: "원천징수_소득세"
    t.integer "wht_farm_tax", null: false, comment: "원천징수_농득세"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["individual_declare_id"], name: "index_wage_pensions_on_declare_default_id"
  end

  create_table "tax_accountants", force: :cascade do |t|
    t.string "name", limit: 30, null: false, comment: "세무대리인성명"
    t.string "residence_number", limit: 13, null: false, comment: "세무대리인주민등록번호"
    t.string "phone_number", limit: 14, comment: "세무대리인전화번호"
    t.string "registration_number", limit: 10, null: false, comment: "세무대리인사업자등록번호"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_providers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.string "token"
    t.jsonb "response"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["provider", "uid"], name: "index_user_providers_on_provider_and_uid", unique: true
    t.index ["token"], name: "index_user_providers_on_token", unique: true
    t.index ["user_id"], name: "index_user_providers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "login"
    t.string "password_digest", null: false
    t.string "name"
    t.string "phone_number"
    t.string "hometax_account"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["login"], name: "index_users_on_login", unique: true
  end

  add_foreign_key "declare_users", "users"
  add_foreign_key "individual_additional_taxes", "individual_declares"
  add_foreign_key "individual_business_income_whts", "individual_declares"
  add_foreign_key "individual_business_incomes", "declare_users"
  add_foreign_key "individual_business_incomes", "individual_declares"
  add_foreign_key "individual_calculated_taxes", "individual_declares"
  add_foreign_key "individual_declares", "declare_users"
  add_foreign_key "individual_income_deductions", "individual_declares"
  add_foreign_key "individual_personal_deductions", "individual_declares"
  add_foreign_key "individual_prepaid_taxes", "individual_declares"
  add_foreign_key "individual_special_taxation_income_deductions", "individual_declares"
  add_foreign_key "individual_tax_credits", "individual_declares"
  add_foreign_key "individual_tax_exemptions", "individual_declares"
  add_foreign_key "individual_wage_pensions", "individual_declares"
  add_foreign_key "user_providers", "users"
end
