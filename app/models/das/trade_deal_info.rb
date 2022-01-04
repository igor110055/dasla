module Das
  class TradeDealInfo < ActiveRecord::Base
    establish_connection(DasDatabase.establish)
    self.table_name = 't_trade_deal_info'
  end
end