Rails.application.routes.draw do
  
  post "accounts/signup"
  post "accounts/login"
  post "accounts/logout"

  post "accounts/password/change", to: "accounts#change_password"

  get  "accounts/avatar", to: "accounts#get_avatar"
  post "accounts/avatar/change", to: "accounts#change_avatar"

  post "data/check", to: "data#check_data"
  post "data/push", to: "data#push_data"
  get  "data/pull", to: "data#pull_data"
  post "data/sync", to: "data#sync_data"

end
