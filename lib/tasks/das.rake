# frozen_string_literal: true
namespace :das do

  desc "cloud word"
  task cloud_word: :environment do
    Das::AccountInfo.set_cloud_word_num
  end

  desc "get ens order"
  task get_ens_order: :environment do
    url = 'https://api.opensea.io/api/v1/events?asset_contract_address=0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85&event_type=successful'
    datas = JSON.parse RestClient.get(url, headers={"Accept" => 'application/json', "X-API-KEY" => Setting.os_key.to_s})
    datas['asset_events'].each do |data|
      arr = Setting.ens_orders || []
      unless arr.map{|i| i['name']}.include?(data['asset']['name'])
        arr << { :address => data['asset']['asset_contract']['address'],
                :decimals => data['payment_token']['decimals'],
                :image_url => data['payment_token']['image_url'],
                :symbol => data['payment_token']['symbol'],
                :usd_price => data['payment_token']['usd_price'],
                :quantity => data['quantity'],
                :name => data['asset']['name'],
                :token_id => data['asset']['token_id']
              }
      end
    end
    Setting.ens_orders = arr[0..99]
  end


end

