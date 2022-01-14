module Das
  class AccountInfo < ActiveRecord::Base
    establish_connection(DasDatabase.establish)
    self.table_name = 't_account_info'

    has_many :rebate_infos, class_name: 'Das::RebateInfo',foreign_key: :inviter_id, primary_key: :account_id
    belongs_to :reverse_info, class_name: 'Das::ReverseInfo',foreign_key: :owner, primary_key: :address

    CHAIN_TYPE = {0 => 'CKB', 1 => 'ETH', 2 => 'BTC', 3 => 'TRON'}
    STATUS = {-1 => 'not_open_register', 0 => 'normal', 1 => 'on_sale', 2 => 'on_auction'}

    def self.owner_chain_type_num
      chain_type_num = Das::AccountInfo.where.not(owner: '0x0000000000000000000000000000000000000000').select("count(distinct(owner)) as total, owner_chain_type").group(:owner_chain_type).as_json
      data = {}
      Das::AccountInfo::CHAIN_TYPE.each do |k, v|
        data[v] = chain_type_num.find{|t| t['owner_chain_type'] == k}.try(:[], 'total').to_i
      end
      data
    end

    def self.account_chain_num
      chain_type_num = Das::AccountInfo.where.not(owner: '0x0000000000000000000000000000000000000000').select("count(*) as total, owner_chain_type").group(:owner_chain_type).as_json
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

    def self.recent_reg_data
      arr = Das::AccountInfo.where("registered_at > ? ", (Time.now - 2.days).beginning_of_day.to_i)
                .select("DATE_FORMAT(FROM_UNIXTIME(registered_at),'%Y-%m-%d') date, count(*) as count")
                .group('date').order('date asc').as_json(:except => :id)
      complete_date(Time.now - 2.days, Time.now, arr, {'count' => 0})
    end

    def self.recent_owner_data
      arr = Das::AccountInfo.select("date,count(owner) as count")
          .from("(select owner, DATE_FORMAT(FROM_UNIXTIME(min(registered_at)),'%Y-%m-%d') as date,min(registered_at) as registered_at from t_account_info group by OWNER) ua")
          .where("registered_at >= #{(Time.now - 2.days).beginning_of_day.to_i}")
          .group('date').order('date asc').as_json(:except => :id)
      complete_date(Time.now - 2.days, Time.now, arr, {'count' => 0})
    end

    def self.daily_reg_count(begin_at, end_at, owner_chain_types)
      arr = Das::AccountInfo.where("registered_at > ? and registered_at < ?", begin_at, end_at).where(owner_chain_type: owner_chain_types)
          .select("DATE_FORMAT(FROM_UNIXTIME(registered_at),'%Y-%m-%d') date,count(*) as total")
          .group('date').order('date asc').as_json(:except => :id)
      complete_date(Time.at(begin_at), Time.at(end_at), arr, {'total' => 0})
    end

    def self.daily_new_owner(begin_at, end_at, owner_chain_types)
      arr = Das::AccountInfo.select("date,count(owner) as total")
                .from("(select owner, DATE_FORMAT(FROM_UNIXTIME(min(registered_at)),'%Y-%m-%d') as date,min(registered_at) as registered_at,min(owner_chain_type) as min_type from t_account_info group by OWNER) ua")
                .where("min_type in (#{owner_chain_types.join(',')}) and registered_at >= #{begin_at} and registered_at <= #{end_at}")
                .group('date').order('date asc').as_json(:except => :id)
      complete_date(Time.at(begin_at), Time.at(end_at), arr, {'total' => 0})
    end

    def day_deal(begin_at, end_at)
      arr = Das::TradeDealInfo.where("block_timestamp > ? and block_timestamp < ?", begin_at, end_at)
                .select("sum(price_ckb) as ckb_total, sum(price_usd) as usd_total, DATE_FORMAT(FROM_UNIXTIME(block_timestamp/1000),'%Y-%m-%d') date")
                .group('date').order('date asc').as_json(:except => :id)
      complete_date(Time.at(begin_at/1000), Time.at(end_at/1000), arr, {'ckb_total' => 0, 'usd_total' => 0})
    end

    def self.complete_date(begin_at, end_at , array, default = {})
      new_array = []
      (begin_at.to_date..end_at.to_date).each do |date|
         check_data = array.find{|i| i['date'] ==  date.strftime('%Y-%m-%d')}
         new_array << (check_data.present? ? check_data : {'date' => date.strftime('%Y-%m-%d')}.merge(default))
      end
      new_array
    end
    
  end
end