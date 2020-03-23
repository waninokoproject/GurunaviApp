Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'restaurants#top'
  #resourcesはやめましょう。
  #resources :restaurants
  get "restaurants" => "restaurants#index"
  post "restaurants/coordinate"
  post "restaurants/page"
  post "restaurants/search"
  #post "restaurants/coordinate"
end
