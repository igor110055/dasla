module Das
  class BlockInfo < ActiveRecord::Base
    establish_connection(DasDatabase.establish)
    self.table_name = 't_block_info'
  end
end