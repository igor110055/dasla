module Das
  class TradeInfo < ActiveRecord::Base
    establish_connection(DasDatabase.establish)
    self.table_name = 't_trade_info'
  end
end