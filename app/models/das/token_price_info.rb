module Das
  class TokenPriceInfo < ActiveRecord::Base
    establish_connection(DasDatabase.establish)
    self.table_name = 't_token_price_info'
  end
end