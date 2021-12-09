module Api
  module V1
    class MaterialesController < ApplicationController
      include ActionView::Helpers::NumberHelper
      include ApplicationHelper
      include Fechas

      def index
        desde, hasta = get_fechas(params)
        #materials = Material.cuenta_contable(hasta)
        materials = Material.order("code ASC, description ASC")
        materiales = []
        #totales = Material.cuenta_contable_total(hasta)
        hasta_long = l(hasta, format: :long).upcase
        desde = l(desde, format: :default)
        hasta = l(hasta, format: :default)
        materials.each do |material|
          materiales << {
            codigo: material.code,
            descripcion: material.description
            #subtotal: number_with_delimiter(material['saldo_bs'])
          }
        end
        #total = number_with_delimiter(totales.first['total_saldo_bs'])
        total = 0
        respond_to do |format|
          format.json {
            render json: {materiales: materiales.as_json, total: total, hastaLong: hasta_long, desde: desde, hasta: hasta}, status: 200
          }
        end
      end

      def subarticulos
        desde, hasta = get_fechas(params)
        material = Material.find_by(code: params[:id])
        subarticulos = material.subarticulos_fisico_valorado(desde, hasta)
        respond_to do |format|
          format.json {
            render json: {subarticulos: subarticulos.as_json}, status: 200
          }
        end
      end
    end
  end
end
