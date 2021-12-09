module Api
  module V2
    class EstadoController < ApplicationController
      skip_before_action :authenticate_user!
      respond_to :json
      def index
        render json: {estado: 'El servicio de almacenes y activos se encuentra disponible.'}, root: false, status: 200
      end
    end
  end
end
