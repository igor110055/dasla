Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :das_accounts, only: [:index] do
        collection do
          get :sync_total, :day_address, :day_owner, :day_deal
        end
      end
    end
  end

  root 'home#index'
end
