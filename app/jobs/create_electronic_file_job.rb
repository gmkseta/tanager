class CreateElectronicFileJob < ApplicationJob
  queue_as :default

  def perform(declare_user_id)
    declare_user = DeclareUser.find(declare_user_id)
    year = 1.year.ago.year
    CreateIncomeFoodtax.call(declare_user_id)
    ic_head = Foodtax::IcHead.find_by(
      cmpy_cd: "00025",
      person_cd: declare_user.person_cd,
      term_cd: "#{year}",
      declare_seq: "1",
      declare_type: "01"
    )
    if ic_head.present?
      declare_file_base64 = ic_head.declare_file
      UploadElectronicFile.call(
        owner_id: declare_user.user.owner_id,
        year: year,
        file_string: declare_file_base64
      )
      SlackBot.ping("🤖*전자파일* 전자파일 업로드완료!", channel: "#tax-ops")
    else
      SlackBot.ping("⚠️*전자파일오류* 푸드택스 파일 생성 오류", channel: "#tax-ops")
      raise "#{declare_user.inspect} is not able to create elec file"
    end
  end
end
