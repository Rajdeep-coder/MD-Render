Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root to: 'admin/dashboard#index'

  resources :my_dairies 
  
  # authentication controller routes for login api
  post '/auth/login',to:"authentication#login"

  get "/app_version", to: "app_versions#latest"

  # forget_password controller routes for send_otp, verify_otp and reset_password
  post '/forget_password/send_otp',to:"forget_password#send_otp"
  post '/forget_password/verify_otp',to:"forget_password#verify_otp"
  put '/forget_password/forget_password',to:"forget_password#forget_password"

  # reset_password controller routes for create api
  post '/reset_password', to:"reset_password#create"

  #terms and condtion routes
  get "/terms_and_coditions", to: "terms_and_coditions#index"
  get "/privacy_policies", to: "privacy_policies#index"

  resources :customers

  resources :buy_milks  do  
    collection do  
      get "credit_history"
      get "pdf_download"
      get "bill_generation"
      get "customer_summury"
      get :audit_bill
    end
  end

  resources :deposit_histories do  
    collection do  
      get "deposit_history"
    end
  end

  resources :products
  resources :notifications do 
    collection do  
      post "create_device"
      delete "logout"
    end
  end
  resources :charts
  resources :plans

  resources :chart_rates do
    collection do 
      get :per_litter_price
      post :build_chart_rate
      delete :clear_chart_rate
    end
  end

  resources :sell_milks do
    collection do 
      get :graph_data
    end
  end

  resources :contacts, only: :create
  resources :grades

  namespace :admin do
    post "upload_chart_rates", to: "custom_admin#upload_chart_rates", as: "chart_rates_upload"
    get 'charts_by_dairy/:id', to: 'custom_admin#charts_by_dairy', as: 'charts_by_dairy'
  end


  # Fittonia Technologies Pvt. Ltd.
  namespace :fittonia do
    resources :contacts, only: :create
    resources :careers, only: :create
  end
end
