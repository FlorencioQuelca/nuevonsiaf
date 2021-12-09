module Api
  module V1
    class RequestsController < ApplicationController
      before_action :set_request, only: [:show, :validar_cantidades]

      respond_to :json

      def show
        render json: @request, status: 200
      end

      def validar_cantidades
        cantidades_subarticulo = params[:cantidades].map { |e| e[1] }
        resultado = @request.validar_cantidades(cantidades_subarticulo)
        render json: { data: resultado }, status: 200
      end

      private

      def set_request
        @request = Request.find(params[:id])
      rescue
        @request = nil
      end
    end
  end
end
