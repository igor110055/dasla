class RecommandList < ApplicationRecord

  def self.recommand_content(domains)
    "🚀 Register your favourite DAS accounts  #domains  #NFTs
🔥 Recommended list:
#{p domains.join('\n')}
👉 Register & Get more: https://das.la/"
  end

  def self.check_domains
    domains = RecommandList.where(is_reg: false, is_recommand: false).order('random()').limit(10)
    $twitter_client.update(RecommandList.recommand_content(domains.pluck(:domain)))
    domains.update_all(is_recommand: true)
  end

  def check_is_reg
    header = {'Content-Type' => 'application/json'}
    url = 'https://mainnet-api.da.systems/v1/das_accountSearch'

    data = {"jsonrpc" => "2.0",
     "id" => 2,
     "method" => "das_accountSearch",
     "params" => [
         {"account" => self.domain,
         "chain_type" => 1,
         "address" => "0xabaf75a934e8b4da85db7c79a9e8c5a0022a1660",
         "account_char_str" => self.domain.split('').map{|i| {"char_set_name" => 2, "char" => i}}
         }
      ]
    }
    begin
      res = RestClient.post(url, data.to_json, headers=header)
      back_data = JSON.parse res.body
      if back_data['result']['data']['status'] != 0
        self.update(is_reg: true)
        return true
      else
        return false
      end
    rescue Exception => e
      p e
      return false
    end
  end

  def select_domains
    while lists = RecommandList.where(is_reg: false, is_recommand: false).order('random()').limit(5)
      break lists if lists.all?{|list| !list.check_is_reg}
    end
  end
  
end
