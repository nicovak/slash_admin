RelaxAdmin::Engine.routes.draw do
  get '/' => 'dashboard#index', as: 'dashboard'
  get 'login' => 'security/sessions#new'
  post 'login', to: 'security/sessions#create'
  get 'logout' => 'security/sessions#destroy'
  get 'dashboard/toggle' => 'dashboard#toggle', as: 'toggle_dashboard'

  # Batch actions
  match 'batch_actions/:action/:model_class', to: 'batch_actions#', via: [:all], as: 'batch_actions'
end
