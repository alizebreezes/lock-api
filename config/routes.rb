Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  post "/handle_report", to: 'reports#handle', defaults: { format: :json }
end
