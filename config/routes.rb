Rails.application.routes.draw do

  resources :orders, only: [:index, :new, :create], path_names: { new: 'checkout' }
  get 'cart' => 'cart#index'
  patch 'cart/add'
  delete 'cart/remove'
  patch 'cart/update'

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'pages#landing'
  get 'notifications/' => 'pages#notifications'
  get 'home/' => 'pages#home'
  get 'profile/' => 'pages#profile'
  
  get 'help/' => 'pages#help'
  get 'about/' => 'pages#about'
  get 'partners' => 'pages#partners'
  get 'terms/' => 'pages#terms'
  get 'privacy/' => 'pages#privacy'
  get 'blog/' => 'pages#blog'
  get 'contact' => 'pages#contact'
 

  get 'login/' => 'pages#login'
  get 'forgot/' => 'pages#forgot'
  get 'register/' => 'pages#register'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  resources :stores, only: [:show]

  # These must be the last routes in the file, since they'll match anything
  post '/:city' => 'stores#search_by_address'
  get '/:city' => 'stores#search_by_city'
end
