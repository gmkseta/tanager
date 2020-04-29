class AccountClassficationsController < ApplicationController
  before_action :authorize_request

  def index
    excluded_card_ids = @business.cards.where.not(@business.hometax_cards.include_number_query).pluck(&:id)

    results = @business.hometax_card_purchases.last_year.select(select_query("HomataxCardPurchase")).group(:vendor_registration_number).union(
      @business.hometax_purchases_cash_receipts.last_year.select(select_query("HomataxPurchasesCashReceipt")).group(:vendor_registration_number)).union(
        @business.hometax_purchases_invoices.last_year.select(select_query("HomataxPurchasesInvoice")).group(:vendor_registration_number)).union(
          @business.card_purchases_approvals.where(id: excluded_card_ids).last_year.select(select_query("홈택스 카드")).group(:vendor_registration_number)).order(sum_amount: :desc).paginate(page: 1)

    render json: { total_pages: results.total_pages, next_page: results.next_page, results: results.select{ |r| r.sum_amount > 0}.sort_by { |r| -r.sum_amount }.as_json(only: [:vendor_business_name, :vendor_registration_number, :sum_amount, :type])}.to_json
  end

  def summary

  end

  private

  def set_business
    public_id = @user.user_providers.cashnote.uid
    @business = Snowdon::Business.find_by(public_id: public_id)
  end

  def select_query(type)
    <<-SQL.squish
      MAX(vendor_business_name) as vendor_business_name,
      vendor_registration_number,
      SUM(amount) as sum_amount,
      '#{type}' as type
    SQL
  end
end
