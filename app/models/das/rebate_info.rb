module Das
  class RebateInfo < ActiveRecord::Base
    establish_connection(DasDatabase.establish)
    self.table_name = 't_rebate_info'
  end
end