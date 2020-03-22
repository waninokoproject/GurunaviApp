Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'restaurants#top'
  #resourcesはやめましょう。
  resources :restaurants

  post "restaurants/search"
  post "restaurants/coordinate"
end
