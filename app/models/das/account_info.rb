module Das
  class AccountInfo < ActiveRecord::Base
    establish_connection(DasDatabase.establish)
    self.table_name = 't_account_info'

    CHAIN_TYPE = {0 => 'CKB', 1 => 'ETH', 2 => 'BTC', 3 => 'TRON'}
    STATUS = {-1 => 'not_open_register', 0 => 'normal', 1 => 'on_sale', 2 => 'on_auction'}

    def self.owner_chain_type_num
      chain_type_num = Das::AccountInfo.select("count(*) as total, owner_chain_type").group(:owner_chain_type).as_json
      data = {}
      Das::AccountInfo::CHAIN_TYPE.each do |k, v|
        data[v] = chain_type_num.find{|t| t['owner_chain_type'] == k}.try(:[], 'total').to_i
      end
      data
    end

  end
end