Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :das_accounts, only: [:index] do
        collection do
          get :sync_total, :daily_reg_count, :daily_new_owner, :day_deal, :invitee_num, :account_length, :cloud_word
        end
      end
    end
  end

  root 'home#index'
end
