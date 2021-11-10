class Api::V1::DasAccountsController < ActionController::API
  def index
    render json: { results: '测试接口' }.to_json, status: :ok
  end
end