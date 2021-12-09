module Api
  module V1
    class ProveedoresController < ApplicationController
      respond_to :json

      def index
        if params[:limit].present?
          render json: Supplier.limit(params[:limit]).search_supplier(params[:q]), root: false, status: 200
        else
          render json: Supplier.search_supplier(params[:q]), root: false, status: 200
        end
      end
    end
  end
end
