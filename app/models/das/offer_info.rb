module Das
  class OfferInfo < ActiveRecord::Base
    establish_connection(DasDatabase.establish)
    self.table_name = 't_offer_info'
  end
end