RelaxAdmin::Engine.routes.draw do
  scope :admin do
    get '/' => 'dashboard#index', as: 'dashboard'
    get 'login' => 'security/sessions#new'
    post 'login', to: 'security/sessions#create'
    get 'logout' => 'security/sessions#destroy'
    get 'dashboard/toggle' => 'dashboard#toggle', as: 'toggle_dashboard'

    # Batch actions

    # DELETE
    post 'batch_actions/delete/:model_class', to: 'batch_actions#delete', as: 'batch_delete'
  end
end
