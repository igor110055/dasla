module Das
  class RebateInfo < ActiveRecord::Base
    establish_connection(DasDatabase.establish)
    self.table_name = 't_rebate_info'

    belongs_to :account_info, class_name: 'Das::AccountInfo',foreign_key: :inviter_id, primary_key: :account_id
  end
end