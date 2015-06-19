require 'resque/server'
Webauto::Application.routes.draw do

 

  

  # TODO: KLUDGE: MANUALLY BRING THE TYPUS ROUTES IN
  #       Typus used to provide :
  #           Typus::Routes.draw(map)
  #       But that is no longer the case.
  scope "admin", :module => :admin, :as => "admin" do

    match "/" => "dashboard#show", :as => "dashboard"
    match "user_guide" => "base#user_guide"

    if Typus.authentication == :session
      resource :session, :only => [:new, :create, :destroy], :controller => :session
      resources :account, :only => [:new, :create, :show, :forgot_password] do
        collection do
          get :forgot_password
          post :send_password
        end
      end
    end

    Typus.models.map { |i| i.to_resource }.each do |resource|
      match "#{resource}(/:action(/:id(.:format)))", :controller => resource
    end

    Typus.resources.map { |i| i.underscore }.each do |resource|
      match "#{resource}(/:action(/:id(.:format)))", :controller => resource
    end
  end
  # END KLUDGE


  mount Resque::Server.new, at: "/resque"
  devise_for :users, skip: [:session, :password, :registration, :confirmation], :controllers => {
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  scope '(:locale)' do
    authenticated :user do
      root :to => 'cars#index'
    end
    root :to => "cars#index"

    devise_for :users, :controllers => {:registrations => "registrations"}, skip: [:omniauth_callbacks]
    as :user do
      get '/users/profile' => 'devise/registrations#edit', :as => :profile
      get '/users/settings' => 'users#edit',:as=>:settings
    end
    #match '/cars'=>'cars#index',:as=>:cars
    #resource :dashboard, :controller => :users, :only => :show
    match '/contact'=>'home#contact',:as=>:contact
    match '/terms-conditions'=>'home#terms',:as=>:terms
    match '/privacy-policy'=>'home#privacy',:as=>:privacy
    match '/about'=>'home#about',:as=>:about
    match '/sitemap'=>'home#site_map',:as=>:site_map
    match '/seller-safety'=>'home#seller_safety',:as=>:safety
    match '/popular-searches'=>'home#popular',:as=>:popular
    match '/searches/destroy_all' => 'searches#destroy_all', :as=>:destroy_all
    match '/searches/show_more(/:advert_id)'=>'searches#show_more',:as=>:show_more
    match "/users/dashboard" => "users#show", :as => :dashboard
    #match "/ads(/:page)" => "users#ads", :as => :ads
    match 'searches/new(/:search)(/:value)(/:model)'=>'searches#new',:as=>:new_search
    match 'vehicles/update_region_select/:id', :controller=>'vehicles', :action => 'update_region_select'
    match "vehicles/find_details",:controller=>'vehicles', :action => 'find_details'
    get "vehicles/show_states",:as=> 'show_states'
    get "vehicles/show_cities",:as=> 'show_cities'
    get "vehicles/show_regions_in_search",:as=> 'show_regions_in_search'
    get "vehicles/update_states",:as=> 'update_states'
    match "vehicles/get_recently_viewed_vehicles",:controller=>'vehicles',:action=>'get_recently_viewed_vehicles'
    match 'help/buying-a-car'=>'help#buying-a-car',:as=>:buying_a_car
    match 'help/selling-a-car'=>'help#selling-a-car',:as=>:selling_a_car
    get 'dealers(/:page)',:to=> 'users#index',:as => :dealers
    resources :users 
    resources :cars do
      match 'search(/:id)(/:sort)(/:page)' => 'cars#search',:via => [:post,:get], :as => :search,:on => :collection
      match 'solr_search'=>'cars#solr_search',:as=>:solr_search,:on => :collection
      member do
        get :save, :watch,:unsave,:compare
      end
    end
    resources :orders
    resources :services
    resources :line_items
    resources :carts
    resources :garage_items
    resources :adverts do
      match 'page(/:page)' => 'adverts#index',:via => [:post,:get],:on => :collection
      member do
        get :details,:statistics,:features,:photos,:contact,:restore,:preview,:checkout,:really_destroy,:activate,:deactivate,:show_secondary_phone,:show_primary_phone
      end
    end
    get '/adverts', to: 'adverts#index', as: 'adverts'
    resources :bikes do
      match 'search(/:id)(/:sort)(/:page)' => 'bikes#search',:via => [:post,:get], :as => :search,:on => :collection
    end
    resources :searches do
      collection do
        get :remove_all,:popular,:expensive
      end
    end
    #get '/saved_searches', to: 'searches#index', as: 'searches'
    resources :vehicles do
      resources :inquiries, :only => [:create]
      resources :comments,:only=>[:new,:create,:destroy]
      match 'search(/:id)(/:sort)(/:page)' => 'vehicles#search',:via => [:post,:get], :as => :search,:on => :collection
      member do
         post :sort_photos
         get :show_interesting,:show_similar,:show_viewed,:show_reg_nr,:show_vin
       end

    end
    resources :compared_items,:only=> [:index,:destroy]
  match "/compare" => "compared_items#index",:as=>:compare
    #match 'vehicle_steps/:id', :controller=>'vehicle_steps', :action => 'index',:as=>:vehicle_steps
    resources :pictures do
       collection do
         get :fail_upload
       end
    end
       resources :dealer_pictures do
       collection do
         get :fail_upload
       end
    end
    resources :saved_items do
      collection do
        get 'remove_all'
      end
    end
    get '/saved_items', to: 'saved_items#index', as: 'saved_items'
  end
end