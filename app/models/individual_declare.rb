class IndividualDeclare < ApplicationRecord
  belongs_to :declare_user
  belongs_to :tax_account, optional: true

  def record
    default_record = "51" + document_code 
    default_record += declare_user.residence_number + "10" + "01" + declare_code + "A01" 
    default_record += individual + declare_month
    default_record += civil_appeal + declare_user.hometax_account
    default_record += submit_date + declare_user.name
    default_record += bank_account
    default_record += tax_agent_field
    default_record += address + declare_period
    default_record += previous_declare_period
  end

  def document_code
    "C110700"
  end

  def bank_account_field
    bank_code + bank_account + bank_type
  end

  def tax_agent_field
    "0" * 67 if tax_agent.blank?
    tax_agent.residence_number + tax_agent.name + tax_agent.code + tax_agent.manage_code + tax_agent.registration_number
  end

  def tax_agent_program_code
    "9000"
  end

  def declare_month
    "#{declare_start_date.year}#{declare_start_date.month}"
  end

  def submit_date
    submit_at.strftime("%F")
  end

  def declare_period
    declare_start_date.strftime("%Y%m%d") + declare_end_date.strftime("%Y%m%d")
  end

  def previous_declare_period
    "0" * 16
  end

  def written_at_date
    written_at.to_date.strftime("%Y%m%d")
  end

  def native_code
    (declare_user.residence_number[6] == "5" || declare_user.residence_number[6] == "6") ? "1" : "2"
  end
end
