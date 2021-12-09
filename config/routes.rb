require 'year_constraint'
require 'api_constraints'

Rails.application.routes.draw do

  default_url_options protocol: '//' # HTTP o HTTPS
  default_url_options host: Rails.application.secrets.rails_host

  namespace :api, defaults: {format: :json}, except: [:new, :edit] do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do

      resources :nota_entradas, only: [:index] do
        put :anular, on: :member
      end

      resources :solicitudes, only: [:index] do
        put :anular, on: :member
      end

      resources :users, only: [:obt_historico_actas] do
        get :obt_historico_actas, on: :member
        get :obt_activos, on: :member
      end

      resources :reportes, only: [:activos] do
        get :activos, on: :collection
      end

      resources :seguros, only: [:create, :update]

      resources :proveedores, only: [:index]

      resources :activos, only: [:index] do
        get :sin_seguro_vigente, on: :member
      end

      resources :requests, only: [:show] do
        post :validar_cantidades, on: :member
      end

      resources :auxiliares, only: [:show]

      resources :accounts, only: [:show]

      resources :suppliers, only: [:show]

      resources :materiales, only: [:index] do
        get :subarticulos, on: :member
      end

    end
    namespace :v2, constraints: ApiConstraints.new(version: 2, default: true) do
      get '/estado', to: 'estado#index', as: :estado
      get '/almacenes/articulos' => 'almacenes#articulos', as: :articulos_almacenes
      get '/almacenes/solicitud' => 'almacenes#obtener_solicitud', as: :obtener_solicitud_almacenes
      post '/almacenes/solicitud' => 'almacenes#crear_solicitud', as: :crear_solicitud_almacenes
      patch '/almacenes/solicitud' => 'almacenes#actualizar_solicitud', as: :actualizar_solicitud_almacenes
      get '/almacenes/proveedores' => 'almacenes#proveedores', as: :proveedores_almacenes
      post '/almacenes/ingreso' => 'almacenes#crear_nuevo_ingreso', as: :crear_nuevo_ingreso_almacenes

      get '/activos/usuario/:usuario', to: 'activos#activos_funcionario', as: :activos_funcionario_activos
      get '/activos/buscar', to: 'activos#buscar', as: :buscar_activos
      post '/activos/devolucion', to: 'activos#devolucion', as: :devolucion_activos
      post '/activos/asignacion', to: 'activos#asignacion', as: :asignacion_activos
      get '/activos/ubicaciones', to: 'activos#ubicaciones', as: :ubicaciones_activos
      get '/activos/auxiliares', to: 'activos#auxiliares', as: :auxiliares_activos
      get '/activos/estados', to: 'activos#estados', as: :estados_activos
      get '/activos/proveedores', to: 'activos#proveedores', as: :proveedores_activos
      post '/activos/ingreso', to: 'activos#crear_nuevo_ingreso', as: :crear_nuevo_ingreso_activos
      post '/activos/baja', to: 'activos#baja', as: :baja_activos

      namespace :almacenes do
        resources :ingresos, only: [:update]
        resources :reportes, only: [] do
          post :fisico_valorado, on: :collection
          post :fisico_valorado_pdf, on: :collection
          post :fisico_valorado_ods_csv, on: :collection
        end
      end
    end
  end

  resources :gestiones, except: [:destroy] do
    put 'cerrar', on: :member
  end
  resources :ufvs, except: [:show, :destroy]
  resources :ubicaciones, except: [:show, :destroy]
  resources :ingresos do
    get :obt_cod_ingreso, on: :collection
  end

  resources :reportes do
    collection do
      get :kardex
      get :activos
      get :depreciacion
      get :resumen
      get :cuenta_contable
      get :inventario_fisico_valorado_v2
      get :estadisticas
      get :bajas
    end
  end

  resources :entry_subarticles, only: [:edit, :update]

  resources :note_entries, except: [:destroy] do
    get :get_suppliers, on: :collection
    get :obt_cod_ingreso, on: :collection
  end

  # proveedores
  resources :suppliers do
    get :note_entries, on: :member
    get :ingresos, on: :member
  end

  resources :accounts do
    get :auxiliares, on: :member
    get :activos, on: :member
  end

  resources :seguros do
    get :asegurar, on: :member
    get :incorporaciones, on: :member
    get :activos, on: :member
    get :resumen, on: :member
  end

  resources :bajas, only: [:index, :new, :create, :show, :edit]

  resources :requests, except: [:edit, :destroy] do
    get :obtiene_nro_solicitud, on: :collection
  end

  resources :materials, except: [:destroy] do
    post :change_status, on: :member
    get :reports, on: :collection
    post :fisico_valorado, on: :collection
  end

  resources :subarticles, except: [:destroy] do
    resources :kardexes, only: [:index]

    member do
      post :change_status
      get :kardex_v2
    end
    collection do
      get :get_subarticles
      get :autocomplete
      post :first_entry
    end
  end

  resources :barcodes, only: [:index] do
    collection do
      get :obt_cod_barra
      post :pdf
    end
  end

  resources :proceedings, only: [:index, :show, :create, :update]

  resources :declines, only: [:index]

  resources :versions, only: [:index] do
    post :export, on: :collection
  end

  resources :assets, except: [:destroy] do
    member do
      get :historical
      get :depreciacion
    end
    collection do
      get :autocomplete
      get :admin_assets
      get :search
      get :assignation
      get :devolution
      get :users
      get :departments
    end
  end

  resources :auxiliaries, except: [:destroy] do
    post :change_status, on: :member
    get :activos, on: :member
  end

  resources :accounts, only: [:index, :show] do
    post :change_status, on: :member
  end

  resources :departments, except: [:destroy] do
    post :change_status, on: :member
    get :download, on: :member
  end

  resources :buildings, except: [:destroy] do
    post :change_status, on: :member
  end

  resources :api_tokens, except: [:destroy] do
    post :change_status, on: :member
  end

  resources :entities

  resources :users, except: [:destroy] do
    post :change_status, on: :member
    get :welcome, on: :collection
    get :download, on: :member
    get :autocomplete, on: :collection
    get :historical, on: :member
    get :historico_almacen, on: :member
    get :verificar_usuario, on: :collection
    get :ver_duplicados, on: :collection
    get :ver_ci_incongruentes, on: :collection
    get :verificar_campo, on: :collection
    post :agrupacion_usuario, on: :collection
    post :guardar_agrupacion, on: :collection
    post :eliminar_usuario, on: :collection
  end

  get '/datatables-spanish', to: 'welcome#datatables_spanish', as: :spanish_datatables
  get '/dashboard', to: 'dashboard#index', as: :dashboard
  patch '/dashboard/update_password', to: 'dashboard#update_password', as: :update_password_dashboard
  post '/dashboard/announcements/hide', to: 'dashboard#hide', as: :hide_announcement

  post '/dbf/:model/import', to: 'dbf#import', constraints: { model: /(buildings|departments|users|accounts|auxiliaries|assets)/ }, as: 'import_dbf'
  get '/dbf/:model', to: 'dbf#index', constraints: { model: /(buildings|departments|users|accounts|auxiliaries|assets)/ }, as: 'dbf'
  get '/dbf', to: redirect("#{ Rails.application.config.action_controller.relative_url_root }/dbf/buildings"), as: 'migration'

  devise_for :users, controllers: { sessions: "sessions" }, skip: [ :sessions ]
  as :user do
    get '/login' => 'sessions#new', as: :new_user_session
    post '/login' => 'sessions#create', as: :user_session
    delete '/logout' => 'sessions#destroy', as: :destroy_user_session
  end

  resources :welcome, only: [:index]

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'users#welcome'
end
