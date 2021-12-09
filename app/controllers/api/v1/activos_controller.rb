module Api
  module V1
    class ActivosController < ApplicationController

      respond_to :json

      def index
        activos =
          if params[:barcode].present?
            Asset.buscar_por_barcode(params[:barcode])
          else
            Asset.todos.order(:code)
          end
        sumatoria = activos.inject(0.0) { |total, activo| total + activo.precio }
        resumen = activos.select("accounts.name as nombre, count(*) as cantidad, sum(assets.precio) as sumatoria").group("accounts.name")
        sumatoria_resumen = resumen.inject(0.0) { |total, cuenta| total + cuenta.sumatoria }
        render json: { activos: activos,
                       sumatoria: sumatoria,
                       resumen: ActiveModel::ArraySerializer.new(resumen, each_serializer: ResumenSerializer),
                       sumatoria_resumen: sumatoria_resumen }
      end

      def sin_seguro_vigente
        seguro = Seguro.find(params[:id])
        activos = seguro.activos_sin_seguro
        sumatoria = activos.inject(0.0) { |total, activo| total + activo.precio }
        resumen = activos.select("accounts.name as nombre, count(*) as cantidad, sum(assets.precio) as sumatoria").group("accounts.name")
        sumatoria_resumen = resumen.inject(0.0) { |total, cuenta| total + cuenta.sumatoria }
        render json: { activos: activos,
                       sumatoria: sumatoria,
                       resumen: ActiveModel::ArraySerializer.new(resumen, each_serializer: ResumenSerializer),
                       sumatoria_resumen: sumatoria_resumen }
      end
    end
  end
end
