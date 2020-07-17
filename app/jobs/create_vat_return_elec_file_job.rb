class CreateVatReturnElecFileJob < ApplicationJob
  queue_as :create_vat_return_elec_file 

  def perform(vat_return_id)
    vat_return = Snowdon::VatReturn.find(vat_return_id)

    file = CreateVatElecFile.call(vat_return_id)

    va_head = Foodtax::VaHead.find_or_initialize_by_vat_return(vat_return)

    if validate_eql_fields(vat_return.form, va_head, file)
      uploadVatReturnFile = <<~QUERY
        mutation {
            uploadVatReturnFile(input: {
              vatReturnId: #{vat_return_id}
              file: "#{file}"
            }){
              result {
                ... on VatReturnNotFoundError {
                  message
                }
                ... on VatReturnFileNotUploadableError {
                  message
                }
              }
            }
          }
      QUERY
      response = Cashnote::GraphqlRequest.new(uploadVatReturnFile, token: nil).http_query
      results = response.dig("data", "uploadVatReturnFile")
      
      return report_to_slack(
        "🤖*부가세* 전자파일 업로드 오류!\n```#{results.dig("result", "message")}```",
        { vat_return_id: vat_return_id, member_cd: vat_return.member_cd },
      ) if results.dig("result", "message").present?

      report_to_slack(
        "🤖*부가세* 전자파일 업로드완료!\n```납부세액: #{vat_return.form.value_vat("27")}```",
        { vat_return_id: vat_return_id, member_cd: vat_return.member_cd },
      )
      return false
    end
    

  rescue ActiveRecord::RecordNotFound => e
    report_to_slack(
      "🤖*부가세* 신고 데이터를 찾을 수 없습니다.\n```Not found : #{e.model}```",
      { vat_return_id: vat_return_id },
    )
  rescue ActiveRecord::RecordInvalid => e
    report_to_slack(
      "🤖*부가세* 전자파일 데이터 내용검증 오류\n```Invalid : #{e.record.errors}```",
      { vat_return_id: vat_return_id },
    )
  rescue Net::HTTPBadResponse
    report_to_slack(
      "🤖*부가세* 전자파일 업로드 요청서버 오류!\n```status not ok```",
      { vat_return_id: vat_return_id },
    )
  end

  def report_to_slack(text, context)
    title = "[Staging] #{text}" if Rails.env.development?
    SlackBot.post(
      blocks: [{
        type: "section",
        text: { type: "mrkdwn", text: text },
      }, {
        type: "context",
        elements: [{
          type: "mrkdwn",
          text: context.map { |name, value| "#{name}=*#{value}*" }.join(" "),
        }],
      }],
      text: text.split("\n").first,
      channel: "#cashnote-tax-ops",
    )
    return false
  end

  def validate_eql_fields(form, va_head, file)
    return report_to_slack(
      "🤖*부가세* 신고검증오류 : *매출* 합계 세액이 다릅니다.\n```계산세액: #{form.value_vat("8").to_i}, 신고예정세액: #{va_head.o_v090.to_i}```",
      { form_id: form.id, member_cd: va_head.member_cd },
    ) if form.value_vat("9").to_i != va_head.o_v090.to_i

    return report_to_slack(
      "🤖*부가세* 신고검증오류 : *매입* 차가감계 세액이 다릅니다.\n```계산세액: #{form.value_vat("17").to_i}, 신고예정세액: #{va_head.i_v080.to_i}```",
      { form_id: form.id, member_cd: va_head.member_cd },
    ) if form.value_vat("17").to_i != va_head.i_v080.to_i

    return report_to_slack(
      "🤖*부가세* 신고검증오류 : *경감공제세액* 합계 세액이 다릅니다.\n```계산세액: #{form.value_vat("20").to_i}, 신고예정세액: #{va_head.v_v040.to_i}```",
      { form_id: form.id, member_cd: va_head.member_cd },
    ) if form.value_vat("20").to_i != va_head.v_v040.to_i

    return report_to_slack(
      "🤖*부가세* 신고검증오류 : *최종* 납부(환급)받을 세액이 다릅니다.\n```계산세액: #{form.value_vat("27").to_i}, 신고세액: #{va_head.real_paytax_amt.to_i}```",
      { form_id: form.id, member_cd: va_head.member_cd },
    ) if form.value_vat("27").to_i != va_head.real_paytax_amt.to_i
    return true
  end
end
