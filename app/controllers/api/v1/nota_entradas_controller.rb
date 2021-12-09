module Api
  module V1
    class NotaEntradasController < ApplicationController
      before_action :set_nota_entrada, only: [:anular]

      respond_to :json

      def index
        render json: NoteEntry.unscoped.order(:note_entry_date), status: 200, each_serializer: NotaEntradaSerializer
      end

      def anular
        mensaje = 'Nota de entrada anulado correctamente'
        estado = 200
        if @nota_entrada.present?
          if nota_entrada_params[:mensaje].present?
            @nota_entrada.invalidate_note(nota_entrada_params[:mensaje])
          else
            mensaje = 'No se especificó la razón para la anulación'
            estado = 400
          end
        else
          mensaje = 'La nota de entrada no existe'
          estado = 404
        end
        render json: {mensaje: mensaje}, status: estado
      end

      private

        def set_nota_entrada
          begin
            @nota_entrada = NoteEntry.unscoped.find(params[:id])
          rescue ActiveRecord::RecordNotFound => e
            @nota_entrada = nil
          end
        end

        def nota_entrada_params
          params.require(:nota_entrada).permit(:mensaje)
        end
    end
  end
end
