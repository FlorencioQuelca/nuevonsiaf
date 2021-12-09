module Api
  module V1
    class AuxiliaresController < ApplicationController
      before_action :set_auxiliar

      def show
        respond_to do |format|
          format.json {
            if @auxiliar.present?
              render json: @auxiliar, each_serializer: AuxiliarySerializer, root: false,
                     status: 200
            else
              render json: { mensaje: 'No tiene activos asignados.' },
                     status: 404
            end
          }
        end
      end

      private
        def set_auxiliar
          begin
            @auxiliar = Auxiliary.find(params[:id])
          rescue ActiveRecord::RecordNotFound => e
            @auxiliar = nil
          end
        end
    end
  end
end
