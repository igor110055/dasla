module Das
  class RecordsInfo < ActiveRecord::Base
    establish_connection(DasDatabase.establish)
    self.table_name = 't_records_info'
  end
end