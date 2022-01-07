class RecommandList < ApplicationRecord

  def self.recommand_content(domains)
    "🚀 Register your favourite DAS accounts  #domains  #NFTs

🔥 Recommended list:

#{domains.join('
')}

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

  def self.check_lay2_account_CKB
    ckbs = []
    (1..18811).to_a.each do |i|
      url = "https://www.layerview.io/zh-CN/account/#{i}"
      data = RestClient.get(url).body
      json = JSON.parse data.match(/"application\/json">(.*)<\/script><script nom/)[1]
      ckbs << json['props']['pageProps']['ckb'].to_s.gsub(',', '').to_f
      p [i, ckbs.last]
    end
  end

  def self.check_ckb_price(operation = false)
    binance_url = 'https://vapi.binance.com/api/v3/avgPrice?symbol=CKBUSDT'
    ave_url = 'https://opencw.xyz/v1api/v1/tokens/0xe934f463d026d97f6ce0a10215d0ac4224f0a930-nervos'
    key = '598cfc6f041d8c11477646176fff1820754af50f1639408667170'
    b_price = JSON.parse(RestClient.get(binance_url).body)['price'].to_f rescue 0
    y_price = JSON.parse(CGI.unescape(Base64::decode64(JSON.parse(RestClient.get(ave_url, headers={'Authorization' => key}).body)['encode_data'])))['token']['current_price_usd'].to_f rescue 0
    if operation
      if b_price - y_price >= 0.0006
        post_alert("币安：#{b_price},YOK：#{y_price}")
      end
    else
      if y_price - b_price >= 0.0006
        post_alert("币安：#{b_price},YOK：#{y_price}")
      end
    end
  end

  def self.post_alert(content = '')
    key = ''
    url = "https://sctapi.ftqq.com/#{key}.send"
    RestClient.post(url, {title: '差价通知', desp: content})
  end
  
end
