# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get 'login', to: 'user_sessions#new', as: :login
  get 'logout', to: 'user_sessions#destroy', as: :logout
  get 'account', to: 'users#edit', as: :account

  resources :user_sessions
  resources :expenses

  root to: 'expenses#index'
end
