module Das
  class ReverseInfo < ActiveRecord::Base
    establish_connection(DasDatabase.establish)
    self.table_name = 't_reverse_info'
    belongs_to :account_info, class_name: 'Das::AccountInfo',foreign_key: :inviter_id, primary_key: :account_id
  end
end