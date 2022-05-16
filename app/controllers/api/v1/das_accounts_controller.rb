class Api::V1::DasAccountsController < ActionController::API
  def index
    render json: { results: '测试接口' }.to_json, status: :ok
  end

  def sync_total
    render json: {account_num: Das::AccountInfo.where.not(account: '').count,
                  owner_num: Das::AccountInfo.where.not(account: '').select("distinct(owner)").count,
                  owner_chain_type_num: Das::AccountInfo.owner_chain_type_num,
                  account_chain_num: Das::AccountInfo.account_chain_num,
                  owner_order: Das::AccountInfo.left_outer_joins(:reverse_info)
                                   .select("count(*) total,min(t_reverse_info.account) as reverse_record,owner")
                                   .group(:owner).order('total desc').limit(10)
                                   .as_json(:except => :id).each{|i| i['reverse_record'] = i['reverse_record'].to_s},
                  recent_reg_data: Das::AccountInfo.recent_reg_data,
                  recent_owner_data: Das::AccountInfo.recent_owner_data,
                  update_time: Time.at(Das::AccountInfo.last.registered_at).strftime('%Y-%m-%d %H:%M:%S')
                  }, status: :ok
  end

  def daily_reg_count
    begin_at = params[:begin_at].present? ? params[:begin_at].to_time.to_i : (Time.now - 3.months).to_i
    end_at = params[:end_at].present? ? params[:end_at].to_time.to_i : (Time.now).to_i
    if params[:owner_chain_type].present?
      owner_chain_types = [params[:owner_chain_type]]
    else
      owner_chain_types = Das::AccountInfo::CHAIN_TYPE.keys
    end
    render json:  Das::AccountInfo.daily_reg_count(begin_at, end_at, owner_chain_types), status: :ok
  end

  def daily_new_owner
    begin_at = params[:begin_at].present? ? params[:begin_at].to_time.to_i : (Time.now - 3.months).beginning_of_day.to_i
    end_at = params[:end_at].present? ? params[:end_at].to_time.to_i : (Time.now).to_i
    if params[:owner_chain_type].present?
      owner_chain_types = [params[:owner_chain_type]]
    else
      owner_chain_types = Das::AccountInfo::CHAIN_TYPE.keys
    end
    render json: Das::AccountInfo.daily_new_owner(begin_at, end_at, owner_chain_types), status: :ok
  end

  def day_deal
    begin_at = params[:begin_at].present? ? params[:begin_at].to_time.to_i*1000 : (Time.now - 3.months).to_i*1000
    end_at = params[:end_at].present? ? params[:end_at].to_time.to_i*1000 : (Time.now).to_i*1000

    render json: Das::TradeDealInfo.where("block_timestamp > ? and block_timestamp < ?", begin_at, end_at)
                     .select("sum(price_ckb) as ckb_total, sum(price_usd) as usd_total, DATE_FORMAT(FROM_UNIXTIME(block_timestamp/1000),'%Y-%m-%d') date")
                     .group('date').order('date asc').as_json(:except => :id), status: :ok
  end

  def invites_leaderboard
    render json: Das::AccountInfo.joins(:rebate_infos)
                     .select("account, count(*) invitee_num")
                     .group("account").order('invitee_num desc').limit(10).as_json(:except => :id), status: :ok
  end

  def account_length
      render json: Das::AccountInfo.where.not(account: '').select('(length(account) - 4) length, count(*) value')
                     .group('length').order('value desc').as_json(:except => :id), status: :ok
  end

  def cloud_word
    render json: Word.order('num desc').as_json(:except => :id), status: :ok
  end

  def latest_bit_accounts
    render json: Das::AccountInfo.latest_bit_accounts(params[:page_index], params[:limit], params[:timestamp], params[:direction]), status: :ok
  end

  def get_accounts_by_bit
    render json: Das::AccountInfo.get_accounts_by_bit(params[:account], params[:page_index], params[:limit]), status: :ok
  end

  def get_tx_parser
    params[:type] ||= 'hash'
    return render json: {msg: 'param is error'}, status: :ok if !['witness', 'hash', 'json'].include?(params[:type]) || params[:data].blank?
    case params[:type]
      # when 'json'
      #   data = Base64::decode64(params[:data].gsub(/\W/, ''))
      when 'hash','witness'
        data = params[:data].gsub(/\W/, '')
    end
    return render json: JSON.parse(`~/das_parser_tool/bin/linux/tx_parser -c ~/das_parser_tool/config/config_mainnet.yaml #{params[:type]} #{data}`), status: :ok
  end

  def get_recent_ens_order
    limit = params[:limit] ||= 100
    return render json: [] if params[:t].blank? || params[:s].blank?
    return render json: [] if (params[:t].to_i/1000) < (Time.now - 30.second).to_i || (params[:t].to_i/1000) > (Time.now + 30.second).to_i
    return render json: [] if OpenSSL::Digest.new('MD5').update((params[:t].to_s + Setting.sign.to_s)).hexdigest != params[:s]
    return render json: Setting.ens_orders[0..(limit - 1)]
  end
end