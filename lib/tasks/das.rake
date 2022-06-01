# frozen_string_literal: true
namespace :das do

  desc "cloud word"
  task cloud_word: :environment do
    Das::AccountInfo.set_cloud_word_num
  end

  desc 'get bit opensea'
  task get_bit_opensea: :environment do
    EthBit.get_bits('0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85', 'successful', 'eth')
    EthBit.get_bits('', 'successful', 'bit')
  end

  desc "get ens order"
  task get_ens_order: :environment do
    url = 'https://api.opensea.io/api/v1/events?asset_contract_address=0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85&event_type=successful'
    datas = JSON.parse RestClient.get(url, headers={"Accept" => 'application/json', "X-API-KEY" => Setting.os_key.to_s})
    arr = Setting.ens_orders || []
    datas['asset_events'].reverse.each do |data|
      if aa = arr.find{|i| i['token_id'] == data['asset']['token_id']}
        aa['name'] = data['asset']['name']
      else
        arr.unshift({ :address => data['asset']['asset_contract']['address'],
                # :decimals => data['payment_token']['decimals'],
                :image_url => data['asset']['image_url'],
                :symbol => data['payment_token']['symbol'],
                :usd_price => data['payment_token']['usd_price'],
                :total_price => data['total_price'].to_f/10**data['payment_token']['decimals'].to_i,
                :quantity => data['quantity'],
                :name => data['asset']['name'],
                :token_id => data['asset']['token_id'],
                :event_timestamp => data['event_timestamp'],
                :is_post_twitter => false,
                :status => Das::AccountInfo.check_ens_account(data['asset']['name'][0..-5])
              })
      end
    end
    Setting.ens_orders = arr.uniq[0..99]
    # if set = Setting.ens_orders[0] && set[:total_price].to_f > Setting.ens_price.to_f && set[:status] == 0 && !set[:is_post_twitter]
    #   $twitter_client.update("🚀 Register your favourite DAS accounts  #domains  #NFTs #{set[:name][0..-5]}.bit")
    #   set[:is_post_twitter] = true
    # end
  end

end

