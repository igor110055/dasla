class EthBit < ApplicationRecord
  CATEGORY = ['ENS', "BIT"]

  def self.get_bits(contract_address ,event_type = '', type = 'bit')
    # successful  transfer  created
    url = "https://api.opensea.io/api/v1/events?asset_contract_address=#{contract_address}"
    if event_type.present?
      url = url + "&event_type=#{event_type}"
    end
    datas = JSON.parse RestClient.get(url, headers={"Accept" => 'application/json', "X-API-KEY" => Setting.os_key.to_s})
    datas['asset_events'].each do |data|
      next if !['successful', 'transfer', 'offer_entered'].include?(data['event_type'])
      bit = EthBit.find_or_initialize_by(category: type, token_id: data['asset']['token_id'])
      bit.assign_attributes({
                                :name => data['asset']['name'],
                                :address => data['asset']['asset_contract']['address'],
                                :image_url => data['asset']['image_url'],
                                :symbol => data['payment_token']['symbol'],
                                :usd_price => data['payment_token']['usd_price'],
                                :total_price => data['total_price'].to_f/10**data['payment_token']['decimals'].to_i,
                                :quantity => data['quantity'],
                                :event_timestamp => data['event_timestamp'],
                                :from_username => (data['from_account']['user']['username'] rescue '')
                            })
      if bit.new_record?
        if type == 'eth' && data['asset']['name'].include?('eth') && Das::AccountInfo.check_ens_account(data['asset']['name'][0..-5]) == 0 && bit.total_price.to_f > Setting.ens_price.to_f
          bit.deal_send_twitter = 1
        end
      end
      if event_type.blank?
        case data['event_type']
          when 'successful'
            bit.deal_send_twitter = 1 if bit.deal_send_twitter == 0
          when 'transfer'
            bit.mint_send_twitter = 1 if bit.mint_send_twitter == 0 && (data['from_account']['user']['username'] == 'NullAddress')
          when 'offer_entered'
            bit.offer_send_twitter = 1 if bit.offer_send_twitter == 0
        end
      end
      bit.save if bit.changed?
    end
  end

  def self.check_twitter
    if aa = EthBit.where(category: 'bit', deal_send_twitter: 1).last
      $twitter_client.update("🎉 #{aa.name} bought for #{aa.total_price} WETH on OpenSea.👇

https://opensea.io/assets/ethereum/#{aa.address}/#{aa.token_id}")
      aa.update(deal_send_twitter: 2)
      return
    end

    if aa = EthBit.where(category: 'bit', offer_send_twitter: 1).last
      $twitter_client.update("🎉 #{aa.name} has a new bid of #{aa.total_price} WETH placed by #{aa.from_username.presence || '***'}.👇

https://opensea.io/assets/ethereum/#{aa.address}/#{aa.token_id}")
      aa.update(offer_send_twitter: 2)
      return
    end


    # if aa = EthBit.where(category: 'bit', pending_send_twitter: 1).limit(10)
    #   $twitter_client.update("🚀 Bit pending #{aa.pluck(:name).join(',')}")
    #   aa.update_all(pending_send_twitter: 2)
    #   return
    # end

    if aa = EthBit.where(category: 'bit', mint_send_twitter: 1).last
      $twitter_client.update("🎉#{aa.name} was just minted on OpenSea, take a look and snatch it?  .bit, your Web3 identity.👇

https://opensea.io/assets/ethereum/#{aa.address}/#{aa.token_id}")
      aa.update(mint_send_twitter: 2)
      return
    end

    if aa = EthBit.where(category: 'eth', deal_send_twitter: 1).last
      $twitter_client.update("🔸#{aa.name} bought for #{aa.total_price} WETH on OpenSea.

🚀Grab #{aa.name[0..-5]}.bit now! .bit, your Web3 identity.

https://app.did.id/account/register/#{aa.name[0..-5]}.bit?inviter=cryptofans.bit&channel=cryptofans.bit​")
      aa.update(deal_send_twitter: 2)
      return
    end


  end

end
