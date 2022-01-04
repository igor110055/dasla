module Das
  class ReverseInfo < ActiveRecord::Base
    establish_connection(DasDatabase.establish)
    self.table_name = 't_reverse_info'
  end
end