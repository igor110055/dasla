module Das
  class TransactionInfo < ActiveRecord::Base
    establish_connection(DasDatabase.establish)
    self.table_name = 't_transaction_info'
  end
end