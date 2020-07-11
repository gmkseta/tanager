module Cashnote
  class VatReturnData
    include Memoized

    extend Dry::Initializer

    param :vat_return

    delegate :business, :year, :period, to: :vat_return

    MonthlyDeliveryAppSales = Struct.new(:app, :name, :amount, :vat)

    def primary_classification_sales_amount
      {
        primary: true,
        classification: {
          code: business.hometax_business_classification_code,
          name: business.hometax_business_classification_name,
        },
        amount: total_sales_amount - (other_class_amounts&.values&.sum || 0),
      }
    end

    memoize def other_classification_sales_amounts
      return if other_class_amounts.nil?

      other_class_amounts.map do |code, amount|
        {
          primary: false,
          classification: HometaxBusinessClassification.find_by(code: code),
          amount: amount,
        }
      end
    end

    memoize def monthly_card_sales
      business.hometax_card_sales
        .where(month: month_range)
        .group(:month)
        .order(month: :desc)
        .sum(:amount)
    end

    memoize def monthly_cash_receipts_sales
      sql_month = to_sql_month("sold_at")

      business.hometax_sales_cash_receipts
        .where(sold_at: date_range)
        .group(Arel.sql(sql_month))
        .order(Arel.sql("#{sql_month} DESC"))
        .pluck(Arel.sql("
          #{sql_month},
          SUM(CASE WHEN receipt_type = 0 THEN amount ELSE -amount END),
          SUM(CASE WHEN receipt_type = 0 THEN vat ELSE -vat END)
        "))
    end

    memoize def monthly_invoices_sales
      sql_month = to_sql_month("written_at")

      business.hometax_sales_invoices
        .where(written_at: date_range)
        .group(Arel.sql(sql_month))
        .order(Arel.sql("#{sql_month} DESC"))
        .pluck(Arel.sql("#{sql_month}, SUM(amount), SUM(tax)"))
    end

    def delivery_app_sales
      baemin_sales
        .merge(yogiyo_sales) { |_, a, b| a + b }
        .merge(baedaltong_sales) { |_, a, b| a + b }
        .sort.reverse.to_h
        .transform_values do |recaps|
          recaps.sort_by { |recap| -recap.amount }
        end
    end

    def pre_noticed_tax
      vat_return.pre_form&.pre_noticed_tax || vat_return.pre_noticed_tax
    end

    private

    memoize def date_range
      Date.new(year, period * 6 - 5)..Date.new(year, period * 6).end_of_month.end_of_day
    end

    memoize def month_range
      Month.from(date_range.first)..Month.from(date_range.last)
    end

    def to_sql_month(column_name)
      "DATE_TRUNC('month', #{column_name})::date"
    end

    def total_sales_amount
      # TODO: should include extra sales
      monthly_card_sales.values.sum +
        monthly_cash_receipts_sales.sum(&:second) +
        monthly_invoices_sales.sum(&:second) +
        total_delivery_app_sales_amount
    end

    memoize def other_class_amounts
      vat_return.pre_form&.sales_amount_by_other_classifications
    end

    memoize def total_delivery_app_sales_amount
      business.baemin_sales_vats.not_cash.where(ordered_at: date_range).sum(:amount) +
        business.yogiyo_sales_recaps.where(month: month_range).sum("online_card_amount + online_mobile_amount + online_etc_amount + offline_cash_amount") +
        baedaltong_sales_relation.sum(:amount)
    end

    def baemin_sales
      sql_month = to_sql_month("baemin_sales_vats.ordered_at")

      business.baemin_sales_vats.not_cash
        .where(ordered_at: date_range)
        .group(Arel.sql("#{sql_month}, order_type"))
        .pluck(Arel.sql("
          #{sql_month},
          order_type,
          SUM(baemin_sales_vats.amount),
          SUM(vat)
        "))
        .group_by(&:first)
        .transform_values do |items|
          items.map do |_, name, amount, vat|
            MonthlyDeliveryAppSales.new("배달의민족", name, amount, vat)
          end
        end
    end

    def yogiyo_sales
      ar = YogiyoMonthlySalesRecap.ar

      business.yogiyo_sales_recaps
        .where(month: month_range)
        .where(ar[:total_amount].gt(ar[:offline_card_amount]))
        .group_by { |recap| recap.month.first_day }
        .transform_values do |(recap)|
          [
            MonthlyDeliveryAppSales.new(
              "요기요",
              "온라인매출",
              recap.online_amount,
              recap.online_amount.fdiv(11).floor,
            ),
            MonthlyDeliveryAppSales.new(
              "요기요",
              "현장 현금매출",
              recap.offline_cash_amount,
              recap.offline_cash_amount.fdiv(11).floor,
            ),
          ].select { |sales| sales.amount.positive? }
        end
    end

    def baedaltong_sales_relation
      orders = business.baedaltong_orders.vat_returnable.where(ordered_at: date_range)

      canceled_order_numbers = orders.canceled.select(:order_number)

      orders.closed.where.not(order_number: canceled_order_numbers)
    end

    def baedaltong_sales
      sql_month = to_sql_month("ordered_at")

      online = baedaltong_sales_relation.paid_online
        .group(Arel.sql(sql_month))
        .sum(:amount)
        .transform_values do |amount|
          [MonthlyDeliveryAppSales.new("배달통", "온라인매출", amount, amount.fdiv(11).floor)]
        end

      offline = baedaltong_sales_relation.paid_offline
        .group(Arel.sql(sql_month))
        .sum(:amount)
        .transform_values do |amount|
          [MonthlyDeliveryAppSales.new("배달통", "현장 현금매출", amount, amount.fdiv(11).floor)]
        end

      online.merge(offline) { |_, a, b| a + b }
    end
  end
end
