class CreateVatReturnElecFileJob < ApplicationJob
  queue_as :create_vat_return_elec_file

  def perform(vat_return_id)
    file = CreateVatElecFile.call(vat_return_id)
    mutation = <<~QUERY
    mutation {
        uploadVatReturnFile(input: {
          vatReturnId: #{vat_return_id}
          file: "#{file}"
        }){
          result {
            ... on ExecutionError {
              message
            }
          }
        }
      }
    QUERY

    response = Cashnote::GraphqlRequest.new(mutation, token: nil).http_query

    result = response.dig("data", "uploadVatReturnFile")
    raise Net::HTTPBadResponse if result.dig("result", "message").present?

    send_message("🤖*부가세* 전자파일 (id: #{vat_return_id}) 업로드완료!")
  rescue ActiveRecord::RecordInvalid
    send_message("🤖*부가세* 전자파일 (id: #{vat_return_id}) 데이터 검증에 실패하였습니다.")
  rescue Net::HTTPBadResponse
    send_message("🤖*부가세* 전자파일 (id: #{vat_return_id}) 업로드 오류!")
  rescue
    send_message("🤖*부가세* 전자파일 (id: #{vat_return_id}) 데이터 옮기기에 실패하였습니다.")
  end

  def send_message(message)
    message = "[테스트] #{message}" if Rails.env.development?
    SlackBot.ping("#{message}", channel: "#cashnote-tax-ops")
  end
end
