module Das
  class IncomeCellInfo < ActiveRecord::Base
    establish_connection(DasDatabase.establish)
    self.table_name = 't_income_cell_info'
  end
end