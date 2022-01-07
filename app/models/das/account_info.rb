module Das
  class AccountInfo < ActiveRecord::Base
    establish_connection(DasDatabase.establish)
    self.table_name = 't_account_info'

    has_many :rebate_infos, class_name: 'Das::RebateInfo',foreign_key: :inviter_id, primary_key: :account_id


    CHAIN_TYPE = {0 => 'CKB', 1 => 'ETH', 2 => 'BTC', 3 => 'TRON'}
    STATUS = {-1 => 'not_open_register', 0 => 'normal', 1 => 'on_sale', 2 => 'on_auction'}

    def self.owner_chain_type_num
      chain_type_num = Das::AccountInfo.select("count(distinct(owner)) as total, owner_chain_type").group(:owner_chain_type).as_json
      data = {}
      Das::AccountInfo::CHAIN_TYPE.each do |k, v|
        data[v] = chain_type_num.find{|t| t['owner_chain_type'] == k}.try(:[], 'total').to_i
      end
      data
    end

    def self.account_chain_num
      chain_type_num = Das::AccountInfo.select("count(*) as total, owner_chain_type").group(:owner_chain_type).as_json
      data = {}
      Das::AccountInfo::CHAIN_TYPE.each do |k, v|
        data[v] = chain_type_num.find{|t| t['owner_chain_type'] == k}.try(:[], 'total').to_i
      end
      data
    end

    def self.set_cloud_word_num(time = Time.now.yesterday.to_i)
      all_words = Word.all
      Das::AccountInfo.where("registered_at > ?", time).find_each do |info|
        all_words.each do |word|
          if info.account[0..-5].include? word.name
            word.num += 1
          end
        end
      end
      all_words.each do |word|
        word.save
      end

    end

  end
end