class Api::V1::DasAccountsController < ActionController::API
  def index
    render json: { results: '测试接口' }.to_json, status: :ok
  end

  def sync_total
    render json: {account_num: Das::AccountInfo.count,
                  owner_num: Das::AccountInfo.select("distinct(owner)").count,
                  owner_chain_type_num: Das::AccountInfo.owner_chain_type_num,
                  account_chain_num: Das::AccountInfo.account_chain_num,
                  owner_order: Das::AccountInfo.select("count(*) total, owner").group(:owner).order('total desc').limit(5).as_json(:except => :id)
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
    render json:  Das::AccountInfo.select("index_day,count(owner) as total")
                      .from("(select owner, DATE_FORMAT(FROM_UNIXTIME(min(registered_at)),'%Y-%m-%d') as index_day, min(owner_chain_type) as min_type from t_account_info
                      where owner_chain_type in (#{owner_chain_types.join(',')}) and registered_at > #{begin_at} and registered_at < #{end_at} group by OWNER) ua")
                      .group('index_day').order('index_day asc').as_json(:except => :id), status: :ok
  end

  def day_owner
    begin_at = params[:begin_at].present? ? params[:begin_at].to_time.to_i : (Time.now - 3.months).to_i
    end_at = params[:end_at].present? ? params[:end_at].to_time.to_i : (Time.now).to_i
    if params[:owner_chain_type].present?
      owner_chain_types = [params[:owner_chain_type]]
    else
      owner_chain_types = Das::AccountInfo::CHAIN_TYPE.keys
    end
    render json: Das::AccountInfo.where("registered_at > ? and registered_at < ?", begin_at, end_at).where(owner_chain_type: owner_chain_types)
                     .select("count(distinct(owner)) as total, DATE_FORMAT(FROM_UNIXTIME(registered_at),'%Y-%m-%d') index_day")
                     .group('index_day').order('index_day asc').as_json(:except => :id), status: :ok
  end

  def day_deal
    begin_at = params[:begin_at].present? ? params[:begin_at].to_time.to_i*1000 : (Time.now - 3.months).to_i*1000
    end_at = params[:end_at].present? ? params[:end_at].to_time.to_i*1000 : (Time.now).to_i*1000

    render json: Das::TradeDealInfo.where("block_timestamp > ? and block_timestamp < ?", begin_at, end_at)
                     .select("sum(price_ckb) as ckb_total, sum(price_usd) as usd_total, DATE_FORMAT(FROM_UNIXTIME(block_timestamp/1000),'%Y-%m-%d') index_day")
                     .group('index_day').order('index_day asc').as_json(:except => :id), status: :ok
  end

  def invitee_num
    render json: Das::AccountInfo.joins(:rebate_infos)
                     .select("account, count(*) invitee_num")
                     .group("account").order('invitee_num desc').limit(10).as_json(:except => :id), status: :ok
  end

  def account_length
    render json: Das::AccountInfo.where.not(account: '').select('(length(account) - 4) account_length, count(*) account_num')
                     .group('account_length').order('account_num desc').as_json(:except => :id), status: :ok
  end

  def cloud_word
    render json: Word.order('num desc').as_json(:except => :id), status: :ok
  end



end