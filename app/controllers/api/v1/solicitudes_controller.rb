module Api
  module V1
    class SolicitudesController < ApplicationController
      before_action :set_solicitud, only: [:anular]

      respond_to :json

      def index
        render json: Request.unscoped.order(:delivery_date), status: 200, each_serializer: SolicitudSerializer
      end

      def anular
        mensaje = 'Solicitud anulado correctamente'
        estado = 200
        if @solicitud.present?
          if solicitud_params[:mensaje].present?
            @solicitud.invalidate_request(solicitud_params[:mensaje])
          else
            mensaje = 'No se especificó la razón para la anulación'
            estado = 400
          end
        else
          mensaje = 'La solicitud no existe'
          estado = 404
        end
        render json: {mensaje: mensaje}, status: estado
      end

      private

        def set_solicitud
          begin
            @solicitud = Request.unscoped.find(params[:id])
          rescue ActiveRecord::RecordNotFound => e
            @solicitud = nil
          end
        end

        def solicitud_params
          params.require(:solicitud).permit(:mensaje)
        end
    end
  end
end
