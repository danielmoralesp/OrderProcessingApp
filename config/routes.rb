Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :orders do
    member do 
      patch :process_order
      patch :complete_order
      patch :fail_order
      patch :cancel_order
    end
  end

  root "orders#index"
end
