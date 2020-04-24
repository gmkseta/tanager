class CreateIndividualDeclares < ActiveRecord::Migration[6.0]
  def change
    create_table :individual_declares do |t|
      t.references :declare_user, null: false, foreign_key: true
      t.references :tax_account

      t.string :declare_code, limit: 2, null: false, comment: "신고구분상세코드"
      t.boolean :individual, null: false, comment: "개인단체구분코드"
      t.string :civil_appeal_code, limit: 5, null: false, comment: "민원종류코드"
      t.date :declare_date, null: false, comment: "과세기간_년월"
      t.datetime :submit_at, null: false, comment: "제출년월"
      t.string :bank_code, limit: 3, comment: "은행코드(국세환급금)"
      t.string :bank_account, limit: 20, comment: "계좌번호(국세환급금)"
      t.string :bank_type, limit: 20, comment: "예금종류"
      t.date :declare_start_date, null: false, comment: "당해과세기간시작"
      t.date :declare_end_date, null: false, comment: "당해과세기간종료"
      t.datetime :written_at, null: false, comment: "작성일자"

      t.string :declare_type, limit: 2, null: false, comment: "신고유형"
      t.string :account_type, limit: 2, null: false, comment: "기장의무구분(소득세)"
      t.string :residence_code, limit: 1, null: false, comment: "거주자구분코드"
      t.string :country_code, limit: 2, null: false, default: "KR", comment: "거주지국코드(영문대문자)"
      t.string :foreign_tax_rate_code, limits: 1, null: false, default: "2", comment: "외국인단일세율적용구분코드"

      t.timestamps
    end
  end
end
