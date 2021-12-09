module Api
  module V2
    module Almacenes
      class IngresosController < ApplicationController
        skip_before_action :verify_authenticity_token
        before_action :set_ingreso, only: [:update]

        respond_to :json

        #patch ingresos(note_entries)
        def update
          respuesta, mensaje = @ingreso.actualizar(params[:ingreso].to_hash)
          render json: formato_respuesta(respuesta, mensaje, {})
        end

        private

        def set_ingreso
          @ingreso = NoteEntry.find(params[:id])
        end
      end
    end
  end
end
