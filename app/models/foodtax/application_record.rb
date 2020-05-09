module Foodtax
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
    establish_connection FOODTAX_DB

    self.table_name_prefix = "dbo."
    self.pluralize_table_names = false
    default_scope { order(reg_date: :desc) }

    after_initialize :default_dates, :default_user_id

    private

    def default_dates
      self.reg_date ||= Time.now.strftime("%F %T")
      self.updt_date ||= Time.now.strftime("%F %T")
    end

    def default_user_id
      self.reg_user_id = "KCD" if reg_user_id.blank?
      self.updt_user_id = "KCD" if updt_user_id.blank?
    end
  end
end
